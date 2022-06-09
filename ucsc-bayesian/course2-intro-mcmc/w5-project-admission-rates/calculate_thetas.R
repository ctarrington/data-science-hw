library("tidyverse")
data("UCBAdmissions")

calculate_thetas = function() {

  df = tibble(
    Dept = character(),
    Gender = character(),
    admission_rate = numeric()
    )
  
  genders = c("Male", "Female")
  departments = c("A", "B", "C", "D", "E", "F")
  
  for (department_index in seq(1,6)) {
    for (gender_index in seq(1,2)) {
      Dept = departments[department_index]
      Gender = genders[gender_index]
      
      acceptance = UCBAdmissions[1, gender_index, department_index]
      rejection = UCBAdmissions[2, gender_index, department_index]
      admission_rate = acceptance / (acceptance + rejection)
      
      df = df %>% add_row(Dept = Dept, Gender = Gender, admission_rate = admission_rate)
    }
  }
  
  return(df)
}