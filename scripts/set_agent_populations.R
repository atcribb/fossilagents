#Summary: set agent populations for all ecophysiotype groups in fossil data
# Uses functions in init_population.R

#=== packages ====#
library(rgplates)
library(ggplot2)

#load functions
source('R/init_population.R') 

#=== data input ===#
#fossil occurrences - 
load('data/ETE_genera_cluster_traits.RData')


#set up data frame of agents and their population sizes for a target starting agent population of 500
cluster_nos <- sort(unique(ETE_trait_data$cluster))
group_table <- data.frame(cluster_no=cluster_nos,
                       n=rep(NA, length(cluster_nos)),
                       proportion=rep(NA,length(cluster_nos)),
                       agent_population_size=rep(NA, length(cluster_nos))
                       )
n_total_agents <- 500
for(i in 1:length(cluster_nos)){
  cluster_data <- subset(ETE_trait_data, cluster==cluster_nos[i])
  group_table$n[i] <- nrow(cluster_data)
  group_table$proportion[i] <- max(round(nrow(cluster_data)/nrow(ETE_trait_data), digits=3), 0.001)
  group_table$agent_population_size[i] <- max(round(group_table$proportion[i]*n_total_agents, digits=0), 1)
}
group_table

#== Create output table ==# 
vars <- c('agent_id',
          'group_tag',
          'temp_med',
          'temp_IQR',
          'O2_med',
          'O2_IQR',
          'Cexp_med',
          'Cexp_IQR',
          'mobility',
          'attachment',
          'sed_relationship',
          'infaunal_depth',
          'resource_location',
          'resource_acquisition',
          'lat',
          'lng')
agent_state_0 <- as.data.frame(matrix(nrow=0, ncol=length(vars)))
colnames(agent_state_0) <- vars

#== initialise agent populations for each of the functional groups ==#
for(i in 1:nrow(group_table)){
  
  this_cluster <- group_table$cluster[i]
  this_cluster_agent_population_size <- group_table$agent_population_size[i]
  
  fg_agents <- init_population(fossil_data=ETE_trait_data,
                                   ecophysiotype_group=group_table$cluster[i],
                                   ecophysiotype_group_column="cluster",
                                   lat_column="p_lat",
                                   lng_column="p_lng",
                                   total_ecophysiotype_population=group_table$agent_population_size[i],
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
    geom_sf(data=fossils_transformed, aes(fill=as.factor(group_tag)), col='black', shape=21, size=2) + 
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

