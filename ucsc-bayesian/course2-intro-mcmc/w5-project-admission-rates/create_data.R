library("tidyverse")
data("UCBAdmissions")

create_data = function() {

  df = tibble(
    department = numeric(),
    gender = numeric(),
    accepted = numeric()
    )
  
  for (gender in seq(1,2)) {
    for (department in seq(1,6)) {
      acceptance = UCBAdmissions[1, gender, department]
      rejection = UCBAdmissions[2, gender, department]
      
      for (row in seq(1, rejection)) {
        df = df %>% add_row(department = department-1, gender = gender-1, accepted = 0)
      }
      
      for (row in seq(1, acceptance)) {
        df = df %>% add_row(department = department-1, gender = gender-1, accepted = 1)
      }
    }
  }
  
  return(df)
}
