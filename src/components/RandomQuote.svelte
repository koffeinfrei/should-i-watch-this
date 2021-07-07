<script>
  import { getRandomQuote } from '../quotes';
  import { onMount } from 'svelte';

  let movieLink;
  // we render the quote only client side, otherwise we end up with 2 different
  // random quotes
  let quote;
  if (typeof window !== 'undefined') {
    quote = getRandomQuote();

    onMount(() => {
      // the programmatic call to `prefetch` doesn't seem to work. triggering
      // the `rel=prefetch` on the link elements seems to do the trick.
      movieLink.dispatchEvent(new MouseEvent('touchstart', { 'bubbles': true }));
    });
  }
</script>

<style type="text/scss">
  @import '../styles/result';
</style>

{#if quote}
<div class="box">
  <div class="icon-label"><span class="icon">💭</span>
    <div>“ {quote.quote} ”</div>
    <a bind:this={movieLink} rel=prefetch href={quote.url}>{quote.movie}</a>
  </div>
</div>
{/if}
