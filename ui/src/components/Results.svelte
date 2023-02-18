<script>
 import { afterUpdate } from "svelte";
 export let showTable;
 export let data;
 export let results;
 export let lexicon; 
 export let showWordcloudModal; 
  
import Chart from "./charts/Chart.svelte";
import DataTable from "./DataTable.svelte";

afterUpdate(() => { 
    if(showTable) results.scrollIntoView({ block: "end", behavior: "smooth" });
})

</script>


<div bind:this={results}>
{#if showTable}
<h2 class="text-3xl my-4 font-roboto text-center">Results</h2>

  {#if data.counts.length === 0}
    <div
      class="py-6 mx-10 px-3 my-4 border-slate-200 rounded-lg border-2 bg-white"
    >
      <h2 class="text-center font-bold text-lg">No results to display!</h2>
      <p class="text-center font-light">
        This could have happened because your corpus wasn't large enough to
        analyze. Try using a different sentiment library or entering more or
        longer texts.
      </p>
    </div>
  {:else}
    <div
      class="w-full px-10 mx-auto grid grid-cols-1 xl:grid-cols-2 gap-4"
    >
      
    <Chart bind:showWordcloudModal {lexicon} data={data}/>
    <DataTable data={data}/>
      
    </div>
  {/if}
{/if}
</div>