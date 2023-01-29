<script>
    import Modal from "./Modal.svelte";
    export let showWordcloudModal; 

    let iframe; 
</script>

<Modal on:modal-close={() => (showWordcloudModal = false)}>
    <span slot="modal-header">Wordcloud</span>
    <span slot="modal-body">
        <iframe src="http://localhost:8000/public/wordcloud.html" style="padding:1.5rem" width="500" height="500" title="Wordcloud"/>
    </span>
</Modal>