#Given suitability scores of live agents, make decision to adapt and/or migrate
choose_action <- function(agent, world_file){
  #action options: 'stay', 'migrate', 'adapt', 'migrate_adapt'
  
  agent_state <- get_agent_state(agent, world_file)
  
  #baseline migration and adaptation probabilities (independent of any stress or traits - random background biological noise)
  base_migration <- 0.05
  base_adaptation <- 0.05
  
  #environmental stress weightings 
  stress <- (1-agent_state$overall_suitability)^2
  stress_weight_migration <- 0.5 #weights ask: how much action can we take if we are very stressed?
  stress_weight_adaptation <- 0.5
  
  #dispersal ability
  if(agent_state$motility_capacity == 'high'){
    dispersal_ability <- 1
  } else if(agent_state$motility_capacity == 'moderate'){
    dispersal_ability <- 0.75
  } else if(agent_state$motility_capacity == 'minimal'){
    dispersal_ability <- 0.25
  } else if(agent_state$motility_capacity == 'none'){
    dispersal_ability <- 0.1
  }
  
  #adaptation capacity based on main stress
  main_stress <- agent_state$main_stress
  if(main_stress == 'temp_suitability'){
    adaptation_capacity <- agent_state$adaptation_capacity_T
  } else if(main_stress == 'oxygen_suitability'){
    adaptation_capacity <- agent_state$adaptation_capacity_O2
  } else if(main_stress == 'food_suitability'){
    adaptation_capacity <- agent_state$adaptation_capacity_food
  }
  
  action_states <- data.frame(
    base_migration = base_migration,
    base_adaptation = base_adaptation,
    stress = stress,
    stress_weight_migration = stress_weight_migration,
    stress_weight_adaptation = stress_weight_adaptation,
    dispersal_ability = dispersal_ability,
    adaptation_capacity = adaptation_capacity 
  )
  
  action_probs <- get_action_probabilities(action_states)
  
  decision <- sample(x=names(action_probs),
                     size=1,
                     prob=action_probs)
  
  
  return(decision)
  
}

