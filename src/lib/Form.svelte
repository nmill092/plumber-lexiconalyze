<script>
  import Input from "./Input.svelte";
  import SummaryChart from "./SummaryChart.svelte";
  import { fly, fade, slide } from "svelte/transition";
  import Grid from "gridjs-svelte";
  import Main from "./Main.svelte";
  import ErrorModal from "./ErrorModal.svelte";

  let shown = true;
  let rows;
  let showErrorModal = false;
  let error;
  let grid;
  let showTable = false;
  let handleSubmit;

  const scrollGridIntoView = () => {
    setTimeout(() => {
      grid.scrollIntoView({ block: "end", behavior: "smooth" });
    }, 100); // don't love this, but struggling to keep grid from scrolling into view before Grid component has mounted
  };
</script>


{#if showErrorModal}
  <ErrorModal {error} on:modal-close={() => (showErrorModal = false)} />
{/if}

<div class="bg-gradient-to-r h-48 w-full from-indigo-500 to-cyan-500 " />

<div class="my-11 mx-10 grid gap-10 lg:grid-flow-col lg:auto-cols-[1fr_3fr]">
  {#if shown}
    <div
      in:fly={{ x: -200 }}
      out:fly={{ x: -200 }}
      class="mb-0 p-8 bg-slate-50 rounded-md shadow-md"
    />
  {/if}

  <main in:slide class=" bg-slate-50 rounded-md shadow-md">
    <Main
      bind:rows
      bind:showTable
      on:submitted={scrollGridIntoView}
      {handleSubmit}
      on:servererror={(e) => {
        showErrorModal = true;
        error = e.detail.text;
      }}
    />

    
    <h2 class="text-3xl mx-10 font-josefin">Results</h2>

    {#if showTable}
      {#if rows.counts.length === 0}
      <div class='py-6 mx-10 px-3 my-4 border-slate-200 rounded-lg border-2 bg-white'>
        <h2 class="text-center font-bold text-lg">No results to display!</h2>
        <p class="text-center font-light">This could have happened because your corpus wasn't large enough to analyze. Try using a different sentiment library or entering more or longer texts.</p>
      </div>
    
      {:else}  

      <div id="result" bind:this={grid} class="w-full px-10 mx-auto grid grid-cols-1 xl:grid-cols-2 gap-4">
        
        <div class='py-6 px-3 my-4 border-slate-200 rounded-lg border-2 bg-white'>
          <SummaryChart data={rows.summary} words={rows.counts}/>
        </div>
      
        <div class='py-6 px-3 my-4 border-slate-200 rounded-lg border-2 bg-white'>
          <Grid
          style ={
          { container: {
           boxShadow: '0px 0px 0px 0px',
           border: 'none'
           }, table: {
       border: 'none'
           }}
          }
           data={rows.counts}
           search={true}
           sort={true}
           pagination={{ limit: 10, summary: false }}
         />
        </div>
      </div>
      {/if}
  {/if}
  </main>
</div>

<style>
  @import "https://cdn.jsdelivr.net/npm/gridjs/dist/theme/mermaid.min.css";
</style>
