#Given suitability scores of live agents, make decision to adapt and/or migrate
choose_action <- function(agent, world_file){
  
  #action options: 'stay', 'migrate', 'adapt', 'migrate_adapt'
  agent_state <- get_agent_state(agent, world_file)
  
  
  
  
  return(list(action=action))
  
}