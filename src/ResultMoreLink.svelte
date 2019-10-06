<script>
  export let link;
</script>

<style>
  a {
    font-weight: normal;
    font-size: 0.9em;
    margin-left: 8px;
  }
</style>

{#if link}
  <a href={link} target="_blank">more ⭧</a>
{/if}
