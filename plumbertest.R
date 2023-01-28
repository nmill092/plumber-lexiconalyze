install.packages("pacman")
pacman::p_load("plumber", "tidyverse", "jsonlite", "tm", "tidytext", "readr", "wordcloud2", "RColorBrewer")

labMT <- read_delim("labMT2english.csv",delim = "\t") %>% rename("value" = "happs")

lexicons <- list("AFINN" = get_sentiments("afinn"), 
                 "NRC" = get_sentiments("nrc"), 
                 "Bing" = get_sentiments("bing"), 
                 "Mechanical Turk (LabMT)" = labMT)

#* @filter cors
cors <- function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$setHeader("Access-Control-Allow-Methods", "*")
    res$setHeader("Access-Control-Allow-Headers",
                  req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
    res$status <- 200
    return(list())
  } else {
    plumber::forward()
  }
}

#* Return all lexicons
#* @get /lexicons
function() {
  names(lexicons)
}

#* @get /date
#* @serializer unboxedJSON
#* @param start
#* @param method
#* @param number
#* @param units
function(req, res, start, method, number, units) {
  tryCatch({
    date <-
      lubridate::parse_date_time(start, orders = c("mdy", "dmy", "ymd"))
    
    fn <- switch(
      units,
      "days" = lubridate::days,
      "weeks" = lubridate::weeks,
      "months" = lubridate::dmonths,
      "years" = lubridate::years
    )
    
    result <- switch(
      method,
      "add" = date + fn(as.numeric(number)),
      "subtract" = date - fn(as.numeric(number))
    )
    
    if (is.na(date) || is.null(fn) || is.null(result))
      stop()
    
    formatted_result <- format(result, "%B %m, %Y")
    
    list(
      start_date = start,
      parsed_date = date,
      operation = paste(method, number, units),
      result_date = formatted_result
    )
  }, error = function(x) {
    list(error = "Server failed to handle your request due to missing or invalid parameters.")
  })
}

#* @post /form
#* @serializer unboxedJSON
#* @parser json
function(req, res) {
  cw <-
    unlist(str_split(trimws(
      gsub("[[:punct:]]", " ", req$body$stops)
    ), "\\s+"))
  
  corp <- Corpus(VectorSource(fromJSON(req$body$corpus)))
  corp <- tm_map(corp, content_transformer(tolower))
  corp <-
    tm_map(corp, content_transformer(function(x)
      gsub(
        pattern = "[[:punct:]]",
        replacement = "",
        x = x
      )))
  corp <- tm_map(corp, removePunctuation)
  corp <- tm_map(corp, stripWhitespace)
  corp <- tm_map(corp, removeWords, c("”", "“", cw, stop_words$word))
  corp <- DocumentTermMatrix(corp)
  
  lexicon <- req$body$lexicon
  lexicon_df <- data.frame(lexicons[[lexicon]])
  
  if (!lexicon %in% c("AFINN", "Mechanical Turk (LabMT)")) {
    counts <- tidy(corp) %>%
      inner_join(lexicon_df, by = c(term = "word")) %>%
      group_by(term, sentiment) %>%
      summarise(count = sum(count, na.rm = T)) %>%
      arrange(desc(count))
    
    summary <- counts %>%
      group_by(sentiment) %>%
      summarise(raw = sum(count, na.rm = T)) %>%
      mutate(pct = raw / sum(raw) * 100) %>%
      arrange(desc(pct))
    
    list(counts = counts,
         summary = summary)
    
  } else {
    counts <- tidy(corp) %>%
      group_by(term) %>%
      summarise(count = sum(count, na.rm = T)) %>%
      inner_join(lexicon_df, by = c(term = "word"))
    
    summary <- counts %>%
      mutate(weightedVal = count * value)
    
    weighted_sentiment <-
      round(weighted.mean(x = summary$value, w = summary$count), 2)
    
    list(
      counts = counts,
      summary = summary,
      weighted_sentiment = weighted_sentiment
    )
  }
}