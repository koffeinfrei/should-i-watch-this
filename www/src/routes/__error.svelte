<script context="module">
  export function load({ error, status }) {
    return {
      props: {
        error,
        status,
      },
    };
  }
</script>

<script>
  export let status;
  export let error;

  import RandomQuote from "../components/RandomQuote.svelte";

  const dev = process.env.NODE_ENV === "development";

  if (status === 404) {
    error.message = "Oh snap! This is not a movie. This is a 404.";
  }
</script>

<svelte:head>
  <title>{status}</title>
</svelte:head>

<section class="box padded">
  <h1>{status}</h1>

  <h2>{error.message}</h2>
</section>

{#if status === 404}
  <RandomQuote />
{/if}

<section class="box padded">
  <div class="box">
    Try to go <a href="/">back to the start</a>.
  </div>

  {#if dev && error.stack}
    <pre>{error.stack}</pre>
  {/if}
</section>
