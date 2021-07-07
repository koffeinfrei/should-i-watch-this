<script context="module">
  import { fetchMovie } from '../../fetchMovie';

  export async function preload(page, session) {
    const { title, year } = page.params;

    let movie;
    if (session && session.movie) {
      movie = session.movie;
    }
    // only for SSR
    else {
      movie = await fetchMovie(title, year, this.fetch);
    }

    if (movie.error) {
      this.error(404);
    }

    return { movie };
  }
</script>

<script>
  import Result from '../../components/Result.svelte';
  import SearchBox from '../../components/SearchBox.svelte';
  import { goto, stores } from '@sapper/app';
  const { session } = stores();

  let titleInput;

  export let movie;

  async function handleSubmit(title) {
    title = title || '';
    session.set({ title });
    await goto('/');
  }
</script>

<SearchBox onSubmit={handleSubmit} />

<Result movie={movie} />
