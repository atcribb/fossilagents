#fit agents most likely to copy themselves into the next generation

agents_reproduce <- function(agent_population, reproduce_threshold, generation, baseline_reproduction=0.6){
  
  baseline_reproduction <- 0.6
  
  candidates <- subset(agent_population, overall_suitability>=reproduce_threshold)
  
  reproducing_agent_ids <- c()
  children_agent_ids <- c()
  
  for(i in 1:nrow(agent_population)){
    
    p_yes <- agent_population[i,'overall_suitability']
    p_no <- 1-p_yes
    outcome <- sample(c('yes', 'no'), 1, prob=c(p_yes, p_no))
    if(outcome=='yes'){
      parent_id <- agent_population[i,'agent_id']
      child_id <- paste(parent_id,generation,sep='.')
      reproducing_agent_ids <- c(reproducing_agent_ids, parent_id)
      children_agent_ids <- c(children_agent_ids, child_id)
    }
  }
  
  child_clones <- subset(agent_population, agent_id %in% reproducing_agent_ids)
  child_clones$agent_id <- children_agent_ids
  
  return(list(child_agent_population=child_clones, reproducing_ids=reproducing_agent_ids, child_ids=children_agent_ids))
  
  
}
