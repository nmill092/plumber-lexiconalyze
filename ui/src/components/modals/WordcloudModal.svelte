<script>
import Modal from "./Modal.svelte";
import axios from 'axios';
import { onMount } from "svelte";
    export let showWordcloudModal; 
    let wordcloudSrc; 

    onMount(() => { 
        axios.get(`http://localhost:${import.meta.env.VITE_API_PORT}/wordcloud`, {responseType: "blob"})
            .then((res) => { 
                wordcloudSrc = URL.createObjectURL(res.data); 
            })
    })

</script>

<Modal on:modal-close={() => (showWordcloudModal = false)}>
    <span slot="modal-header">Word Cloud <a class="text-sm bg-rose-500 p-2 text-white rounded-lg" target="_blank" rel="noreferrer" on:click={() => window.open(wordcloudSrc, "_blank")} href="#">Open in separate window</a></span>
    <span slot="modal-body">
        {#if wordcloudSrc}
        <img src={wordcloudSrc} alt="Sentiment word cloud"/>
        {:else}
        <p>Loading word cloud...</p>
        {/if}
    </span>
</Modal>