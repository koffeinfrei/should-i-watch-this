<script>
  import { onMount } from 'svelte';

  import Result from './Result.svelte';
  import Error from './Error.svelte';
  import Spinner from './Spinner.svelte';

  let title = '';
  let year = '';
  let promise;

  onMount(async () => {
    const {titleFromUrl, yearFromUrl} = getMovieFromUrl();

    if (titleFromUrl) {
      title = titleFromUrl;
      year = yearFromUrl;
      handleClick();
    }
  });

  function handleClick() {
    promise = fetchMovie();
  }

  function handleKeyup(event) {
    if (event.key === "Enter") {
      handleClick();
    }
  }

  function setUrl(movie) {
    location.hash = `/${encodeURI(movie.title)}/${movie.year}`;
  }

  function getMovieFromUrl() {
    const [_, titleFromUrl, yearFromUrl] = location.hash.split(/\//);

    if (!titleFromUrl) {
      return {};
    }

    return {
      yearFromUrl,
      titleFromUrl: decodeURI(titleFromUrl)
    }
  }

  async function fetchMovie() {
    if (!title) {
      return { error: 'Hmm? I think you forgot to enter the movie title.' };
    }

    const url = 'http://openfaas.koffeinfrei.org:31112' +
      '/function/should-i-watch-this-www' +
      `?show_links=true&year=${year}`;

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-Auth-Token': ''
      },
      body: title
    });
    return await response.json();
  }
</script>

<style>
main {
  margin: 0 auto;
  max-width: 800px;
  margin-bottom: 53px;
}

.center {
  text-align: center;
}

.box {
  margin-bottom: 53px;
}

.footer {
  margin: auto 0 8px 0;
}

</style>

<main>
  <section class="center box">
    <input bind:value={title} on:keyup={handleKeyup} placeholder="Enter the movie title">
    <button on:click={handleClick}>Lookup</button>
  </section>

  <section class="box">
    {#await promise}
      <section class="center box">
        <Spinner />
      </section>
    {:then result}
      {#if result}
        {#if result.error}
          <Error text={result.error} />
        {:else}
          <Result movie={result} />
        {/if}
      {/if}
    {:catch error}
      <Error text={error.message} />
    {/await}
  </section>
</main>

<section class="center footer">
  Made with ☕️  by <a href="https://www.koffeinfrei.org" target="_blank">Koffeinfrei ⭧</a>
</section>
