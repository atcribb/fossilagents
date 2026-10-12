# Function to produce suitability score for an agent based on its characteristics
# Return suitability score

read_environment <- function(agent_state, environment_nc_path){
  
  #defense! defence! 
  required_climate_variables <- c('temp_med', 'temp_IQR', 'O2_med', 'O2_IQR', 'Cexp_med', 'Cexp_IQR')
  if(!all(required_climate_variables %in% colnames(agent_state))){
    stop('Incompatible climate variable names. See package notes for requirements.')
  }
  if(!is.character(environment_nc_path) || length(environment_nc_path) != 1L || is.na(environment_nc_path) || !file.exists(environment_nc_path)){
    stop('environment_nc_path must identify an existing filepath.')
  }
  
  
  
}
