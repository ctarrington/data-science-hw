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
      count = acceptance + rejection
      theta = acceptance / count
      
      for (row in seq(1, count)) {
        df = df %>% add_row(department = department, gender = gender, accepted = rbinom(1,1,theta))
      }
    }
  }
  
  return(df)
}
