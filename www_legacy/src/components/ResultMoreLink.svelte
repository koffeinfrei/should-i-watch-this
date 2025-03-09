<script>
  export let link;
</script>

{#if link}
  <a href={link} class="external" target="_blank" rel="noopener external"
    >more</a
  >
{/if}

<style>
  a {
    font-weight: normal;
    font-size: 0.9em;
    margin-left: 8px;
  }
</style>
