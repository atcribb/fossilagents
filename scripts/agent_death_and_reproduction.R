#Starting with a dataframe of initialised agents that already have suitability scores and persistence probabilities 
#(see scripts/agent_population_suitabilities.R)
#call initial agent population agent_state_0 in this example

library(R.utils)
sourceDirectory('R/', modifiedOnly=FALSE)

agent_death_outcomes <- agent_death(agent_state_0, 0.05)
agent_state_postdeath <- agent_death_outcomes$surviving_agents
dead_agents_state_1 <- agent_death_outcomes$dead_agents 
agent_reproduce_outcomes <- agents_reproduce(agent_state_postdeath, 0.4, 1)
new_agent_state <- rbind(agent_state_0, agent_reproduce_outcomes$child_agent_population)
