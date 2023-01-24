<script>
  import Input from "./Input.svelte";
  import { fly, fade, slide } from "svelte/transition";
  import Grid from "gridjs-svelte"; 
  import Main from "./Main.svelte";
  import ErrorModal from "./ErrorModal.svelte";

  let submitted = true;
  let rows;
  let showErrorModal = false; 
  let error; 

</script>

{#if showErrorModal}
<ErrorModal error={error} on:modal-close={()=> showErrorModal=false}/>
{/if}

<div class="bg-gradient-to-r h-48 from-indigo-500 to-cyan-500 " />

<button on:click={() => (submitted = !submitted)}>CLick me</button>

<div
  class="my-11 mx-10 grid gap-10 lg:grid-flow-col md:auto-cols-[1fr_3fr]"
>
  {#if submitted}
    <div
      in:fly={{ x: -200 }}
      out:fly={{ x: -200 }}
      class="mb-0 p-8 bg-slate-50 rounded-md shadow-md">
    </div>
  {/if}
  <main in:slide class=" bg-slate-50 rounded-md shadow-md">
    <Main bind:rows={rows} on:servererror={(e) => {showErrorModal = true; error=e.detail.text }}/>

    {#if rows}
      <div class="w-full px-10 mx-auto">
        <Grid
          data={rows}
          style={{ width: "100%" }}
          search={true}
          sort={true}
          pagination={{ limit: 10, summary: false }}
        />
      </div>
    {/if}
  </main>
</div>

<style>
  @import "https://cdn.jsdelivr.net/npm/gridjs/dist/theme/mermaid.min.css";
</style>
