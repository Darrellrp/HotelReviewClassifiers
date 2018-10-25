# Install rvest, RMySQL, dbConnect packages
# install.packages('rvest')
# install.packages('RMySQL')
# install.packages('dbConnect')
# install.packages('dplyr')
# install.packages('class')
# install.packages('tm')
# install.packages('e1071')
# install.packages('caret')
# install.packages('tm')
# install.packages('randomForest') 
# install.packages('cleanr') 
# install.packages('wordcloud')

# Import packages
library(rvest)
library(RMySQL)
library(dbConnect)
library(dplyr)
library(class)
library(tm)
library(e1071)
library(caret)
library(tm)
library(randomForest)
library(cleanr)
library(wordcloud)

source('basic_visual.R')
source('web_scraper.R')
source('text_classification.R')
source('utilities.R')
source('storage.R')

STORE_REVIEWS_IN_CSV <- FALSE
STORE_REVIEWS_IN_DB <- FALSE

LOAD_COOKED_REVIEWS <- TRUE

LOAD_NAIVE_MODEL <- FALSE
LOAD_RANDOM_FOREST_MODEL <- TRUE

WRITE_OWN_REVIEW <- TRUE
SAMPLE_SIZE <- 10000
TRAINING_PERC <- .99

reviews <- NULL

# set.seed(1)

if (!LOAD_COOKED_REVIEWS) {
  # Get Web & Kaggle reviews
  reviews_web_ozo_hotel <- get_web_reviews('https://www.tripadvisor.com', '/Hotel_Review-g188590-d7786396-Reviews-Ozo_Hotel-Amsterdam_North_Holland_Province.html')
  reviews_kaggle <- get_kaggle_reviews('csv/Hotel_Reviews.csv')
  reviews_handwritten <- get_handwritten_reviews('csv/handwritten_reviews.csv');
  
  # Combine Web & Kaggle reviews
  reviews <- rbind(reviews_web, reviews_kaggle, reviews_handwritten) 
  
  # Shuffle reviews
  reviews <- shuffle(reviews)
  
  # Store reviews in CSV & DB
  if (STORE_REVIEWS_IN_CSV) store_csv(reviews, 'csv/cooked_reviews.csv')
  if (STORE_REVIEWS_IN_DB) store_db(reviews, host = 'localhost', dbname = 'accomodations_db', user = 'root', password = '')
} else {
  print('Loading stored reviews...')
  reviews <- read.csv('csv/cooked_reviews.csv')
}

# Get a sample from all review
sample <- head(reviews, SAMPLE_SIZE)

# Prompt user to enter new review & label
new_review <- if (WRITE_OWN_REVIEW) readline(prompt="Enter new review: " )
new_review_label <- if (WRITE_OWN_REVIEW) as.numeric(readline(prompt="Enter review label: " ))

# Create Training & Test set
if (WRITE_OWN_REVIEW) {
  train <- sample
  test <- data.frame(Review = new_review, Is_Positive = new_review_label)
  
  sample <- rbind(sample, test)
  
  train$Is_Positive <- as.factor(train$Is_Positive)
  test$Is_Positive <- factor(test$Is_Positive, levels = c(0,1))
} else {
  # Split sample Tip: use sample.split
  sample_split <- sample.int(n = nrow(sample), size = floor(TRAINING_PERC * nrow(sample)), replace = F)
  
  train <- sample[sample_split,]
  test <- sample[-sample_split,]
  
  train$Is_Positive <- as.factor(train$Is_Positive)
  test$Is_Positive <- as.factor(test$Is_Positive)
}

# Create corpus from dataframe
corpus <- Corpus(DataframeSource(data.frame(doc_id = 1:nrow(sample), text = sample$Review, stringsAsFactors = FALSE)))

# Clean the corpus
corpus <- clean_corpus(corpus)

# Create DocumentTermMatrix & Remove sparse terms
dtm <- removeSparseTerms(DocumentTermMatrix(corpus), .99)
dtm_matrix <- as.data.frame(as.matrix(dtm))

# Split the DocumentTermMatrix into train & test samples
matrix_train <- if (WRITE_OWN_REVIEW) dtm_matrix[-nrow(sample),] else dtm_matrix[sample_split,]
matrix_test <- if (WRITE_OWN_REVIEW) dtm_matrix[nrow(sample),] else dtm_matrix[-sample_split,]

# KNN prediction
predict_knn(train, test, matrix_train, matrix_test, sample_split, WRITE_OWN_REVIEW)

# Naive Bayes prediction
predict_naive(train, test, matrix_train, matrix_test, LOAD_NAIVE_MODEL, WRITE_OWN_REVIEW)

# Random Forest prediction
predict_random_forest(train, test, matrix_train, matrix_test, LOAD_RANDOM_FOREST_MODEL, WRITE_OWN_REVIEW)

# Show worldcloud
show_wordcloud(dtm)
