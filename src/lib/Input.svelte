<script>
  import { createEventDispatcher } from "svelte";
  import Fa from "../../node_modules/svelte-fa";
  import {faTrash, faAdd } from "../../node_modules/@fortawesome/free-solid-svg-icons";
  import tooltip from './tooltip.js'
  export let value;
  export let id;
  export let disabled;
  export let showAdd;

  const dispatch = createEventDispatcher();

  const getWordCount = (words) => {
    if (!words) return 0;
    return words.split(/\s|\./).filter((i) => i.length > 0).length;
  };

  const getCharCount = (words) => {
    if (!words) return 0;
    return words.replace(" ", "").length;
  };
</script>

<textarea
  bind:value
  rows="5"
  placeholder="Enter a few lines of text"
  class="appearance-none flex-1 focus:outline-none focus:border-sky-500 focus:ring-3 focus:ring-sky-500 transform transition focus:shadow-sm p-3 border-slate-200 d rounded-lg border-2 w-full"
/>

<div class="flex gap-5 items-center">
  <span class="text-indigo-600 block font-light flex-1"
    >{getWordCount(value)} words {getCharCount(value)} characters</span
  >

  <button
    title="Delete item"
    use:tooltip
    {disabled}
    class="appearance-none disabled:bg-slate-600 cursor-pointer bg-rose-600 hover:bg-rose-400 hover:scale-105 text-white block transition transform rounded-sm hover:shadow-lg uppercase px-4 py-3"
    on:click|preventDefault={() => dispatch("textdelete", { id: id })}
  >
    <Fa icon={faTrash} color="white" title="Delete" />
  </button>

 {#if showAdd}
  <button 
        title="Add item below"
        use:tooltip
        class="appearance-none font-bold cursor-pointer bg-green-600 hover:bg-green-400 hover:scale-105 text-white block transition transform rounded-sm hover:shadow-lg uppercase px-4 py-3"
        on:click|preventDefault={() => dispatch("addField")}> <Fa icon={faAdd} color="white" title="Delete"/>    </button>
  {/if}

</div>

<style>
  
</style>
