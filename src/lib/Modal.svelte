<script>
    import { createEventDispatcher } from "svelte";
    import { fly, fade } from "svelte/transition";
    
    let container;
    let modal;
  
    const dispatch = createEventDispatcher();
  
    function handleClick(e) {
      if (
        (e instanceof KeyboardEvent && e.key === "Escape") ||
        (e instanceof PointerEvent && !modal.contains(e.target))
      ) {
        dispatch("modal-close");
      }
    }
  </script>
  
  <div
    in:fade
    out:fade
    bind:this={container}
    class="modal__container"
    on:click={handleClick}
    on:keydown={handleClick}
  >
    <div
      in:fly={{ y: -200, duration: 500 }}
      out:fly={{ y: -200, duration: 500 }}
      id="modal"
      bind:this={modal}
      on:keydown={handleClick}
      on:click={handleClick}
    >
      <div class="modal__body">
        <h2 class="mb-5 text-center	text-rose-600 font-bold text-xl">
          <slot name="modal-header"></slot>
        </h2>
       <div>
         <slot name="modal-body"></slot>
       </div>
        <button
          class="mt-5 btn btn-blue"
          on:click={() => {
            dispatch("modal-close");
          }}
        >
          Close
        </button>
      </div>
    </div>
  </div>
  
  <style>
    #modal {
      min-width: 600px;  
      padding: 10px;
      background-color: white;
      border-radius: 10px;
      box-shadow: 10px 10px 10px rgba(0, 0, 0, 0.1);
    }
  
    .modal__container {
      height: 100vh;
      width: 100vw;
      background-color: rgba(0, 0, 0, 0.5);
      display: flex;
      justify-content: center;
      align-items: center;
      position: fixed;
      z-index: 1;
    }
    .modal__body {
      width: 100%;
      display: flex;
      padding: 10px;
      justify-content: space-between;
      align-items: center;
      flex-direction: column;
    }
  </style>
  