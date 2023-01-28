<script>
  import { afterUpdate } from "svelte";
  import ErrorModal from "./ErrorModal.svelte";
  import Header from "./Header.svelte";
  import Intro from "./Intro.svelte";
  import Form from "./Form.svelte";
  import Results from "./Results.svelte";
  import Sidebar from "./Sidebar.svelte";

  let rows;
  let showErrorModal = false;
  let error;
  let results;
  let lexicon;
  let showTable = false;
  let handleSubmit;
</script>

{#if showErrorModal}
  <ErrorModal {error} on:modal-close={() => (showErrorModal = false)} />
{/if}

<Header />
<div class="my-11 mx-10 grid gap-5 lg:grid-flow-col lg:auto-cols-[1fr_3fr]">
  <Sidebar />
  <div class="grid gap-5 grid-cols-1">
    <Intro />
    <main class=" bg-slate-50 rounded-md shadow-md">
      <Form
        bind:lexicon
        bind:rows
        bind:showTable
        {handleSubmit}
        on:servererror={(e) => {
          showErrorModal = true;
          error = e.detail.text;
        }}
      />
      <Results {lexicon} bind:showTable bind:rows bind:results />
    </main>
  </div>
</div>

<style>
</style>
