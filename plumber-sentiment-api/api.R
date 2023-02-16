# Setup -------------------------------------------------------------------


# install.packages("pacman")
pacman::p_load("plumber", "tidyverse", "jsonlite", "tm", "tidytext", "readr", "wordcloud2", "RColorBrewer", "wordcloud", "htmlwidgets")

# Initialize an empty global container for the analysis results
result <- NULL  

labMT <- read_delim("labMT2english.csv",delim = "\t") %>% rename("value" = "happs")

lexicons <- list("AFINN" = tidytext::get_sentiments("afinn"), 
                 "NRC" = tidytext::get_sentiments("nrc"), 
                 "Bing" = tidytext::get_sentiments("bing"), 
                 "Mechanical Turk (LabMT)" = labMT)

# I define this function outside of any particular endpoint to keep the endpoint code succinct
calculate_sentiment <- function(.corpus, .lexicon, .stops) {
  
  custom_stops <- unlist(stringr::str_split(trimws(gsub("[[:punct:]]", " ", .stops)), "\\s+"))
  
  # Convert the array of texts into a Corpus so that we can clean it using tm
  corpus <- tm::Corpus(tm::VectorSource(jsonlite::fromJSON(.corpus)))  
  corpus <- tm::tm_map(corpus, content_transformer(tolower)) # convert all words to lower case
  corpus <- tm::tm_map(corpus, removePunctuation) # remove all punctuation
  corpus <- tm::tm_map(corpus, removeNumbers) # remove all numbers
  corpus <- tm::tm_map(corpus, stripWhitespace) # strip out white space
  corpus <- tm::tm_map(corpus, removeWords, c(custom_stops, stop_words$word)) # remove additional user-defined stop words 
  corpus <- tm::DocumentTermMatrix(corpus) # create a Document Term Matrix from the final cleaned text
  
  lexicon_df <- data.frame(lexicons[[.lexicon]])

  if (!.lexicon %in% c("AFINN", "Mechanical Turk (LabMT)")) {
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
    
    result <<- list(counts = counts, 
                   summary = summary)
    
    return(result)
    
  } else {
    counts <- broom::tidy(corpus) %>%
      group_by(term) %>%
      summarise(count = sum(count, na.rm = T)) %>%
      inner_join(lexicon_df, by = c(term = "word"))
    
    summary <- counts %>% mutate(weighted_value = count * value)

    weighted_sentiment <- round(weighted.mean(x = summary$value, w = summary$count), 2)
    
    result <<- list(counts = counts, 
               weighted_sentiment = weighted_sentiment)
    
    return(result)
  }
}

# API -------------------------------------------------------------------

# We need the below filter to enable our front end to call the API 

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

#* Returns all available lexicons
#* @get /lexicons
function() {
  names(lexicons)
}

#* Passes user input to the calculate_sentiment function and returns detailed sentiment analysis as a JSON response
#* @serializer unboxedJSON
function(req) {

  calculate_sentiment(.stops = req$body$stops, 
                      .corpus = req$body$corpus, 
                      .lexicon = req$body$lexicon)
}

#* @get /wordcloud
#* @serializer png
function(req, res) {
  wordcloud_df <- result$counts %>% 
    rename("word" = "term", "freq" = "count") %>% 
    select(word,freq)
  
  wordcloud(words = wordcloud_df$word,
            freq = wordcloud_df$freq,
            min.freq = 1,
            max.words=200, 
            scale=c(5,.6),
            random.order=T,
            rot.per=0.35,
            colors=brewer.pal(8, "Dark2"))

}