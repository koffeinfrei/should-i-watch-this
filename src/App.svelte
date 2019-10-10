<script>
  import Result from './Result.svelte';
  import Error from './Error.svelte';
  import Spinner from './Spinner.svelte';

  let title = '';
  let promise;

  function handleClick() {
    promise = fetchMovie();
  }

  async function fetchMovie() {
    if (!title) {
      return { error: 'Hmm? I think you forgot to enter the movie title.' };
    }

    const url = 'http://openfaas.koffeinfrei.org:31112/function/should-i-watch-this-www';

    const response = await fetch(url, {
      method: 'POST',
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/x-www-form-urlencoded',
        'X-Auth-Token': ''
      },
      body: title
    });
    return await response.json();
  }
</script>

<style>
main {
  margin: 0 auto;
  max-width: 800px;
}

.center {
  text-align: center;
}

.box {
  margin-bottom: 53px;
}

.footer {
  margin-bottom: 8px;
}

</style>

<main>
  <section class="center box">
    <input bind:value={title} placeholder="Enter the movie title">
    <button on:click={handleClick}>Lookup</button>
  </section>

  <section class="box">
    {#await promise}
      <section class="center box">
        <Spinner />
      </section>
    {:then result}
      {#if result}
        {#if result.error}
          <Error text={result.error} />
        {:else}
          <Result movie={result} />
        {/if}
      {/if}
    {:catch error}
      <Error text={error.message} />
    {/await}
  </section>

  <section class="center footer">
    Made with ☕️  by <a href="https://www.koffeinfrei.org" target="_blank">Koffeinfrei ⭧</a>
  </section>
</main>
