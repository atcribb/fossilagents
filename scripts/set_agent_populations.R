#Summary: set agent populations for all ecophysiotype groups in fossil data
# Uses functions in init_population.R

#load functions
source('R/init_population.R') 

#data input 
load('data/Rhaetian-Hettangian_cleanecospacedata.RData')

#set up data frame of agents and their population sizes for a target starting agent population of 500
ETE_ecospace <- subset(ETE_ecospace, !is.na(FG_Number))
Rhaetian_data <- subset(ETE_ecospace, stage=='Rhaetian')
FG_list <- names(sort(table(Rhaetian_data$FG_Number), decreasing=TRUE))
FG_table <- data.frame(fg_number=FG_list,
                       n=rep(NA, length(FG_list)),
                       proportion=rep(NA,length(FG_list)),
                       agent_popluation_size=rep(NA, length(FG_list))
                       )
n_total_agents <- 500
for(i in 1:nrow(FG_table)){
  fg_data <- subset(Rhaetian_data, FG_Number==FG_table$fg_number[i])
  FG_table$n[i] <- nrow(fg_data)
  FG_table$proportion[i] <- max(round(nrow(fg_data)/nrow(Rhaetian_data), digits=3), 0.001)
  FG_table$agent_population_size[i] <- max(round(FG_table$proportion[i]*n_total_agents, digits=0), 1)
}
FG_table

#== Create output table ==# 
vars <- c('agent_id',
         'group_tag',
         'tiering',
         'motility',
         'feeding',
         'T_u',
         'T_o',
         'O2_u',
         'O2_o',
         'energy_min',
         'lat',
         'lng')
agent_state_0 <- as.data.frame(matrix(nrow=0, ncol=length(vars)))
colnames(agent_state_0) <- vars

#== initialise agent populations for each of the functional groups ==#
for(i in 1:nrow(FG_table)){
  
  this_fg <- FG_table$fg_number[i]
  this_fg_agent_population_size <- FG_table$agent_population_size[i]
  
  fg_agents <- init_population(fossil_data=Rhaetian_data,
                                   ecophysiotype_group=FG_table$fg_number[i],
                                   ecophysiotype_group_colum="FG_Number",
                                   lat_column="p_lat",
                                   lng_column="p_lng",
                                   total_ecophysiotype_population=FG_table$agent_population_size[i],
                                   subsample_cell_size=250,
                                   subsample_cell_threshold=15)
    agent_state_0 <- rbind(agent_state_0, fg_agents)
  
}
View(agent_state_0)

map_it <- function(timebin_fossil_data, age_of_timebin_Ma, p_lng_column_name, p_lat_column_name){
  
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
    geom_sf(data=fossils_transformed, aes(fill=group_tag), col='black', shape=21, size=2) + 
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
map_it(agent_state_0, 201, "lat", "lng")

