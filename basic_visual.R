show_wordcloud <- function(dtm) {
  freq <- data.frame(sort(colSums(as.matrix(dtm)), decreasing = TRUE))
  wordcloud(rownames(freq), freq[,1], max.words = 40)
  print(freq)
}
  