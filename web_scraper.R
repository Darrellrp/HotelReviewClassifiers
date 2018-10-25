get_web_reviews <- function(base_url, url) {
  
  url <- paste(base_url, url, sep = '')
  
  number_of_pages <- as.numeric(html_attr(html_node(read_html(url), '.pageNum.last'), 'data-page-number')) - 1
  
  review_titles <- NULL
  review_text <- NULL
  review_rating <- NULL
  
  for(pageId in 0:number_of_pages) {
    
    if (pageId >= 150) {
      break
    }
    
    print(url)
    
    # Get the page
    page <- read_html(url)
    
    # Get the text & rating from the reviews & Converting the text & rating to text
    review_text <- append(review_text, html_text(html_nodes(page, '.prw_reviews_text_summary_hsx > .entry > .partial_entry')))
    review_rating <- as.numeric(append(review_rating, get_review_rating(html_attr(html_nodes(page, '.reviewSelector .ui_bubble_rating'), 'class'))))
    
    # Get the next page url
    url <- paste(base_url, html_attr(html_node(page, '.next'), 'href'), sep = '')
  }
  
  # Create dataframe for the Reviews & Name the columns
  reviews <- cbind.data.frame(review_text, review_rating)
  colnames(reviews) <- c('Review', 'Rating')
  
  # Label the reviews (Positive or Negative) & exclude the 30 ratings
  reviews <- select(subset(mutate(reviews, Is_Positive = Rating > 30), Rating != 30), -Rating)
  
  # Convert Is_Positive column from Boolean to Integer
  reviews$Is_Positive <- as.integer(as.logical(reviews$Is_Positive))
  
  return(reviews)
}