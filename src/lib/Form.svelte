<script>
  import Input from "./Input.svelte";
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
    }, 500); // don't love this, but struggling to keep grid from scrolling into view before Grid component has mounted
  };
</script>

{#if showErrorModal}
  <ErrorModal {error} on:modal-close={() => (showErrorModal = false)} />
{/if}

<div class="bg-gradient-to-r h-48 w-full from-indigo-500 to-cyan-500 " />

<div class="my-11 mx-10 grid gap-10 lg:grid-flow-col lg:auto-cols-[.5fr_3fr]">
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

    {#if showTable}
      <!-- <div bind:this={grid} class= {`${!showTable ? 'hidden' : 'w-full px-10 mx-auto'}`}> -->
      <div bind:this={grid} class="w-full px-10 mx-auto">
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
