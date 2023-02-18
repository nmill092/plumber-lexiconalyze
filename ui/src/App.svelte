<script>
  import 'tippy.js/dist/tippy.css';
  import Main from "./components/Main.svelte";
</script>

<main>
<Main/>
</main>

<style global lang="postcss">
  @import url('https://fonts.googleapis.com/css2?family=Roboto+Slab:wght@100;200;300;400;500;600;700;800;900&display=swap&family=Catamaran:wght@100;200;300;400;500;600;700;800;900');
  @import "https://cdn.jsdelivr.net/npm/gridjs/dist/theme/mermaid.min.css";

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