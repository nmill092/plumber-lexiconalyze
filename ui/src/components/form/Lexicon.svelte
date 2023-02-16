<script>
  export let options; 
</script>


<div class="py-6 px-3 my-4 border-slate-200 rounded-lg border-2 bg-white">
    <h3 class="text-slate-800 text-xl font-bold">
      Choose a sentiment lexicon 📚
    </h3>
    <p class="my-6">
      There are many different methods and lexicons that can be used to
      evaluate the sentiment of a text. Here you can choose between four
      popular sentiment lexicons and compare the results. Which do you
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