<script>
  import ResultMoreLink from './ResultMoreLink.svelte';

  export let movie;
</script>

<style type="text/scss">
$horizontal-spacing: 50px;
$left-column-width: 9rem;
$box-bottom-spacing: 42px;
$poster-width: 130px;

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

h3 {
  position: relative;
  padding-left: $horizontal-spacing;
}

.icon {
  position: absolute;
  left: 0;
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
    <img src={movie.poster_url || '/default-poster.png'} width="130" class="poster" alt="poster" />
    <a href={movie.trailer_url} target="_blank" class="external trailer">Trailer</a>
  </div>
</div>

<div class="box">
  <h3><span class="icon">{movie.recommendation.emoji}</span>{movie.recommendation.text}</h3>
</div>

<div class="box">
  <h3><span class="icon">🍅</span>Rotten Tomatoes<ResultMoreLink link={movie.links.rotten_tomatoes} /></h3>

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
  <h3><span class="icon">🎬</span>IMDb<ResultMoreLink link={movie.links.imdb} /></h3>

  <table class="full-width">
    <tr>
      <td class="label">Rating</td>
      <td class="value">{movie.scores.imdb.rating}</td>
    </tr>
  </table>
</div>

<div class="box">
  <h3><span class="icon">📈</span>Metacritic<ResultMoreLink link={movie.links.metacritic} /></h3>

  <table class="full-width">
    <tr>
      <td class="label">Score</td>
      <td class="value">{movie.scores.metacritic.score}</td>
    </tr>
  </table>
</div>

<svelte:head>
  <title>{movie.title} | Should I watch this?</title>
</svelte:head>
