
<script>

  import { createEventDispatcher } from "svelte";
  import { flip } from "svelte/animate";
  import { fly, fade, slide } from "svelte/transition";
  import axios from "axios";
  import MultiSelect from "svelte-multiselect";
  import Input from "./Input.svelte";


  let idCounter = 0;
  let texts = [{ id: 0, val: "" }];
  export let rows;  // will be populated with api response data

  const dispatch = createEventDispatcher();

  const addField = () => {
    idCounter++;
    texts = [...texts, { id: idCounter, val: "" }];
  };

  const removeField = (idToDelete) => {
    texts = texts.filter((i) => i.id != idToDelete);
  };

  const handleSubmit = async (e) => {
    let corpuses = texts.map((text) => text.val);

    const form = new FormData(e.target);
    form.set("corpus", JSON.stringify(corpuses));
    const obj = Object.fromEntries(form.entries());

    try {
      const res = await axios.post("http://localhost:8000/form", obj);
      rows = res.data.counts;
    } catch (err) {
        
      dispatch("servererror", {
        text: err.code==="ERR_BAD_RESPONSE" 
                ? "Sorry mate, the server had an issue processing your request 😢 Please try again or visit this page later."
                : "It appears that the server is offline 😔 Please try again later."
      });
    }
  };
</script>

<form on:submit|preventDefault={handleSubmit} class="w-full">
    <div class="px-8 py-6 my-4">
      <div class="flex flex-col gap-3 content-center">
      {#each texts as text, i (text.id)}
        <div class="flex-[1_0_auto]" in:fade out:fly animate:flip="{{duration: 200}}">
          <Input 
              on:textdelete={(e) => removeField(e.detail.id)} 
              on:addField={addField} 
              bind:value={texts[i].val}
              disabled={texts.length === 1}
              showAdd={texts[texts.length-1].id === text.id}
              id={text.id}/>
        </div>
      {/each}
      </div>

      <button
        type="submit"
        class="appearance-none font-bold tracking-wider cursor-pointer bg-indigo-600 text-white block my-5 transition transform rounded-sm hover:shadow-lg uppercase px-4 py-3"
        >Submit</button
      >
    </div>

    <div class="px-8 py-6 my-4">
      <MultiSelect
        name="stops"
        allowUserOptions={true}
        id="languages"
        options={["apple", "plum", "pear"]}
        placeholder="What languages do you know?"
      />
    </div>

    <div class="px-8 py-6 my-4">
      <select
        name="lexicon"
        class="appearance-none w-52 px-3 py-4 bg-white rounded-md"
      >
        <option value="afinn">AFINN</option>
        <option value="nrc">NRC</option>
        <option value="bing">Bing</option>
      </select>
    </div>
  </form>