# install.packages("pacman")
pacman::p_load("plumber", "tidyverse", "jsonlite", "tm", "tidytext", "readr", "wordcloud2", "RColorBrewer", "htmlwidgets")

# the below objects will be initialized once when our server starts

labMT <- read_delim("labMT2english.csv",delim = "\t") %>% rename("value" = "happs")

lexicons <- list("AFINN" = get_sentiments("afinn"), 
                 "NRC" = get_sentiments("nrc"), 
                 "Bing" = get_sentiments("bing"), 
                 "Mechanical Turk (LabMT)" = labMT)

calculate_sentiment <- function(.stops, .corpus, .lexicon) {
  
  custom_stops <- unlist(str_split(trimws(gsub("[[:punct:]]", " ", .stops)), "\\s+"))
  
  corpus <- Corpus(VectorSource(fromJSON(.corpus)))
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <-
    tm_map(corpus, content_transformer(function(x)
      gsub(pattern = "[[:punct:]]",
        replacement = "",
        x = x)))
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, stripWhitespace)
  corpus <- tm_map(corpus, removeWords, c(custom_stops, stop_words$word))
  corpus <- DocumentTermMatrix(corpus)
  
  lexicon <- .lexicon
  lexicon_df <- data.frame(lexicons[[lexicon]])
  counts <- NULL
  
  if (!lexicon %in% c("AFINN", "Mechanical Turk (LabMT)")) {
    counts <- tidy(corpus) %>%
      inner_join(lexicon_df, by = c(term = "word")) %>%
      group_by(term, sentiment) %>%
      summarise(count = sum(count, na.rm = T)) %>%
      arrange(desc(count))
    
    summary <- counts %>%
      group_by(sentiment) %>%
      summarise(raw = sum(count, na.rm = T)) %>%
      mutate(pct = raw / sum(raw) * 100) %>%
      arrange(desc(pct))
    
    saveWordcloud(tidy(corpus)) 
    
    return(list(counts = counts, summary = summary))
    
  } else {
    counts <- tidy(corpus) %>%
      group_by(term) %>%
      summarise(count = sum(count, na.rm = T)) %>%
      inner_join(lexicon_df, by = c(term = "word"))
    
    summary <- counts %>%
      mutate(weighted_value = count * value)
    
    weighted_sentiment <-
      round(weighted.mean(x = summary$value, w = summary$count), 2)
    
    saveWordcloud(tidy(corpus)) 
    
    return(list(counts = counts, summary = summary, weighted_sentiment = weighted_sentiment))
  }
}


saveWordcloud <- function(counts) {
  wordcloud_df <- counts %>% rename("word" = "term", "freq" = "count") %>% select(word,freq)
  wordcloud <- wordcloud2(wordcloud_df,fontFamily = "Helvetica",color = "random-dark",)
  saveWidget(wordcloud, "./wordcloud.html", selfcontained = F)
}

#* @assets .
list()

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
  calculate_sentiment(.stops = req$body$stops, .corpus = req$body$corpus, .lexicon = req$body$lexicon)
}

#* @get /wordcloud
#* @serializer html
function(req, res) {
  read_file_raw("./wordcloud.html")
}