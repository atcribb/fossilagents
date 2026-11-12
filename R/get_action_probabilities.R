#gets action probabilities for agents to take

get_action_probabilities <- function(action_states){

  base_migration <- action_states$base_migration
  base_adaptation <- action_states$base_adaptation
  stress <- action_states$stress
  stress_weight_migration <- action_states$stress_weight_migration
  stress_weight_adaptation <- action_states$stress_weight_adaptation
  dispersal_ability <- action_states$dispersal_ability
  adaptation_capacity <- action_states$adaptation_capacity 
  
  prob_migration <- (base_migration + stress*stress_weight_migration)*dispersal_ability
  prob_adaptation <- (base_adaptation + stress*stress_weight_adaptation)*adaptation_capacity
  
  action_probs <- data.frame(
    stay = (1-prob_migration)*(1-prob_adaptation),
    migrate = prob_migration*(1-prob_adaptation),
    adapt = (1-prob_migration)*prob_adaptation,
    migrate_adapt = prob_migration*prob_adaptation
  )
  
  return(action_probs)
  
  
}
