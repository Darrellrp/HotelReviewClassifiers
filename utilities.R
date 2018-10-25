shuffle <- function(table) {
  return(table[sample(1:nrow(table)),])
}

get_review_rating <- function(review_class) {
  return(as.numeric(gsub('ui_bubble_rating bubble_', '', review_class)))
}

get_kaggle_reviews <- function(filePath) {
  
  print('Loading kaggle reviews...')
  
  hotel_reviews_kaggle <- read.csv('csv/Hotel_Reviews.csv')
  
  # Put Positive review in seperate dataframe & label them positive
  reviews_pos <- rename(mutate(select(hotel_reviews_kaggle, 'Positive_Review'), Is_Positive = TRUE), Review = Positive_Review)
  
  # Put Negative review in seperate dataframe & label them negative
  reviews_neg <- rename(mutate(select(hotel_reviews_kaggle, 'Negative_Review'), Is_Positive = FALSE), Review = Negative_Review)
  
  # combine Positive & Negative reviews
  reviews <- rbind(reviews_pos, reviews_neg)
  
  reviews <- subset(reviews, Review != 'No Negative')
  reviews <- subset(reviews, Review != 'No Positive')
  
  # Convert Is_Positive column from Boolean to Integer
  reviews$Is_Positive <- as.integer(as.logical(reviews$Is_Positive))
  
  return(reviews)
}

get_handwritten_reviews <- function(filePath) {
  return(read.csv(filePath))
}

clean_corpus <- function(corpus) {
  corpus <- tm_map(corpus, removeNumbers)
  corpus <- tm_map(corpus, removeWords, stopwords("english"))
  corpus <- tm_map(corpus, content_transformer(tolower))
  corpus <- tm_map(corpus, removePunctuation)
  
  return(corpus)
}

