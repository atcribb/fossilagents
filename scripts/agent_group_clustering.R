# Set agent groups based on hierarchical cluster analysis

#==== packages ====#
library(ggplot2)
library(cluster)
library(factoextra)
library(dynamicTreeCut)

#==== data input ====#
load('data/genera_traits_data.RData')
#remove functional group number columns, as we won't use these in the cluster analysis because they have been decomposed
genera_traits <- genera_traits[,c(1,5:16)]
rownames(genera_traits) <- genera_traits$genus

#remove data where IQRs are zero -> insufficient data to group into clusters 
genera_traits <- subset(genera_traits, temp_IQR > 0.00)
genera_traits <- subset(genera_traits, O2_IQR > 0.00)
genera_traits <- subset(genera_traits, Cexp_IQR > 0.00)


#==== create orders =====#
#Binary values for sediment-associated or non-sediment-associated 
genera_traits$sediment_associated <- ifelse(
  genera_traits$sediment_relationship == 'none',
  0,
  1
)

#ordered sequence for sediment position: none (pelagic) --> surface --> partially buried --> buried
genera_traits$sediment_position <- genera_traits$sediment_relationship
genera_traits$sediment_position[genera_traits$sediment_position=='none'] <- NA
genera_traits$sediment_position <- ordered(
  genera_traits$sediment_position, 
  levels=c('water column', 'surface-associated', 'partially buried', 'buried')
)

#ordere sequnce for infaunal depth
genera_traits$depth_for_distance <- genera_traits$infaunal_depth
genera_traits$depth_for_distance[genera_traits$sediment_relationship=='none'] <- NA
genera_traits$depth_for_distance <- ordered(
  genera_traits$depth_for_distance, 
  levels=c('none', 'very shallow', 'shallow', 'deep')
)


#==== calculating Gower distances for ecological traits ====#
#Distances for tiering:
tiering_data <- genera_traits[,c('sediment_associated', 'sediment_position', 'depth_for_distance')]
D_tiering <- cluster::daisy(tiering_data, metric='gower', 
                            type=list(symm='sediment_associated')) #noting binary variable 

#Distances for motility:
genera_traits$mobility_ord <- ordered(
  genera_traits$mobility,
  levels=c('stationary', 'facultative', 'high', 'very high')
)
genera_traits$attached_yn <- ifelse(
  genera_traits$attachment=='attached',
  1,
  0
)
motility_data <- genera_traits[,c('mobility_ord','attached_yn')]
D_motility <- cluster::daisy(motility_data, metric='gower',
                             type=list(symm='attached_yn'), #noting binary variable 
                             weights=c(2,1)) #weighting so that higher mobility is more similar, etc. -- could sensitivity test this 

#Distances for feeding:
genera_traits$resource_location_fact <- factor(genera_traits$resource_location)
genera_traits$resource_acquisition_fact <- factor(genera_traits$resource_acquisition)
feeding_data <- genera_traits[,c('resource_location_fact', 'resource_acquisition_fact')]
D_feeding <- cluster::daisy(feeding_data, metric='gower') 

D_tiering_mat <- as.matrix(D_tiering)
D_feeding_mat <- as.matrix(D_feeding)
D_motility_mat <- as.matrix(D_motility)

#check that row names are aligned
identical(rownames(D_tiering_mat),rownames(D_motility_mat))
identical(rownames(D_tiering_mat),rownames(D_feeding_mat))

#Give each ecological trait equal contribution to functionale cology
D_ecological_mat <- (D_tiering_mat + D_motility_mat + D_feeding_mat)/3


#==== calculating Gower distance for climate traits =====#
temperature_data <- genera_traits[,c('temp_med', 'temp_IQR')]
D_temp <- cluster::daisy(temperature_data, metric='gower')

oxygen_data <- genera_traits[,c('O2_med', 'O2_IQR')]
D_oxy <- cluster::daisy(oxygen_data, metric='gower')

Cexp_data <- genera_traits[,c('Cexp_med', 'Cexp_IQR')]
D_food <- cluster::daisy(Cexp_data, metric='gower')

#check row names are aligned
identical(rownames(D_temp),rownames(D_oxy))
identical(rownames(D_temp),rownames(D_food))

#combine into climate distance giving equal weights to each variable 
D_temp_mat <- as.matrix(D_temp)
D_oxy_mat <- as.matrix(D_oxy)
D_food_mat <- as.matrix(D_food)
D_climate_mat <- (D_temp_mat + D_oxy_mat + D_food_mat)/3

#==== combine into full functional ecology and climatic niche ====#
D_niche_mat <- (0.5*D_ecological_mat + 0.5*D_climate_mat) #equally weighted 
D_total <- as.dist(D_niche_mat)


