
<script>
  import Grid from "gridjs-svelte";
  export let data; 
</script>

<div class="py-6 px-3 my-4 border-slate-200 rounded-lg border-2 bg-white">
    <Grid
      style={{
        container: {
          boxShadow: "0px 0px 0px 0px",
          border: "none",
        },
        table: {
          border: "none",
        },
      }}
      data={data.counts}
      search={true}
      sort={true}
      pagination={{ limit: 10, summary: false }}
    />
  </div>