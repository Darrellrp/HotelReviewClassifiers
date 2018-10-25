predict_knn <- function(train, test, matrix_train, matrix_test, sample_split, write_own_review) {
  
  # Determine (approximately) the optimal k-value
  knn_k <- if(write_own_review) sqrt(nrow(train)) else sqrt(length(sample_split))
  
  print('KNN: Classifying reviews...')
  pred_knn <- knn(matrix_train, matrix_test, train$Is_Positive, k = knn_k)
  
  # Show prediction result
  if(write_own_review) show_pred_results(pred_knn, test$Is_Positive)
  else print(confusionMatrix(pred_knn, test$Is_Positive))
}

predict_naive <- function(train, test, matrix_train, matrix_test, load_model, write_own_review) {
  
  model_naive <- NULL
  
  if (load_model) {
    print('Loading Naive model...')
    model_naive <- readRDS(file = 'models/naive_model.rds')
  } else {
    print('Naive Bayes: Training model...')
    model_naive <- naiveBayes(matrix_train, train$Is_Positive)
    
    print('Saving model...')
    saveRDS(model_naive, 'models/naive_model.rds') 
  }
  
  print('Naive Bayes: Classifying reviews...')
  pred_naive <- predict(model_naive, matrix_test)
  
  # Show prediction result
  if(write_own_review) show_pred_results(pred_naive, test$Is_Positive)
  else print(confusionMatrix(pred_naive, test$Is_Positive))
}

predict_random_forest <- function (train, test, matrix_train, matrix_test, load_model, write_own_review) {
  
  model_rf <- NULL
  
  if (load_model) {
    print('Loading Random Forest model...')
    model_rf <- readRDS(file = 'models/random_forest_model.rds')
  } else {
    print('Random Forest: Training model...')
    model_rf <- randomForest(matrix_train, train$Is_Positive)
    
    print('Saving model...')
    saveRDS(model_rf, 'models/random_forest_model.rds') 
  }
  
  print('Random Forest: Classifying reviews...')
  pred_rf <- predict(model_rf, matrix_test)
  
  # Show prediction result
  if(write_own_review) show_pred_results(pred_rf, test$Is_Positive)
  else print(confusionMatrix(pred_rf, test$Is_Positive))
}

show_pred_results <- function (pred, true_label) {
  pred <- as.numeric(as.character(pred))
  true_label <- as.numeric(as.character(true_label))
  
  print('')
  
  # Predicted correctly
  if (pred == true_label) {
    print('Correct prediction!')

  } else {
    print('Incorrect prediction!')
  }
  
  # Print the label of the review
  if (true_label == 1) print('The reviews was positive.')
  else print('The reviews was negative.')
  
  print(paste('Predicted label:', pred))
}

