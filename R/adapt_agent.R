#Function for agent to shift climatic nice towards experience

adapt_agent <- function(agent, max_adaptation_rate=0.05, world_file){
  
  #Calculate a maximum potential shift
  #D_N = max. adaptation rate * adaptation capacity * (experience - current niche median)
  
  #Gather variables for niche shift equation:
  #Adaptive capacities:
  agent_state <- get_agent_state(agent)
  adaptation_capacity_T <- agent_state$adaptation_capacity_T
  adaptation_capacity_O2 <- agent_state$adaptation_capacity_O2
  adaptation_capacity_food <- agent_state$adaptation_capacity_food
  
  #experienced climates
  agent_climates <- read_environment(test_agent, 'lat', 'lng', world_file)
  experience_T <- agent_climates$current_temperature
  experience_O2 <- agent_climates$current_oxygen
  experience_food <- agent_climates$current_Corg
  
  #current niche medians
  T_niche_median <- as.numeric(agent$adapted_temp_med)
  O2_niche_median <- as.numeric(agent$adapted_O2_med)
  food_niche_median <- as.numeric(agent$adapted_Cexp_med)
  
  
  #Only need to adapt oxygen and food if current values are lower than the niche median - 1/2 niche IQR (more oxygen and more food all fine)
  #Temperature always moving target 
  shift_T <- 'yes'
  shift_O2 <- 'no'
  shift_food <- 'no'
  
  if(experience_O2 < (O2_niche_median - 0.5*as.numeric(agent$O2_IQR))){
    shift_O2 <- 'yes'
    max_D_O2 <- max_adaptation_rate*adaptation_capacity_O2*(O2_niche_median-experience_O2) #niche median will always be higher than experienced O2
    actual_D_O2 <- rbeta(1, shape1=2, shape2=5)*max_D_O2
    new_O2_med <- O2_niche_median+actual_D_O2
  } else{new_O2_med=O2_niche_median}
  
  if(experience_food < (food_niche_median - 0.5*as.numeric(agent$Cexp_IQR))){
    shift_food <- 'yes'
    max_D_food <- max_adaptation_rate*adaptation_capacity_food*(food_niche_median-experience_food) #niche median will always be higher than experienced O2
    actual_D_food <- rbeta(1, shape1=2, shape2=5)*max_D_food
    new_food_med <- food_niche_median+actual_D_food
  } else{new_food_med=food_niche_median}
  
  max_D_T <- max_adaptation_rate*adaptation_capacity_T*(T_niche_median-experience_T)
  actual_D_T <- rbeta(1, shape1=2, shape2=5)*max_D_T
  new_temp_med <- actual_D_T + T_niche_median
  
  agent$adapted_temp_med <- new_temp_med
  agent$adapted_O2_med <- new_O2_med
  agent$adapted_Cexp_med <- new_food_med
  
  return(agent)
  
  
}
