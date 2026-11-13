
agent_map <- function(timebin_fossil_data, age_of_timebin_Ma, p_lng_column_name, p_lat_column_name){
  
  #get map shapes 
  coastlines <- rgplates::reconstruct('coastlines', age=age_of_timebin_Ma, model='PALEOMAP')
  edge <- mapedge()
  proj <- 'ESRI:54030'
  coasts_sf <- st_transform(coastlines, crs=proj)
  edge_sf <- st_transform(edge, crs=proj)
  
  #make fossil data spatial
  sf_fossils <- st_as_sf(timebin_fossil_data, coords=c(p_lng_column_name, p_lat_column_name), crs=4326) 
  proj <- 'ESRI:54030'
  fossils_transformed <- st_transform(sf_fossils, crs=proj)
  
  age_map <- ggplot() +
    geom_sf(data=edge_sf, fill='#E0FBFC') +
    geom_sf(data=coasts_sf, fill='gray90', col='gray85') +
    geom_sf(data=fossils_transformed, aes(fill=overall_suitability), col='black', shape=21, size=4) + 
    scale_fill_viridis_c() +
    theme_bw() +
    theme(
      panel.border=element_rect(fill=NA),
      legend.key.height = unit(1.5,'line'),
      legend.title=element_text(size=6),
      legend.text=element_text(size=7),
      plot.title=element_text(size=7, face='bold')
    )
  return(age_map)
  
}