<script>
  import { onMount } from 'svelte';

  export let title = undefined;
  export let onSubmit;

  let titleInput;

  onMount(async () => {
    titleInput.focus();
  });

  async function handleClick() {
    onSubmit(title);
  }

  async function handleKeyup(event) {
    if (event.key === "Enter") {
      onSubmit(title);
    }
  }

</script>

<section class="box padded">
  <input bind:this={titleInput} bind:value={title} on:keyup={handleKeyup} placeholder="Movie title or IMDb id">
  <button on:click={handleClick}>Look up</button>
</section>
