library(plumber)
library(dotenv)

pr_run(pr("api/api.R"), port=Sys.getenv("API_PORT"))
