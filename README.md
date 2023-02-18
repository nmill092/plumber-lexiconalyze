# lexiconalyze

This app was created to demonstrate the process of building an API using R's [Plumber framework](https://www.rplumber.io/) and consuming it with a JavaScript front end.  

The Svelte front end is deployed at [nmill092.github.io/plumber-lexiconalyze](https://nmill092.github.io/plumber-lexiconalyze/). The API has been deployed onto a DigitalOcean droplet with the help of the R package `plumberDeploy`. 

To run the app locally, you will first run the API and then point your front end at it.

## Running the API

Change your working directory to `api/`. 

Install the `plumber` package by running `install.packages("plumber")` in an R console.  Open `plumber.R`. If using RStudio, you can run the API by clicking "Run API" at the top of your editor window. Otherwise, you can run the API programmatically using the following command: `plumber::plumb("plumber.R") %>% plumber::pr_run()`. Optionally, you can add a `port` argument to specify a port on which the API should listen for requests. Otherwise, Plumber will randomly select an open port. See `?pr_run` for more details. 

Once the API starts, check your R console and make note of the API's base URL (**127.0.0.1:xxxx** aka **localhost:xxxx**). You can test the API using the Swagger UI, Postman, cURL, or another tool.

## Running the front end 

Change your working directory to `ui/`. 

**IMPORTANT STEP**: At the root of `ui/`, create a `.env` file and add your API's base URL as follows (no curly braces): 

``` 
VITE_API_BASE={YOUR API BASE URL GOES HERE}
```

Make sure your working directory is set to `ui/`; then open a terminal and run `npm install && npm run dev`.
