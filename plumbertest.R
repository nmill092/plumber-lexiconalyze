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
  print(wordcloud::wordcloud(wordcloud_df$word,freq=wordcloud_df$freq,colors=RColorBrewer::brewer.pal(6,"Spectral")))
  wordcloud <- wordcloud2(wordcloud_df,fontFamily = "Helvetica",color = "random-dark")
  saveWidget(wordcloud, "./wordcloud.html", selfcontained = F)
}



#* @filter cors
cors <- function(req, res) {
  res$setHeader("Access-Control-Allow-Origin", "*")
  
  if (req$REQUEST_METHOD %in% c("OPTIONS")) {
    res$setHeader("Access-Control-Allow-Methods", "*")
    res$setHeader("Access-Control-Allow-Headers",
                  req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
    res$status <- 200
    return(list())
  } else {
    plumber::forward()
  }
}

#* @assets .
list()

#* Return all lexicons
#* @get /lexicons
function() {
  names(lexicons)
}

#* @post /form
#* @serializer unboxedJSON
#* @parser json
function(req, res) {
  print(req$REQUEST_METHOD)
  
  calculate_sentiment(.stops = req$body$stops, .corpus = req$body$corpus, .lexicon = req$body$lexicon)
}