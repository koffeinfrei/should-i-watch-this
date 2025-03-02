<script>
  import Footer from "../components/Footer.svelte";
  import "../app.css";
</script>

<main>
  <section class="box">
    <slot />
  </section>
</main>

<Footer />

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
