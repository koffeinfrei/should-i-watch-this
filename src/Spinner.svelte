<script>
import { onDestroy } from 'svelte';

const spinnerCharacters = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];

let currentIndex = 0;
let currentCharacter;

function setCurrentCharacter() {
  currentCharacter = spinnerCharacters[currentIndex];
}

function onInterval(callback, milliseconds) {
  const interval = setInterval(callback, milliseconds);

  onDestroy(() => {
    clearInterval(interval);
  });
}

onInterval(() => {
  currentIndex = (currentIndex + 1) % spinnerCharacters.length;
  setCurrentCharacter();
}, 60);

</script>

<style>
span {
  font-size: 21px;
}
</style>

<span>{currentCharacter || ''}</span>

<svelte:head>
  <title>Should I watch this?</title>
</svelte:head>
