<script>
  import Fa from "svelte-fa"; 

  import { faGithub } from "@fortawesome/free-brands-svg-icons";
</script>

<div class="p-8 bg-slate-50 rounded-md shadow-md">
  <h3 class="text-2xl font-roboto font-bold">Welcome to lexiconalyze! </h3>
    <p class="mt-4">
        This is a simple tool that helps you evaluate the sentiment of one or more pieces of text using <a class="font-bold text-indigo-700 decoration-0" href="https://www.knime.com/blog/lexicon-based-sentiment-analysis" target="_blank" rel="noreferrer">lexicon-based sentiment analysis</a>. 
    </p>

    <p class="mt-4"><span class="font-bold">How it works:</span> First, we clean your texts by removing common filler words, numbers, and punctuation. Then we use your chosen sentiment lexicon to categorize each word of your text. You'll then see the results visualized in a chart and a table.</p>

    <p class="mt-4">Get started by pasting your texts into the section below.</p>

    <div class="mr-auto mt-6 flex justify-start ">
      <a href="#">
    <div class="bg-white px-3 py-1 rounded shadow-md">
      <Fa icon={faGithub} size="lg" class="inline" title="Github"/> &nbsp;View on Github
    </div>
    </a>
    </div>

  </div>

  