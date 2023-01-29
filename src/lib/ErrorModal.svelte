<script>
import Modal from "./Modal.svelte";
export let error = "Something went wrong!";
export let showErrorModal; 
</script>


<Modal on:modal-close={() => (showErrorModal = false)}>
	<span slot="modal-header">Something went wrong!</span>
	<p slot="modal-body" class="text-center"> {error}</p>
</Modal> 
