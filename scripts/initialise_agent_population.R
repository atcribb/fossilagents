library(R.utils)
sourceDirectory('R/', modifiedOnly=FALSE)

#fossil occurrences - 
load('data/ETE_genera_cluster_traits.RData')

#Make agent population
#set up data frame of agents and their population sizes for a target starting agent population of 500
cluster_nos <- sort(unique(ETE_trait_data$cluster))
group_table <- data.frame(cluster_no=cluster_nos,
                          n=rep(NA, length(cluster_nos)),
                          proportion=rep(NA,length(cluster_nos)),
                          agent_population_size=rep(NA, length(cluster_nos))
)
n_total_agents <- 100
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
          'lng',
          'adapted_temp_med',
          'adapted_O2_med',
          'adapted_Cexp_med')
agent_state_0 <- as.data.frame(matrix(nrow=0, ncol=length(vars)))
colnames(agent_state_0) <- vars

#== initialise agent populations for each of the functional groups ==#
for(i in 1:nrow(group_table)){
  
  tryCatch({
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
  }, error=function(error) {
    message("Skipping cluster ", group_table$cluster[i], ": ", conditionMessage(error))
  })
  
}

agent_state_0$temp_suitability <- rep(NA, nrow(agent_state_0))
agent_state_0$oxygen_suitability <- rep(NA, nrow(agent_state_0))
agent_state_0$food_suitability <- rep(NA, nrow(agent_state_0))
agent_state_0$overall_suitability <- rep(NA, nrow(agent_state_0))

file_201 <- "~/Desktop/Manucripts/phanero_cgenie/muffin.CB.L23z_201_z32.BASES-1.config"

for(i in 1:nrow(agent_state_0)){
  
  agent_state <- agent_state_0[i,]
  agent_suitability <- read_environment(agent_state, "lat", "lng", file_201)
  
  agent_state_0$temp_suitability[i] <- agent_suitability$temp_suitability
  agent_state_0$oxygen_suitability[i] <- agent_suitability$oxygen_suitability
  agent_state_0$food_suitability[i] <- agent_suitability$food_suitability
  agent_state_0$overall_suitability[i] <- agent_suitability$overall_suitability
  
  
}

agent_state_0$persistence_probability <- calc_persistence(agent_state_0$overall_suitability)$p_persist

agent_map(agent_state_0, 201, 'lng', 'lat')

#save in list
agent_population_history <- list()
agent_population_history <- record_agent_population(agent_state_0, agent_population_history, 0)

