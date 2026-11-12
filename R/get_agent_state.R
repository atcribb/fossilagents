#Function to get agent state: suitability scores, main stress, connectivity, mobility capacity, and adaptation capacity

get_agent_state <- function(agent, world_file){
  
  overall_suitability <- agent[,'overall_suitability']
  temperature_suitability <- agent[,'temp_suitability']
  food_suitability <- agent[,'food_suitability']
  oxygen_suitability <- agent[,'oxygen_suitability']
  
  main_stress <- names(which.min(agent[,c('temp_suitability', 'oxygen_suitability', 'food_suitability')]))
  
  if(agent$mobility=='very high'){
    motility_capacity <- 'high'
  } else if(agent$mobility=='high'){
    motility_capacity <- 'moderate'
  } else if(agent$mobility=='facultative'){
    motility_capacity <- 'minimal'
  } else if(agent$mobility=='stationary'){
    motility_capacity <- 'none'
  }
  
  cell_assessment <- get_accessible_cells(agent, agent$mobility, 'cell_id')
  viable_cells <- cell_assessment$viable_surrounding_cells 
  all_cells <- cell_assessment$all_surrounding_cells 
  connectivity <- nrow(viable_cells)/nrow(all_cells)
  
  
  #adaptive capacities
  max_T_shift <- 1
  max_O2_shift <- 0.05
  max_Cexp_shift <- 0.25
  
  #initial state
  init_T_med <- as.numeric(agent$temp_med)
  init_O2_med <- as.numeric(agent$O2_med)
  init_Cexp_med <- as.numeric(agent$Cexp_med)
  
  #current adapted state 
  T_capacity <- max(0,
                    1 - abs((init_T_med - as.numeric(agent$adapted_temp_med)) / max_T_shift)
  )
  O2_capacity <- max(0,
                    1 - abs((init_O2_med - as.numeric(agent$adapted_O2_med)) / max_O2_shift)
  )
  food_capacity <- max(0,
                    1 - abs((init_Cexp_med - as.numeric(agent$adapted_Cexp_med)) / max_Cexp_shift)
  )
  
  return(list(overall_suitability=overall_suitability,
              temperature_suitability=temperature_suitability,
              food_suitability=food_suitability,
              oxygen_suitability=oxygen_suitability,
              main_stress=main_stress,
              connectivity=connectivity,
              motility_capacity=motility_capacity,
              adaptation_capacity_T=T_capacity,
              adaptation_capacity_O2=O2_capacity,
              adapatation_capacity_food=food_capacity))
}

