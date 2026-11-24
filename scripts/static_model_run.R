#Model run on a static cGENIE reconstruction
#Example for workflow development

set.seed(541)

#=== Load packages and functions ===#
library(rgplates)
library(ggplot2)
library(palaeoverse)
library(PaleoClimR)
library(R.utils)
sourceDirectory('R/', modifiedOnly=FALSE)

#=== additional data input: cGENIE reconstruction file ===#
#This will change for you based on your environmental data input:
world_state <- "~/Desktop/Manucripts/phanero_cgenie/muffin.CB.L23z_201_z32.BASES-1.config"

#=== Step 1: Initialise agent population ===#
#This script never needs to change, so we can just run it at the start of every model
make_initial_map <- TRUE
source('scripts/initialise_agent_population.R')

#Worth checking everything looks okay
View(agent_population_history)
View(agent_population_history$timestep_0)
agent_population_history$timestep_0 <- subset(agent_population_history$timestep_0, !is.na(overall_suitability))

#=== Step 2: Run timesteps ===#
timesteps <- 20
for(t in 1:timesteps){
  
  agent_population_history <- update_agents(agents=agent_population_history[[t]],
                              timestep=t,
                              history_list=agent_population_history,
                              world_file=world_state,
                              carrying_capacity=500)
  
}












