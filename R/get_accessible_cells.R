# Return neighboring H3 cells that map to ocean cGENIE cells adjacent to land.
# grid_sf must contain cell_id, lon, and lat columns.

#Function to match h3 cell midpoint lat/lngs to genie cells 
cgenie_grid_match <- function(lat, lng){
  
  load('data/lookups/cell_lng_edges.RData')
  load('data/lookups/cell_lat_edges.RData')  
  
  lat_row <- which(lat_edge_lookup$south_edge < lat &
                     lat < lat_edge_lookup$north_edge)
  cgenie_lat <- lat_edge_lookup$cgenie_lat[lat_row]
  
  lng_row <- which(lng_edge_lookup$west_edge < lng &
                     lng < lng_edge_lookup$east_edge)
  cgenie_lng <- lng_edge_lookup$cgenie_lon[lng_row]
  
  return(list(cgenie_lat=cgenie_lat, cgenie_lng=cgenie_lng))
  
}


get_accessible_cells <- function(agent_df, cell_id_column, depth_mask_path='data/masks/ocean_land_coast.RData', h3_resolution=2){
  
  load(depth_mask_path)
  
  library(sf)
  library(h3jsr)
  
  #surrounding cell ids
  disk_ids <- get_disk(h3_address=agent_df[,cell_id_column], ring_size=1)[[1]]
  agent_id <- agent_df[,cell_id_column]
  disk_ids[!disk_ids %in% agent_id] #remove the agent id from the disk return
  
  #disk midpoint coordinates
  surrounding_midpoints <- st_coordinates(cell_to_point(disk_ids))
  surrounding_midpoints <- as.data.frame(surrounding_midpoints)
  colnames(surrounding_midpoints) <- c('midpoint_lng', 'midpoint_lat')
  surrounding_midpoints$cell_ID <- disk_ids
  surrounding_midpoints$environment_type <- rep(NA, nrow(surrounding_midpoints))
  
  mask_lat_list <- as.numeric(rownames(ocean_land_coast_mask))
  
  
  for(i in 1:nrow(surrounding_midpoints)){
    matched_coords <- cgenie_grid_match(surrounding_midpoints[i,'midpoint_lat'],surrounding_midpoints[i,'midpoint_lng'])
    matched_lat <- matched_coords$cgenie_lat
    matched_lng <- matched_coords$cgenie_lng
    
    lat_row_idx <- which(round(matched_lat) == round(mask_lat_list))
    
    surrounding_midpoints$environment_type[i] <- ocean_land_coast_mask[lat_row_idx, as.character(matched_lng)]

  }
  
  #keep the coast
  coastal_cells <- subset(surrounding_midpoints, environment_type=='coast')
  
  return(list(viable_surrounding_cells=coastal_cells, all_surrounding_cells=surrounding_midpoints))

  
}

