<script>
  import SummaryChart from "./SummaryChart.svelte";
  import GaugeChart from "./GaugeChart.svelte";
  export let lexicon;
  export let data;
</script>

<div class="py-6 px-5 my-4 border-slate-200 rounded-lg border-2 bg-white">
  {#if lexicon !== "AFINN" && lexicon !== "Mechanical Turk (LabMT)"}
    <SummaryChart data={data.summary} words={data.counts} />
  {:else}
    <GaugeChart {lexicon} data={data.weighted_sentiment} />

    <p class="text-lg mb-10">
      The {lexicon} weighted average sentiment of your text corpus is
      <strong class="text-indigo-800">{data.weighted_sentiment}</strong>
      on a scale from
      {lexicon === "AFINN"
        ? "-5 to 5, with -5 being the most negative and 5 being the most positive."
        : "1.3 to 8.5, with 1.3 being the most negative and 8.5 being the most positive."}
    </p>
  {/if}

  <p class="text-lg">
    Remember that this is just an estimation based on the classification of each
    word in your corpus according to your selected sentiment library. View the raw sentiment data in the table <span class="inline xl:hidden">below</span><span class="hidden xl:inline">on the right</span>.
  </p>
</div>
