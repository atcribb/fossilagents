#Function to record agent population in a buildable lists as model moves through time 

record_agent_population <- function(agent_population_df, history_list, time_step){
  
  if(!is.data.frame(agent_population_df)){
    stop("agent_population_df must be a data frame.")
  }
  if(!is.list(history_list)){
    stop("history_list must be a list.")
  }
  if(!is.numeric(time_step) || length(time_step) != 1L ||
     is.na(time_step) || !is.finite(time_step)){
    stop("time_step must be one finite number.")
  }

  history_name <- paste0("timestep_", time_step)
  if(history_name %in% names(history_list)){
    stop("history_list already contains ", history_name, ".")
  }

  history_list[[history_name]] <- agent_population_df
  return(history_list)
  
}
