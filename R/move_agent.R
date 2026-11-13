#Moves agents to a random surrounding viable cell

move_agent <- function(agent){
  
  #get all of the accessible cells 
  accessible_cells <- get_accessible_cells(agent, agent$mobility, 'cell_id')$viable_surrounding_cells

  #sample a random row
  idx <- sample(nrow(accessible_cells), 1)
  target_cell <- accessible_cells[idx,]
  
  new_lat <- target_cell$midpoint_lat
  new_lng <- target_cell$midpoint_lng
  new_cell_id <- target_cell$cell_ID

  agent$cell_id <- new_cell_id
  agent$lat <- new_lat
  agent$midpoint_lat <- new_lat
  agent$lng <- new_lng
  agent$midpoint_lng <- new_lng
  
  return(agent)

}
