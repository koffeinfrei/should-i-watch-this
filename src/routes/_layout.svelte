<script>
  import Footer from '../components/Footer.svelte';

  export let segment;
</script>

<style>
main {
  margin: 0 auto;
  margin-bottom: 53px;
}

@media (min-width: 800px) {
  main {
    width: 800px;
  }
}
</style>

<main>
  <section class="box">
    <slot></slot>
  </section>
</main>

<Footer />
