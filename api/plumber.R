# Setup -------------------------------------------------------------------

install.packages("pacman")
pacman::p_load("tm", "readr", "broom", "dplyr", "magrittr", "jsonlite", "wordcloud")

afinn <- base::readRDS("lexicons/afinn/afinn_111.rds")
nrc <- base::readRDS("lexicons/nrc/NRCWordEmotion.rds") 
bing <- base::readRDS("lexicons/bing/bing.rds")
labMT <- readr::read_delim("labMT2english.csv",delim = "\t") %>% rename("value" = "happs")

lexicons <- list("AFINN" = afinn, 
                 "NRC" = nrc,
                 "Bing" = bing,
                 "Mechanical Turk (LabMT)" = labMT)

# I define this function outside of any particular endpoint to keep the endpoint code succinct
calculate_sentiment <- function(.corpus, .lexicon, .stops) {
  
  custom_stops <- unlist(stringr::str_split(trimws(gsub("[[:punct:]]", " ", .stops)), "\\s+"))
  
  corpus <- tm::Corpus(tm::VectorSource(jsonlite::fromJSON(.corpus)))  
  corpus <- tm::tm_map(corpus, content_transformer(tolower))
  corpus <- tm::tm_map(corpus, removeNumbers) 
  corpus <- tm::tm_map(corpus, removeWords, c(custom_stops, tm::stopwords())) # remove additional user-defined stop words
  corpus <- tm::tm_map(corpus, removePunctuation) 
  corpus <- tm::tm_map(corpus, content_transformer(function(x) gsub("[[:punct:]]", " ", x))) # remove punctuation not captured by above
  
  corpusCopy <- corpus # create a snapshot of the un-stemmed corpus for later use
  
  corpus <- tm::tm_map(corpus, stemDocument, language="english")
  corpus <- tm::DocumentTermMatrix(corpus)
  
  lexicon_df <- data.frame(lexicons[[.lexicon]])
  
  # Assign the below object to the global scope so that it can be used in the /wordcloud endpoint
  tidy.corpus <<- tidytext::tidy(corpus)
  tidy.corpus$term <<- as.character(stemCompletion(tidy.corpus$term,dictionary = corpusCopy))
  
  if (!.lexicon %in% c("AFINN", "Mechanical Turk (LabMT)")) {
    counts <- tidy.corpus %>%
      dplyr::inner_join(lexicon_df, by = c(term = "word")) %>%
      dplyr::group_by(term, sentiment) %>%
      dplyr::summarise(count = sum(count, na.rm = T)) %>%
      dplyr::arrange(desc(count))
    
    summary <- counts %>%
      dplyr::group_by(sentiment) %>%
      dplyr::summarise(raw = sum(count, na.rm = T)) %>%
      dplyr::mutate(pct = raw / sum(raw) * 100) %>%
      dplyr::arrange(desc(pct))
    
    result <- list(counts = counts, 
                   summary = summary)

    return(result)
    
  } else {
    counts <- tidy.corpus %>%
      dplyr::group_by(term) %>%
      dplyr::summarise(count = sum(count, na.rm = T)) %>%
      dplyr::inner_join(lexicon_df, by = c(term = "word"))
    
    summary <- counts %>% dplyr::mutate(weighted_value = count * value)

    weighted_sentiment <- round(weighted.mean(x = summary$value, w = summary$count), 2)
    
    result <- list(counts = counts, 
               weighted_sentiment = weighted_sentiment)

    return(result)
  }
}

# API -------------------------------------------------------------------

# We need the below filter to enable our front end to call the API when running the app locally

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
#* @post /analyze
function(req) {
  calculate_sentiment(.stops = req$body$stops, 
                      .corpus = req$body$corpus, 
                      .lexicon = req$body$lexicon)
}

#* @get /wordcloud
#* @serializer png
function() {
  wordcloud_df <- tidy.corpus %>% 
    dplyr::rename("word" = "term", 
           "freq" = "count") %>% 
    dplyr::select(word,freq)
  
  wordcloud::wordcloud(words = wordcloud_df$word,
            freq = wordcloud_df$freq,
            min.freq = 1,
            max.words=200, 
            scale=c(5,.6),
            random.order=T,
            rot.per=0.35,
            colors=brewer.pal(8, "Dark2"))
}