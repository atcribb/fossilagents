#Full function to update agent population by:
# agent_death
# agents_reproduce
# choose_action:
# [adapt, migrate, adapt+migrate, stay]
# record new population by appending list 

update_agents <- function(agents, timestep, history_list, world_file, carrying_capacity=250){
  
  #kill agents
  update_popdyns_agents <- agent_death(agents, 0.05)$surviving_agents 
  #produce new agents 
  update_popdyns_agents <- rbind(update_popdyns_agents, agents_reproduce(update_popdyns_agents, 0.4, timestep)$child_agent_population)
  
  #cull least fit agents for carrying capacity
  if(nrow(update_popdyns_agents)>carrying_capacity){
    update_popdyns_agents <- update_popdyns_agents[order(update_popdyns_agents$persistence_probability, decreasing=TRUE)[1:carrying_capacity],]
  }
  
  #create new dataframe for updated agents
  new_agent_population <- as.data.frame(matrix(NA, nrow=0, ncol=ncol(update_popdyns_agents)+1))
  colnames(new_agent_population) <- c(colnames(update_popdyns_agents), 'action')
  
  #choose actions - agent by agent
  for(i in 1:nrow(update_popdyns_agents)){
    
    this_agent <- update_popdyns_agents[i,]
    
    action <- choose_action(this_agent, world_file)

    if(action=="stay"){ #action consequences if choosing to stay/remain the same
      
      this_agent$action <- action
      new_agent_population <- rbind(new_agent_population, this_agent) #just copy over the old agent into the new
      
    } else if(action=="migrate"){ #action consequences if choosing to migrate 
      
      this_agent$action <- action
      cell_check <- nrow(get_accessible_cells(this_agent, this_agent$mobility, 'cell_id')$viable_surrounding_cells)
      
      if(cell_check>0){
        moved_agent <- move_agent(this_agent)
        new_agent_population <- rbind(new_agent_population, moved_agent)
      } else(new_agent_population <- new_agent_population) #don't add the new agent

      
    } else if(action=="adapt"){ #action consequences if choosing to adapt niche 
      
      this_agent$action <- action
      adapted_agent <- adapt_agent(this_agent, 0.05, world_file)
      new_agent_population <- rbind(new_agent_population, adapted_agent)
      
    } else if(action=="migrate_adapt"){ #action consequences if choosing to migrate and adapt
      
      this_agent$action <- action
      
      #move
      cell_check <- nrow(get_accessible_cells(this_agent, this_agent$mobility, 'cell_id')$viable_surrounding_cells)
      if(cell_check>0){
        moved_agent <- move_agent(this_agent)
      }
      
      #adapt
      adapted_moved_agent <- adapt_agent(moved_agent, 0.05, world_file)
      new_agent_population <- rbind(new_agent_population, adapted_moved_agent)

    }
    
    
  }
  
  #record
  updated_history <- record_agent_population(new_agent_population, history_list, timestep)
  
  return(updated_history)
  

}
