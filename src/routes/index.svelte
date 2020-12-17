<script context="module">
  export async function preload(page, session) {
    return { title: session?.title };
  }
</script>

<script>
  import SearchBox from '../components/SearchBox.svelte';
  import SearchStatus from '../components/SearchStatus.svelte';
  import { onMount } from 'svelte';
  import { stores } from '@sapper/app';
  const { session } = stores();

  export let title;

  function handleSubmit(newTitle) {
    console.log('index submit', title);
    title = newTitle || '';
  }
</script>

<SearchBox {title} onSubmit={handleSubmit}/>

<SearchStatus {title} />
