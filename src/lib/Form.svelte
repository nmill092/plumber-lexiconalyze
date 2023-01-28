<script>
  import axios from "axios";
  import { onMount, createEventDispatcher } from "svelte";
  import MultiSelect from "svelte-multiselect";
  import { flip } from "svelte/animate";
  import { fade, fly } from "svelte/transition";
  import Input from "./Input.svelte";

  export let lexicon; 
  export let rows; // will be populated with api response data
  export let showTable = false;

  let form; 
  let texts = [{ id: 0, val: "" }];
  let idCounter = 0;
  let options = []; 

  onMount(() => {
    axios.get("http://localhost:8000/lexicons")
        .then(res => {
          options = res.data; 
        })
  })

  const dispatch = createEventDispatcher();

  const addField = () => {
    idCounter++;
    texts = [...texts, { id: idCounter, val: "" }];
  };

  const removeField = (idToDelete) => {
    texts = texts.filter((i) => i.id != idToDelete);
  };
 
  export let handleSubmit = async (e) => {
    let corpus = texts.map((text) => text.val);
    const formData = new FormData(e.target);
    formData.set("corpus", JSON.stringify(corpus));
    const formObj = Object.fromEntries(formData.entries());    
    console.log(formObj)


    try {
      const res = await axios.post("http://localhost:8000/form", formObj);
      rows = res.data;
      showTable = true;
      lexicon = formObj.lexicon; 
      dispatch("submitted");
    } catch (err) {
      alert(err);
      dispatch("servererror", {
        text:
          err.code === "ERR_BAD_RESPONSE"
            ? "Sorry mate, the server had an issue processing your request 😢 Please try again or visit this page later."
            : "It looks like the server is offline 😔 Please try again later.",
      });
    }
  };

  const resetAll = () => { 
    texts = [{ id: 0, val: "" }]; 
    lexicon = ''; 
    window.scrollTo(0,0); 
    showTable=false; 
  }
</script>

<form on:submit|preventDefault={handleSubmit} bind:this={form} class="w-full">
  <div class="px-8 py-6 my-4">
    <h2 class="text-3xl my-4 font-roboto">Build your corpus</h2>
    <div class="my-6">
      <p class="mb-3">A <strong>corpus</strong> is a collection of texts that forms the basis of a. A text can be as short as a tweet or as long as a novel.</p> 
      <p>Use the fields below to add your texts one-by-one. You can also submit a single text. You should aim to enter a total of at least a few sentences; otherwise, there won't be enough data to analyze your text.</p>
    </div>
     <div class="flex flex-col gap-3 content-center">
      {#each texts as text, i (text.id)}
        <div
          class="flex-[1_0_auto]"
          in:fade
          out:fly
          animate:flip={{ duration: 200 }}
        >
          <Input
            on:textdelete={(e) => removeField(e.detail.id)}
            on:addField={addField}
            bind:value={texts[i].val}
            disabled={texts.length === 1}
            showAdd={texts[texts.length - 1].id === text.id}
            id={text.id}
          />
        </div>
      {/each}
    </div>

    <hr class="my-8" />
    <h2 class="text-3xl font-roboto">Customize your analysis</h2>

    <div class="grid gap-2 grid-cols-1 lg:grid-cols-2">
      <div class="px-3 my-4 py-5 border-slate-200 rounded-lg border-2 bg-white">
        <h3 class="text-slate-800 text-xl font-markazi font-bold">
          Get rid of stop words 🛑
        </h3>
        <p class="my-6">
          <a
            class="font-bold text-indigo-700 decoration-0"
            href="https://github.com/igorbrigadir/stopwords"
            target="_blank"
            rel="noreferrer">Stop words</a
          > are words that appear frequently in most texts but carry little or no
          lexical significance ("and", "the", "of", and so on). All of the most common
          stop words will be filtered out of your text automatically, but you can
          enter additional custom stop words below.
        </p>
        <MultiSelect
          --sms-padding={".75rem 1rem"}
          outerDivClass={"px-3 py-2 bg-white rounded-lg border-slate-200 border-2"}
          name="stops"
          allowUserOptions={true}
          createOptionMsg={"Add this stop word"}
          id="languages"
          options={[]}
          placeholder="Enter your custom stop words here."
        />
      </div>

      <div class="py-6 px-3 my-4 border-slate-200 rounded-lg border-2 bg-white">
        <h3 class="text-slate-800 text-xl font-bold">
          Choose a sentiment library 📚
        </h3>
        <p class="my-6">
          There are many different methods and libraries that can be used to
          evaluate the sentiment of a text. Here you can choose between three
          popular sentiment libraries and compare the results. Which do you
          think most accurately gauges the sentiment of your texts?
        </p>
        <select
          id="sentiment" name="lexicon" class="w-full px-3 p py-2 bg-white rounded-lg border-slate-200 border-2">
          <option disabled value="" selected>Choose a sentiment library</option>
          {#each options as option}
            <option value={option}>{option}</option>
          {/each}
        </select>
      </div>
    </div>

    <button
      disabled='{lexicon==='' || texts[0].val.length===0}'
      type="submit"
      class="m-auto font-bold disabled:bg-slate-700 transition tracking-wider cursor-pointer bg-indigo-600 text-white block my-5 transform rounded-lg lg:w-1/2 w-full hover:shadow-lg uppercase px-4 py-3"
      >Submit</button
    >

    <button on:click|preventDefault={resetAll}>Reset</button>
  </div>
</form>
