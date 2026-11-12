#kill agents given threshold
agent_death <- function(agent_population, persistance_threshold){
  
  #kill agents below threshold 
  first_dead_agents <- subset(agent_population, overall_suitability < persistance_threshold)
  chopping_block <- subset(agent_population, overall_suitability >= persistance_threshold)
  
  survivor_agent_ids <- c()
  dead_agent_ids <- c()
  
  #surviving agents are a function of persistence probability
  for(i in 1:nrow(chopping_block)){
    persist_probability <- chopping_block[i,'persistence_probability']
    death_probability <- 1-persist_probability
    action <- sample(c('death', 'persist'), 1, prob=c(death_probability, persist_probability))
    if(action=='persist'){
      survivor_agent_ids <- c(survivor_agent_ids, chopping_block[i,'agent_id'])
    } else if(action=='death'){
      dead_agent_ids <- c(dead_agent_ids, chopping_block[i,'agent_id'])
    }
  }
  
  og_dead_agent_ids <- first_dead_agents$agent_id
  dead_agents <- subset(agent_population, agent_id %in% c(og_dead_agent_ids, dead_agent_ids))
  
  surviving_agents <- subset(agent_population, agent_id %in% survivor_agent_ids)
  
  return(list(surviving_agents=surviving_agents, dead_agents=dead_agents))

  
}

