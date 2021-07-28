<script>
  import ResultMoreLink from '../components/ResultMoreLink.svelte';
  import { page } from '$app/stores';

  export let movie;

  const { host, path } = $page;
  const protocol = host.startsWith('localhost') ? 'http://' : 'https://';
  const hostWithProtocol = `${protocol}${host}`
  const pageUrl = `${hostWithProtocol}${path}`

  const posterUrl = movie.poster_url || `${hostWithProtocol}/default-poster.png`;

  const pageTitle = `${movie.title} (${movie.year}) | Should I watch this?`;
</script>

<style type="text/scss">
@import '../styles/result';

h2 {
  padding-left: $horizontal-spacing;
}

table {
  border-collapse: separate;
  border-spacing: 0;
}

table.full-width {
  width: 100%;
}

td {
  vertical-align: top;
}

.label {
  padding-left: $horizontal-spacing;
  width: $left-column-width;
}

.value {
  font-weight: bold;
}

.box {
  margin-bottom: $box-bottom-spacing;
}

@media (min-width: 40em) {
  .summary {
    display: flex;
  }
}

@media (min-width: 40em) {
  .description {
    margin-right: $horizontal-spacing;
  }
}

.poster {
  height: auto;
  width: $poster-width;
}

.marketing {
  display: flex;
  margin: 0 0 $box-bottom-spacing $horizontal-spacing;
}

@media (min-width: 40em) {
  .marketing {
    flex-direction: column;
    margin: 0;
  }
}

.trailer {
  margin-left: calc(#{$left-column-width} - #{$poster-width});
}

@media (min-width: 40em) {
  .trailer {
    margin: 0;
  }
}
</style>

<section class="box">
  <div class="summary">
    <div class="description">
      <h2 class="box">{movie.title}</h2>

      <div class="box">
        <table>
          <tr>
            <td class="label">Year</td>
            <td class="value">{movie.year}</td>
          </tr>
          <tr>
            <td class="label">Director</td>
            <td class="value">{movie.director}</td>
          </tr>
          <tr>
            <td class="label">Actors</td>
            <td class="value">{movie.actors}</td>
          </tr>
        </table>
      </div>
    </div>

    <div class="marketing">
      <img src={posterUrl} width="130" class="poster" alt="poster" />
      {#if movie.trailer_url}
        <a href={movie.trailer_url} target="_blank" class="external trailer" rel="noopener external">Trailer</a>
      {/if}
    </div>
  </div>

  <div class="box">
    <h3 class="icon-label"><span class="icon">{movie.recommendation.emoji}</span>{movie.recommendation.text}</h3>
  </div>

  <div class="box">
    <h3 class="icon-label"><span class="icon">🍅</span>Rotten Tomatoes<ResultMoreLink link={movie.links.rotten_tomatoes} /></h3>

    <table class="full-width">
      <tr>
        <td class="label">Score</td>
        <td class="value">{movie.scores.rotten_tomatoes.score}</td>
      </tr>
      <tr>
        <td class="label">Audience</td>
        <td class="value">{movie.scores.rotten_tomatoes.audience}</td>
      </tr>
    </table>
  </div>

  <div class="box">
    <h3 class="icon-label"><span class="icon">🎬</span>IMDb<ResultMoreLink link={movie.links.imdb} /></h3>

    <table class="full-width">
      <tr>
        <td class="label">Rating</td>
        <td class="value">{movie.scores.imdb.rating}</td>
      </tr>
    </table>
  </div>

  <div class="box">
    <h3 class="icon-label"><span class="icon">📈</span>Metacritic<ResultMoreLink link={movie.links.metacritic} /></h3>

    <table class="full-width">
      <tr>
        <td class="label">Score</td>
        <td class="value">{movie.scores.metacritic.score}</td>
      </tr>
    </table>
  </div>
</section>

<svelte:head>
  <title>{pageTitle}</title>

  <!-- Open Graph / Facebook -->
  <meta property="og:type" content="website">
  <meta property="og:url" content={pageUrl}>
  <meta property="og:title" content={pageTitle}>
  <meta property="og:description" content="{movie.recommendation.emoji} {movie.recommendation.text}">
  <meta property="og:image" content={posterUrl}>

  <!-- Twitter -->
  <meta property="twitter:card" content="summary_large_image">
  <meta property="twitter:url" content={pageUrl}>
  <meta property="twitter:title" content={pageTitle}>
  <meta property="twitter:description" content="{movie.recommendation.emoji} {movie.recommendation.text}">
  <meta property="twitter:image" content={posterUrl}>
</svelte:head>
