# Function to produce suitability score for an agent based on its characteristics
# Return suitability score

get_suitability <- function(experienced_climate, climate_median, climate_IQR, variable){
  
  if(!any(variable %in% c('temperature', 'oxygen', 'food'))){
    stop('Invalid variable name. Variable must be "temperature", "oxygen", or "food".')
  }
  if(is.na(variable)){
    stop('Need variable name. Variable must be "temperature", "oxgen", or "food".')
  }
  
  climate_median <- as.numeric(climate_median)
  climate_IQR <- as.numeric(climate_IQR)
  
  #Temperature - Gaussian response
  if(variable=="temperature"){ 
    temp_sd <- climate_IQR / 1.3488
    #calculate z-score distance for suitability: z = (x-u)/sd
    z_distance <- (experienced_climate - climate_median)/temp_sd
    #transform distance to gaussian response to standardize between 0 and 1
    suitability <- exp(-0.5 * z_distance^2)
      
    return(list(z_distance=z_distance, suitability=suitability))
  }
  
  #Oxygen - Hill function with large h, assuming animals live in oxygenated waters well above their thresholds 
  if(variable=="oxygen"){
    O2_K <- climate_median - climate_IQR
    h <- 6
    O2_experienced <- experienced_climate
    suitability <- O2_experienced^h / (O2_K^h + O2_experienced^h)
    O2_optimum_suitability <- climate_median^h / (O2_K^h + climate_median^h)
    suitability <- suitability / O2_optimum_suitability
    suitability <- min(suitability, 1)
    return(list(suitability=suitability))
    
    return(list(suitability=suitability))
  }
  
  #Organic carbon/food resource - Hill function with smaller h
  if(variable=="food"){
    food_K <- climate_median - climate_IQR
    h <- 1
    food_experienced <- experienced_climate
    suitability <- food_experienced^h / (food_K^h + food_experienced^h)
    food_optimum_suitability <- climate_median^h / (food_K^h + climate_median^h)
    suitability <- suitability / food_optimum_suitability
    suitability <- min(suitability, 1)
    return(list(suitability=suitability))
  }
 
}

read_environment <- function(agent_state, lat_column_name, lng_column_name, environment_nc_path){
  
  #defense! defence! 
  required_climate_variables <- c('temp_med', 'temp_IQR', 'O2_med', 'O2_IQR', 'Cexp_med', 'Cexp_IQR')
  if(!all(required_climate_variables %in% colnames(agent_state))){
    stop('Incompatible climate variable names. See package notes for requirements.')
  }
  if(!is.character(environment_nc_path) || length(environment_nc_path) != 1L || is.na(environment_nc_path) || !file.exists(environment_nc_path)){
    stop('environment_nc_path must identify an existing filepath.')
  }
  if(!requireNamespace("PaleoClimR", quietly=TRUE)){
    stop("The PaleoClimR package is required.")
  } else{
    library(PaleoClimR)
  }
  
  #match to environment 
  current_temperature <- PaleoClimR::cGENIE.points.data(var='ocn_temp', #deg C
                                                        experiment=environment_nc_path,
                                                        depth.level=1,
                                                        dims=3,
                                                        agent_state,
                                                        year='default',
                                                        lat.name=lat_column_name,
                                                        lng.name=lng_column_name,
                                                        na.method='nearest')$matched_climate
  current_oxygen <- PaleoClimR::cGENIE.points.data(var='ocn_O2', #uM
                                                   experiment=environment_nc_path,
                                                   depth.level=1,
                                                   dims=3,
                                                   agent_state,
                                                   year='default',
                                                   lat.name=lat_column_name,
                                                   lng.name=lng_column_name,
                                                   na.method='nearest')$matched_climate
  current_Corg <- PaleoClimR::cGENIE.points.data(var='bio_fpart_POC', #mol m-3 yr-1
                                                   experiment=environment_nc_path,
                                                   depth.level=1,
                                                   dims=3,
                                                   agent_state,
                                                   year='default',
                                                   lat.name=lat_column_name,
                                                   lng.name=lng_column_name,
                                                   na.method='nearest')$matched_climate
  
  # get suitability scores
  temp_suitability <- get_suitability(current_temperature, agent_state[,'temp_med'], agent_state[,'temp_IQR'], 'temperature')
  oxygen_suitability <- get_suitability(current_oxygen, agent_state[,'O2_med'], agent_state[,'O2_IQR'], 'oxygen')
  food_suitability <- get_suitability(current_Corg, agent_state[,'Cexp_med'], agent_state[,'Cexp_IQR'], 'food')
  
  # get overall suitability score - harmonic mean which gives more power to poor conditions
  scores <- cbind(abs(temp_suitability$suitability),
                  abs(oxygen_suitability$suitability),
                  abs(food_suitability$suitability))
  scores <- pmax(0, pmin(1, scores))
  overall_suitability <- length(scores) / sum(1/scores)
  
  return(list(current_temperature=current_temperature,
              current_oxygen=current_oxygen,
              current_Corg=current_Corg,
              temp_z=temp_suitability$z_distance,
              temp_suitability=temp_suitability$suitability, 
              oxygen_suitability=oxygen_suitability$suitability,
              food_suitability=food_suitability$suitability,
              overall_suitability=overall_suitability))
  
}
