<script>
  import { getRandomQuote } from '../quotes';

  // we render the quote only client side, otherwise we end up with 2 different
  // random quotes
  let quote;
  if (typeof window !== 'undefined') {
    quote = getRandomQuote();
  }
</script>

<style type="text/scss">
  @import '../styles/result';
</style>

{#if quote}
<div class="box">
  <div class="icon-label"><span class="icon">💭</span>
    <div>“ {quote.quote} ”</div>
    <a rel=prefetch href={quote.url}>{quote.movie}</a>
  </div>
</div>
{/if}
