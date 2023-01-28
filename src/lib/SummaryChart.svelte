<script>
  import { chart } from "svelte-apexcharts";

  export let data;
  export let words;
  
  $: options = {
    series: [
      {
        data: data.map((datum) => datum.pct.toFixed(2)),
      },
    ],
    chart: {
      type: "bar",
      height: "600px",
    },
    
    dataLabels: {
      enabled: true,
      formatter: function (val, opts) {
        return val + "%";
      },
    },
    xaxis: {
      categories: data.map((datum) => datum.sentiment),
    },
    tooltip: {
      custom: function ({ series, seriesIndex, dataPointIndex, w }) {
        let sentiment = w.globals.labels[dataPointIndex];
        let list = words.filter((word) => word.sentiment === sentiment);
        return `<div>
                 <h2 class='font-bold'>Top <span class='text-transparent bg-clip-text bg-gradient-to-r from-indigo-500 to-red-600'>${sentiment}</span> words:</h2> 
                 <ul class='mt-4'>
                    ${list
                      .map((word) => `<li class=>${word.term}</li>`)
                      .slice(0, 5)
                      .join("")} 
                </ul>
            </div>`;
      },
    },
    plotOptions: {
      bar: {
        borderRadius: 4,
        horizontal: true,
        colors: {
          ranges: [
            {
              from: "red",
              to: "blue",
              color: undefined,
            },
          ],
        },
      },
    },
  }
</script>

<div class="mb-10" use:chart={options} />
<style>
</style>
