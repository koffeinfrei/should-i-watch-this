<script>
  import ResultMoreLink from './ResultMoreLink.svelte';

  export let movie;
</script>

<style>

h2 {
  padding-left: 38px;
}

table.full-width {
  width: 100%;
}

td {
  vertical-align: top;
}

td.label {
  padding-left: 38px;
  width: 20%;
}

td.value {
  font-weight: bold;
}

.icon {
  display: inline-block;
  width: 38px;
}

.recommendation {
  text-align: center;
}

.box {
  margin-bottom: 42px;
}

.border {
  padding-top: 8px;
  border: 1px solid #ccc;
}

.summary {
  display: flex;
}

.description {
  margin-right: 38px;
}

.poster {
  height: auto;
  width: 130px;
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
    <img src={movie.poster_url || '/default-poster.png'} width="220" class="poster" alt="poster" />
  </div>
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

<div class="recommendation box border">
  <h3>Should I watch this?</h3>
  <p>{movie.recommendation.emoji} {movie.recommendation.text}</p>
</div>