#=========== Hierarchical clustering analysis -- how many k? ==================#
#Choices: agglomerative
#Compare complete and average linkages 
methods <- c(average='average', complete='complete', single='single')
agg_coeff <- sapply(methods, function(m){
  cluster::agnes(D_total, stand=TRUE, metric='euclidean', method=m)$ac
})
agg_coeff #complete linkages give highest agglomerative coefficient, but they're both high
eco_clusters <- hclust(D_total, method='complete')
fviz_dend(eco_clusters, cex=0.1)

#now need to cut that tree... test different heights 
heights <- seq(0.1, 0.2, 0.01)
height_grps <- sapply(heights, function(hs){
  length(names(table(cutree(eco_clusters, h=hs))))
})
data.frame(h=heights, k=height_grps) #check it out 

choose_k <- 20

fviz_dend(eco_clusters, k=choose_k,
          cex=0.1,
          rect=TRUE)

eco_grps <- cutree(eco_clusters, k=choose_k)
fviz_cluster(list(data=D_total, cluster=eco_grps),
             ellipse.type='convex')


#=== validation: cluster-traits table ===#
genera_traits$cluster <- eco_grps

get_mode <- function(x) {
  counts <- table(x)
  mode_value <- names(counts)[which.max(counts)]
  mode_prop <- max(counts) / sum(counts)
  return(
    c(
      mode = mode_value,
      proportion = mode_prop
    )
  )
}

clusters <- sort(unique(genera_traits$cluster))

cluster_characterization <- data.frame(
  cluster = clusters,
  n_genera = NA_integer_,
  
  dominant_sediment_relationship = NA_character_,
  sediment_relationship_prop = NA_real_,
  
  dominant_infaunal_depth = NA_character_,
  infaunal_depth_prop = NA_real_,
  
  dominant_mobility = NA_character_,
  mobility_prop = NA_real_,
  
  dominant_attachment = NA_character_,
  attachment_prop = NA_real_,
  
  dominant_resource_location = NA_character_,
  resource_location_prop = NA_real_,
  
  dominant_resource_acquisition = NA_character_,
  resource_acquisition_prop = NA_real_,
  
  temp_med = NA_real_,
  temp_IQR = NA_real_,
  
  O2_med = NA_real_,
  O2_IQR = NA_real_,
  
  Cexp_med = NA_real_,
  Cexp_IQR = NA_real_
)

for (i in seq_along(clusters)) {
  
  cluster_id <- clusters[i]
  
  cluster_data <- genera_traits[
    genera_traits$cluster == cluster_id,
  ]
  
  cluster_characterization$n_genera[i] <-
    nrow(cluster_data)
  
  
  # Tiering
  
  result <- get_mode(
    cluster_data$sediment_relationship
  )
  
  cluster_characterization$dominant_sediment_relationship[i] <-
    result["mode"]
  
  cluster_characterization$sediment_relationship_prop[i] <-
    as.numeric(result["proportion"])
  
  
  result <- get_mode(
    cluster_data$infaunal_depth
  )
  
  cluster_characterization$dominant_infaunal_depth[i] <-
    result["mode"]
  
  cluster_characterization$infaunal_depth_prop[i] <-
    as.numeric(result["proportion"])
  
  
  # Motility
  
  result <- get_mode(
    cluster_data$mobility
  )
  
  cluster_characterization$dominant_mobility[i] <-
    result["mode"]
  
  cluster_characterization$mobility_prop[i] <-
    as.numeric(result["proportion"])
  
  
  result <- get_mode(
    cluster_data$attachment
  )
  
  cluster_characterization$dominant_attachment[i] <-
    result["mode"]
  
  cluster_characterization$attachment_prop[i] <-
    as.numeric(result["proportion"])
  
  
  # Feeding
  
  result <- get_mode(
    cluster_data$resource_location
  )
  
  cluster_characterization$dominant_resource_location[i] <-
    result["mode"]
  
  cluster_characterization$resource_location_prop[i] <-
    as.numeric(result["proportion"])
  
  
  result <- get_mode(
    cluster_data$resource_acquisition
  )
  
  cluster_characterization$dominant_resource_acquisition[i] <-
    result["mode"]
  
  cluster_characterization$resource_acquisition_prop[i] <-
    as.numeric(result["proportion"])
  
  
  # Environmental niche
  
  cluster_characterization$temp_med[i] <-
    median(
      cluster_data$temp_med,
      na.rm = TRUE
    )
  
  cluster_characterization$temp_IQR[i] <-
    median(
      cluster_data$temp_IQR,
      na.rm = TRUE
    )
  
  cluster_characterization$O2_med[i] <-
    median(
      cluster_data$O2_med,
      na.rm = TRUE
    )
  
  cluster_characterization$O2_IQR[i] <-
    median(
      cluster_data$O2_IQR,
      na.rm = TRUE
    )
  
  cluster_characterization$Cexp_med[i] <-
    median(
      cluster_data$Cexp_med,
      na.rm = TRUE
    )
  
  cluster_characterization$Cexp_IQR[i] <-
    median(
      cluster_data$Cexp_IQR,
      na.rm = TRUE
    )
}

View(cluster_characterization)



#==== finally, create agent group cluster dataset =====#



