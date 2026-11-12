#Assign h3 grid cell ids to agent

get_cell_ids <- function(agent_df, lat_col, lng_col, resolution=2){
  
  library(h3jsr)
  library(sf)
  
  sf_coords <- sf::st_as_sf(agent_df, coords=c('lng', 'lat'), crs=4326, remove=FALSE)
  
  cell_ids <- h3jsr::point_to_cell(sf_coords, res=resolution)
  h3_midpoints <- st_coordinates(h3jsr::cell_to_point(cell_ids))
  colnames(h3_midpoints) <- c('lng', 'lat')
  return(list(cell_ids = cell_ids, h3_midpoints = h3_midpoints))
  
  
}

