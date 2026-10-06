#Initialise a population of agents

set.seed(201)

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
    geom_sf(data=fossils_transformed, fill='#adc178', col='black', shape=21, size=2) + #add fill aes here to code for eukaryotes vs prokaryotes, etc.
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

init_population <- function(fossil_data, ecophysiotype_group,
                            ecophysiotype_group_column, lat_column, lng_column, 
                            total_ecophysiotype_population,
                            subsample_cell_size,
                            subsample_cell_threshold,
                            map_output=TRUE){
  
  
  #=== Defense ===#
  if(!is.data.frame(fossil_data)){ #input data must be a dataframe 
    stop("Input data must be a dataframe.")
  }
  if(!is.character(c(ecophysiotype_group_column, lat_column, lng_column))){#column names must be strings
    stop("Column names must be characters or strings.")
  }
  if(!(ecophysiotype_group %in% unique(fossil_data[,ecophysiotype_group_column]))){ #ecophysiotype group must exist in the given column
    stop("Ecophysiotype group not found in input data.")
  }
  
  if(any(is.na(fossil_data[,ecophysiotype_group_column]))){ 
    warning("Please note that some of your input data do not have assigned ecophysiotype groups. Continuing with data that is available.")
  }
  if(any(is.na(fossil_data[,c(lat_column,lng_column)]))){
    stop('Values in coordinate columns cannot be empty.')
  }
  if(length(fossil_data[which(!is.numeric(fossil_data[,lat_column]))]) > 0 | length(fossil_data[which(!is.numeric(fossil_data[,lng_column]))])){
    stop('Values in coordinate columns must be numeric')
  }
  if(length(total_ecophysiotype_population) != 1L ||
     !is.numeric(total_ecophysiotype_population)){
    stop("Total agent population must be one positive whole number.")
  }
  if(is.na(total_ecophysiotype_population) ||
     !is.finite(total_ecophysiotype_population) ||
     total_ecophysiotype_population < 1 ||
     total_ecophysiotype_population != floor(total_ecophysiotype_population) ||
     total_ecophysiotype_population > .Machine$integer.max){
    stop("Total agent population must be one positive whole number.")
  }

  #=== spatially normalise data ===#
  #load subsampling functions
  devtools::source_url("https://raw.githubusercontent.com/atcribb/EPME_bioturbators/main/R/subsampling_functions.R")
  subsampled_data <- subsample_space(fossil_data, subsample_cell_size, subsample_cell_threshold)
  
  if(!("cell_ID" %in% names(subsampled_data))){
    stop("Input data must contain a 'cell_ID' column.")
  }
  if(any(is.na(subsampled_data$cell_ID))){
    stop("Values in the 'cell_ID' column cannot be empty.")
  }
  
  
  #=== subset out ecophysiotype data ===#
  ecophysiotype_data <- subsampled_data[which(subsampled_data[,ecophysiotype_group_column]==ecophysiotype_group),]
  if(nrow(ecophysiotype_data) == 0L){
    stop("No records for the selected ecophysiotype remain after spatial subsampling. Try adjusting your subsampling parameters, or discard ecophysiotype group as too rare.")
  }
  
  #=== allocate the agent population among occupied cells ===#
  # Preserve the cell order produced by subsample_space() so that allocation and rounding are reproducible, including when two cells have equal weights.
  all_cell_ids <- unique(subsampled_data$cell_ID)
  n_all_occurrences <- tabulate(
    match(subsampled_data$cell_ID, all_cell_ids),
    nbins=length(all_cell_ids)
  )
  n_ecophysiotype_occurrences <- tabulate(
    match(ecophysiotype_data$cell_ID, all_cell_ids),
    nbins=length(all_cell_ids)
  )
  
  cell_population <- data.frame(
    cell_ID=all_cell_ids,
    n_all_occurrences=n_all_occurrences,
    n_ecophysiotype_occurrences=n_ecophysiotype_occurrences,
    stringsAsFactors=FALSE
  )
  
  # Only cells occupied by the selected ecophysiotype become local populations. 
  # The denominator includes every retained occurrence in each cell and therefore reduces the influence of uneven fossil sampling effort.
  cell_population <- cell_population[
    cell_population$n_ecophysiotype_occurrences > 0L,
    ,
    drop=FALSE
  ]
  cell_population$sampling_normalised_score <-
    cell_population$n_ecophysiotype_occurrences /
    cell_population$n_all_occurrences
  cell_population$normalised_weight <-
    cell_population$sampling_normalised_score /
    sum(cell_population$sampling_normalised_score)
  
  n_occupied_cells <- nrow(cell_population)
  if(total_ecophysiotype_population < n_occupied_cells){
    stop(
      paste0(
        "Total agent population must be at least ",
        n_occupied_cells,
        " so every occupied cell is represented."
      )
    )
  }
  
  # Reserve one agent for each observed occupied cell. 
  # Allocate the remaining agents in proportion to the sampling-normalised weights so that the known initial geographic range is retained in the simulation.
  n_agents_remaining <- total_ecophysiotype_population - n_occupied_cells
  unrounded_agents <- cell_population$normalised_weight * n_agents_remaining
  additional_agents <- floor(unrounded_agents)
  n_agents_to_round <- n_agents_remaining - sum(additional_agents)
  
  # Largest-remainder rounding gives integer cell populations whose sum is exactly total_ecophysiotype_population. Original cell order resolves exact ties.
  if(n_agents_to_round > 0L){
    rounding_order <- order(
      -(unrounded_agents - additional_agents),
      seq_len(n_occupied_cells)
    )
    cells_to_increment <- rounding_order[seq_len(n_agents_to_round)]
    additional_agents[cells_to_increment] <-
      additional_agents[cells_to_increment] + 1L
  }
  cell_population$n_agents <- as.integer(1L + additional_agents)
  
  
  #== initiate columns for output data ==#
  agent_columns <- c('agent_id',
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
                     'lng'
                     )
  
  #=== create agent population data frame ===#
  # Begin with missing values so that traits and physiological tolerances can
  # be populated once their initialisation rules have been defined.
  agent_population <- as.data.frame(
    matrix(
      NA,
      nrow=sum(cell_population$n_agents),
      ncol=length(agent_columns)
    )
  )
  colnames(agent_population) <- agent_columns
  
  # Create consecutive blocks of agents for each occupied cell. 
  # Agent IDs are unique within this ecophysiotype population, while group_tag records the ecophysiotype shared by every agent returned by this function call.
  next_agent_row <- 1L
  for(i in seq_len(nrow(cell_population))){
    n_cell_agents <- cell_population$n_agents[i]
    cell_agent_rows <- seq.int(
      from=next_agent_row,
      length.out=n_cell_agents
    )
    cell_occurrence_rows <- which(
      ecophysiotype_data$cell_ID == cell_population$cell_ID[i]
    )
    
    agent_population$agent_id[cell_agent_rows] <- cell_agent_rows
    agent_population$group_tag[cell_agent_rows] <- ecophysiotype_group
    
    # Place the local population at the mean palaeocoordinate of the selected ecophysiotype's retained occurrences within its spatial cell.
    agent_population$lat[cell_agent_rows] <- mean(
      ecophysiotype_data[[lat_column]][cell_occurrence_rows]
    )
    agent_population$lng[cell_agent_rows] <- mean(
      ecophysiotype_data[[lng_column]][cell_occurrence_rows]
    )
    
    next_agent_row <- max(cell_agent_rows) + 1L
  }
  
  

  
  if(map_output==FALSE){
     return(agent_population)
  }
  if(map_output==TRUE){
    return(agent_population)
  }
  
  
}

table(ETE_ecospace$FG_Number)
test <- init_population(fossil_data=ETE_ecospace, 
                        ecophysiotype_group="115", 
                        ecophysiotype_group_column="FG_Number", 
                        lat_column = "p_lat", 
                        lng_column = "p_lng", 
                        subsample_cell_size = 275,
                        subsample_cell_threshold = 15,
                        total_ecophysiotype_population = 55, 
                        map_output = TRUE
                        )
test


checking <- subset(ETE_ecospace, FG_Number=="115")
View(checking)

map_it(test, 201, "lng", "lat")
