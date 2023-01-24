<script>
    import 'tippy.js/dist/tippy.css';

  import Form from "./lib/Form.svelte";
</script>

<main>
<Form/>
</main>

<style global lang="postcss">
  @tailwind base;
  @tailwind components;
  @tailwind utilities;


  :global(body) { 
    @apply bg-indigo-50;
  }
</style>