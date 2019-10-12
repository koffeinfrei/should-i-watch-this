<script>
  import { onMount } from 'svelte';

  import { setUrl, getMovieFromUrl } from './url';
  import { fetchMovie } from './fetchMovie';

  import Result from './Result.svelte';
  import Error from './Error.svelte';
  import Spinner from './Spinner.svelte';

  let title = '';
  let year = '';
  let fetchMoviePromise;

  onMount(async () => {
    const {titleFromUrl, yearFromUrl} = getMovieFromUrl();

    if (titleFromUrl) {
      title = titleFromUrl;
      year = yearFromUrl;
      handleClick();
    }
  });

  function handleClick() {
    fetchMoviePromise = fetchMovie(title, year);

    fetchMoviePromise.then((result) => {
      if (!result.error) {
        setUrl(result);
      }
    });
  }

  function handleKeyup(event) {
    if (event.key === "Enter") {
      handleClick();
    }
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
    {#await fetchMoviePromise}
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
