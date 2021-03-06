
# loads the raw data, setting some default types for various columns

load_raw <- function(filename) {
  read_csv(filename, 
                              col_types = cols(
                                .default = col_character(),
                                project_id = col_character(),
                                id = col_character(),
                                parameter_id = col_character(),
                                age_in_days = col_integer(),
                                date_of_experiment = col_datetime(format = ""),
                                weight = col_double(),
                                phenotyping_center_id = col_character(),
                                production_center_id = col_character(),
                                weight_date = col_datetime(format = ""),
                                date_of_birth = col_datetime(format = ""),
                                procedure_id = col_character(),
                                pipeline_id = col_character(),
                                biological_sample_id = col_character(),
                                biological_model_id = col_character(),
                                weight_days_old = col_integer(),
                                datasource_id = col_character(),
                                experiment_id = col_character(),
                                data_point = col_double(),
                                age_in_weeks = col_integer(),
                                `_version_` = col_character()
                              )
  )
}

# Apply some standard cleaning to the data
clean_raw_data <- function(mydata) {
  mydata %>% 
    
    # Fileter to IMPC source (recommened by Jeremey in email to Susi on 20 Aug 2018)
    filter(datasource_name == 'IMPC') %>%
    
    # standardise trait names
    mutate(parameter_name = tolower(parameter_name) ) %>%
    
    # remove extreme ages
    filter(age_in_days > 0 & age_in_days < 500) %>% 

    # remove NAs 
    filter(!is.na(data_point)) %>%
  
    # subset to reasonable set of variables
    # date_of_experiment: Jeremy suggested using as an indicator of batch-level effects
    select(production_center, strain_name, strain_accession_id, biological_sample_id, pipeline_stable_id, procedure_group, procedure_name, sex, date_of_experiment, age_in_days, weight, parameter_name, data_point) %>% 
    arrange(production_center, biological_sample_id, age_in_days)
}


# subset data to select data for given parameter, and taking a single record per individual, choosing the record as close as possible to 
# age_center
#data_subset_parameter_individual_by_age <- function(mydata, parameter, age_min, age_center) {
#  tmp <- mydata %>%
#    filter(age_in_days >= age_min,
#           parameter_name == parameter) %>%
 #   # take results for single individual closest to age_center
#    mutate(age_diff = abs(age_center - age_in_days)) %>%
#    group_by(biological_sample_id) %>%
 #   filter(age_diff == min(age_diff)) %>%
 #   select(-age_diff)
  # still some individuals with multiple records (because same individual appears under different procedures, so filter to one record)
 # i <- match(unique(tmp$biological_sample_id), tmp$biological_sample_id)
#  tmp[i, ] 
#}

#for loop across all traits (FZ)
data_subset_parameterid_individual_by_age <- function(mydata, parameter, age_min, age_center) {
  tmp <- mydata %>%
    filter(age_in_days >= age_min,
           id == parameter) %>%
    # take results for single individual closest to age_center
    mutate(age_diff = abs(age_center - age_in_days)) %>%
    group_by(biological_sample_id) %>%
    filter(age_diff == min(age_diff)) %>%
    select(-age_diff)
  
  # still some individuals with multiple records (because same individual appears under different procedures, so filter to one record)
  i <- match(unique(tmp$biological_sample_id), tmp$biological_sample_id)
  tmp[i, ] 
}
