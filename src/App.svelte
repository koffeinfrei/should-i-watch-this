<script>
  import { onMount } from 'svelte';

  import { setUrl, getMovieFromUrl } from './url';
  import { fetchMovie } from './fetchMovie';

  import Result from './Result.svelte';
  import Error from './Error.svelte';
  import Spinner from './Spinner.svelte';
  import Footer from './Footer.svelte';

  let titleInput;
  let title = '';
  let year = '';
  let fetchMoviePromise;

  onMount(async () => {
    const {titleFromUrl, yearFromUrl} = getMovieFromUrl();

    if (titleFromUrl) {
      title = titleFromUrl;
      year = yearFromUrl;
      run();
    }
    else {
      titleInput.focus();
    }
  });

  function handleClick() {
    year = '';
    run();
  }

  function handleKeyup(event) {
    if (event.key === "Enter") {
      year = '';
      run();
    }
  }

  function run() {
    fetchMoviePromise = fetchMovie(title, year);

    fetchMoviePromise.then((result) => {
      if (!result.error) {
        setUrl(result);
      }
    });
  }
</script>

<style>
main {
  margin: 0 auto;
  margin-bottom: 53px;
}

@media (min-width: 800px) {
  main {
    width: 800px;
  }
}

.box {
  margin-bottom: 53px;
}

.padded {
  padding-left: 50px;
}
</style>

<main>
  <section class="box padded">
    <input bind:this={titleInput} bind:value={title} on:keyup={handleKeyup} placeholder="Movie title or IMDb id">
    <button on:click={handleClick}>Look up</button>
  </section>

  <section class="box">
    {#await fetchMoviePromise}
      <section class="box padded">
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

<Footer />
