<script>
    import { chart } from "svelte-apexcharts";
    import { scaleLinear } from 'd3';
    export let data;
    export let lexicon; 

$: scale = lexicon === "AFINN" ? scaleLinear().domain([-5,5]).range([0,100]) : scaleLinear().domain([1.3,8.5]).range([0,100]); 

$: options = {
  chart: {
    height: 480,
    type: "radialBar",
  },
 title: { 
    text: lexicon + " Lexicon Sentiment Analysis",
    align: "center"
 }, 
  series: [scale(data)],
  fill: {
  colors: [function({ value, seriesIndex, w }) {
    let color; 
    switch(true) {
        case value < 10 : return "#EF4444";
        case value >= 10 && value <25 : return "#EA580C"; 
        case value >= 25 && value <50 : return "#F59E0B";
        case value >= 50 && value <75 : return "#14B8A6";
        case value >= 75 : return "#4ADE80";
    }
  }]
},

annotations: {
  xaxis: [
    {
      x: 56,
      borderColor: '#00E396',
      label: {
        borderColor: '#00E396',
        style: {
          color: '#fff',
          background: '#00E396'
        },
        text: 'Y-axis annotation on 8800'
      }
    }
  ]
},
  plotOptions: {
    radialBar: {
      startAngle: -90,
      endAngle: 90,
      track: {
        dropShadow: {
          enabled: true,
          blur: 4,
          opacity: 0.15
        }
      },
      dataLabels: {
        name: {
          color: "#696969",
          fontSize: "13px"
        },
        value: {
          color: "#696969",
          fontSize: "30px",
          show: true,
          formatter: function () {
                    return data.toFixed(1)
                  }
        }
      }
    }
  },
  // stroke: {
  //   lineCap: "round"
  // },
  labels: ["Weighted Score"]
};
  </script>
  
  <div class="mb-10" use:chart={options} />
  
  <style>
  </style>  