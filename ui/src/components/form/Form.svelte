<script>
  import axios from "axios";
  import { onMount, createEventDispatcher } from "svelte";
  import { flip } from "svelte/animate";
  import { fade, fly } from "svelte/transition";
  import Input from "./Input.svelte";
  import StopWords from "./StopWords.svelte";
  import Lexicon from "./Lexicon.svelte";

  export let lexicon; 
  export let rows; // will be populated with api response data
  export let showTable = false;

  let form; 
  let texts = [{ id: 0, val: "" }];
  let idCounter = 0;
  let options = []; 

  onMount(() => {
    
    axios.get(`${import.meta.env.VITE_API_BASE}/lexicons`)
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
      const res = await axios.post(`${import.meta.env.VITE_API_BASE}/analyze`, formObj);
      rows = res.data;
      showTable = true;
      lexicon = formObj.lexicon; 
      dispatch("submitted");
    } catch (err) {
      dispatch("servererror", {
        text:
          err.code === "ERR_BAD_RESPONSE"
            ? "Sorry, the server had an issue processing your request 😢 Please try again or visit this page later."
            : "It looks like the server is offline 😔 Please try again later.",
      });
    }
  };
</script>

<form on:submit|preventDefault={handleSubmit} bind:this={form} class="w-full">
  <div class="px-8 py-6 my-4">
    <h2 class="text-2xl font-bold my-4 font-roboto">Add your texts</h2>
    <div class="my-6">
      <p class="mb-3">Use the space below to add the texts you would like to analyze. For best results, texts should come from the same source or author. You should aim to enter a total of at least a few sentences; otherwise, there won't be enough data to analyze your text.
      </p> 
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
    <h2 class="text-2xl font-bold font-roboto">Customize your analysis</h2>

    <div class="grid gap-2 grid-cols-1 lg:grid-cols-2">
      
      <StopWords/> 
      <Lexicon {options}/>
      
    </div>

    <button
      disabled='{lexicon==='' || texts[0].val.length===0}'
      type="submit"
      class="border transition border-transparent disabled:hover:text-white hover:bg-white hover:border hover:border-indigo-700 hover:text-indigo-700 rounded-lg mt-5 px-4 text-center uppercase py-2 w-full bg-indigo-700
       m-auto font-bold disabled:bg-slate-700 tracking-wider cursor-pointer  text-white block my-5 transform lg:w-1/2 hover:shadow-lg"
      >Submit</button
    >



  </div>
</form>
