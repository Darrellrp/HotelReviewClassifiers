store_csv <- function (reviews, filePath) {
  # Export the reviews table to csv file
  write.table(reviews, filePath, sep = ",") 
}

store_db <- function (reviews, dbname, user, password, host = 'localhost', port = 3306) {
  # Connect to MySQL Database
  db <- dbConnect(RMySQL::MySQL(), user=user, password=password, dbname=dbname, host=host, port=port)
  
  print('Storing reviews in database...')
  
  reviews$Review <- gsub('"', "'", reviews$Review)
  
  # Insert Table data into the Database
  for(rowId in c(1:nrow(reviews))) {
    callQuery <- paste('CALL add_review("', reviews$Review[rowId], '", ', reviews$Is_Positive[rowId], ')', sep = "")
    dbSendQuery(db, callQuery)
  }
  
  # Close connection
  dbDisconnect(db)
  
}

store_handwritten_reviews <- function(hand_reviews_reviews, hand_reviews_label, filePath) {
  
  hand_reviews_df <- data.frame(Review = hand_reviews_reviews, Is_Positive = hand_reviews_label)
  
  write.table(hand_reviews_df, filePath, sep = ",")
  
  hand_reviews <- read.csv(filePath)
}