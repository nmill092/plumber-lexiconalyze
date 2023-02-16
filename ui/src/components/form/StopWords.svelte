<script>
      import MultiSelect from "svelte-multiselect";
</script>

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
      > are words that appear frequently in most texts but carry little or no significance ("and", "the", "of", and so on). All of the most common
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