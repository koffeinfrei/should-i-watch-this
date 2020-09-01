<script>
  import ResultMoreLink from './ResultMoreLink.svelte';

  export let movie;
</script>

<style>
h2 {
  padding-left: 50px;
}

table.full-width {
  width: 100%;
}

td {
  vertical-align: top;
}

td.label {
  padding-left: 50px;
  width: 9rem;
}

td.value {
  font-weight: bold;
}

h3 {
  position: relative;
  padding-left: 50px;
}

.icon {
  position: absolute;
  left: 0;
}

.box {
  margin-bottom: 42px;
}

@media (min-width: 40em) {
  .summary {
    display: flex;
  }
}

@media (min-width: 40em) {
  .description {
    margin-right: 50px;
  }
}

.poster {
  height: auto;
  width: 130px;
  margin-left: 50px;
  margin-bottom: 42px;
}

@media (min-width: 40em) {
  .poster {
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

  <div>
    <img src={movie.poster_url || '/default-poster.png'} width="130" class="poster" alt="poster" />
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
