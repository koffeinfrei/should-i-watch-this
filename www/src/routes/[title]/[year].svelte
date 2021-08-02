<script context="module">
  import { fetchMovie } from "../../fetchMovie";

  export async function load({ page, session, fetch }) {
    const { title, year } = page.params;

    let movie;
    if (session && session.movie) {
      movie = session.movie;
    }
    // only for SSR
    else {
      movie = await fetchMovie(title, year, fetch);
    }

    if (movie.error) {
      return {
        status: 404,
      };
    }

    return { props: { movie } };
  }
</script>

<script>
  import Result from "../../components/Result.svelte";
  import SearchBox from "../../components/SearchBox.svelte";
  import { goto } from "$app/navigation";
  import { getStores } from "$app/stores";
  const { session } = getStores();

  let titleInput;

  export let movie;

  async function handleSubmit(title) {
    title = title || "";
    session.set({ title });
    await goto("/");
  }
</script>

<SearchBox onSubmit={handleSubmit} />

<Result {movie} />
