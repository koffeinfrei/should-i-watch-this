<script>
  import Error from '../components/Error.svelte';
  import Spinner from '../components/Spinner.svelte';
  import { getUrl } from '../getUrl';
  import { fetchMovie } from '../fetchMovie';
  import { goto, stores } from '@sapper/app';
  const { session } = stores();

  export let title;

  let year = '';
  let fetchMoviePromise;

  async function run() {
    year = '';
    fetchMoviePromise = fetchMovie(title, year, fetch);

    fetchMoviePromise.then(async (result) => {
      if (!result.error) {
        session.set({ movie: result });
        await goto(getUrl(result));
      }
    });
  }

  // undefined is considered initial state
  $: if (title !== undefined) {
    run();
  }
</script>

<section class="box">
  {#await fetchMoviePromise}
    <section class="box padded">
      <Spinner />
    </section>
  {:then result}
    {#if result && result.error}
      <Error text={result.error} />
    {/if}
  {:catch error}
    <Error text={error.message} />
  {/await}
</section>
