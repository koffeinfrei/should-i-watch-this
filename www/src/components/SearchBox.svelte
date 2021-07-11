<script>
  export let title = undefined;
  export let onSubmit;

  let titleInput;

  async function handleClick() {
    onSubmit(title);
  }

  async function handleKeyup(event) {
    if (event.key === "Enter") {
      onSubmit(title);
    }
  }

  async function init(element){
    setTimeout(() => element.focus(), 0);
  }
</script>

<section class="box padded">
  <input bind:this={titleInput} bind:value={title} on:keyup={handleKeyup} placeholder="Movie title or IMDb id" use:init>
  <button on:click={handleClick}>Look up</button>
</section>
