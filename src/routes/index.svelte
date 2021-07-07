<script context="module">
  export async function preload(page, session) {
    return { title: (session || {}).title };
  }
</script>

<script>
  import SearchBox from '../components/SearchBox.svelte';
  import SearchStatus from '../components/SearchStatus.svelte';
  import RandomQuote from '../components/RandomQuote.svelte';

  export let title;

  function handleSubmit(newTitle) {
    title = newTitle || '';
  }
</script>

<SearchBox {title} onSubmit={handleSubmit}/>

{#if title === undefined}
  <RandomQuote />
{:else}
  <SearchStatus {title} />
{/if}

<svelte:head>
  <title>Should I watch this?</title>
</svelte:head>
