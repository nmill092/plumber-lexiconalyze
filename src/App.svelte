<script>
    import 'tippy.js/dist/tippy.css';

  import Form from "./lib/Form.svelte";
</script>

<main>
<Form/>
</main>

<style global lang="postcss">
  @import url('https://fonts.googleapis.com/css2?family=Catamaran:wght@100;200;300;400;500;600;700;800;900&family=Lora:ital,wght@0,400;0,500;0,600;0,700;1,400;1,500;1,600;1,700&display=swap');
  @tailwind base;
  @tailwind components;
  @tailwind utilities;

  :global(body) { 
    @apply bg-indigo-50;
    scroll-behavior: smooth;
  }

  :global(.apexcharts-tooltip) {
    padding: 1.3rem; 
  }

  :global(.gridjs-footer) {
    box-shadow: 0px 0px 0px 0px; 
    border-bottom: 1px; 
  }

  :global(.gridjs-wrapper) {
    border-top-width: 0;
    box-shadow: 0px 0px 0px 0px;
  }


</style>