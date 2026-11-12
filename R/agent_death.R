#kill agents given threshold
agent_death <- function(agent_population, suitability_threshold){
  
  surviving_agents <- subset(agent_population, overall_suitability >= suitability_threshold)
  dead_agents <- subset(agent_population, overall_suitability < suitability_threshold)
  
  return(list(surviving_agents=surviving_agents, dead_agents=dead_agents))

  
}
