# http://stackoverflow.com/questions/30592094/r-spreading-multiple-columns-with-tidyr
# http://www.cookbook-r.com/Manipulating_data/Converting_data_between_wide_and_long_format/

# converting wide to long with data.table
df <- data.frame(month=rep(1:3,2),
                 student=rep(c("Amy", "Bob"), each=3),
                 A=c(9, 7, 6, 8, 6, 9),
                 B=c(6, 7, 8, 5, 6, 7))
df
dfl <- data.table::dcast(data.table::setDT(df), month ~ student, value.var = c("A","B"))
dfl

# converting wide to long with tidyr
dfl2 <- df %>% tidyr::gather(variable, value, -(month:student)) %>%
  tidyr::unite(temp, student, variable) %>%
  tidyr::spread(temp, value)
dfl2



## Enumeration of strings
#To create automatically enumerated strings use paste0 function:

a <- c("A", "B", "C")
b <- c("1", "2", "3")
paste0(a, b)
paste0("A",b)


# computing variable in long format
# compute time difference between the observation of each wave
library(magrittr)

ds <- data.frame(
     id           = c(111,111,111,222,222,333),
     wave         = c(0,1,2,0,1,0),
     age_at_visit = c(10,11,12,10,12,10)
     )

ds <- ds %>%
  dplyr::group_by(id) %>%
  dplyr::arrange(wave) %>%
  dplyr::mutate(
    time_difference = ifelse(
      seq_len(length(id))==1L,                    # Examine the row order within the subject id.
      0,                                          # Return zero for subject's first row.
      age_at_visit - dplyr::lag(age_at_visit, 1)  # Otherwise return the difference.
    )
  ) %>%
  dplyr::ungroup()


