#Function to calculate probability of persistence to the next model step
#Note: an agent is closer to representing a population of model organisms rather than an individual
#Hazard-based survival: P_persist = exp(-(background_hazard + stress_sensitivity*((1-Suitability)^curve_decay)))
#or, P_persist = exp(-lambda*dt) and lambda = background_hazard + stress_sensitivty*(1-Suitability)^curve_decay

#Default shape for 10,000 year timesteps and a hazard function that has little persistence probability at the low end and high persistence probability at the high end, sharp increase

calc_persistence <- function(suitability_score,
                             dt=10000, #years
                             background_hazard = 0.03,
                             stress_sensitivity = 5.8,
                             curve_decay = 3.0
){
  
  #conversions
  lambda_0 <- background_hazard/dt
  lambda_stress <- stress_sensitivity/dt
  gamma_value <- curve_decay

  #formulate and solve hazard function
  lambda <- lambda_0 + lambda_stress * (1-suitability_score)^gamma_value
  p_persist <- exp(-lambda*dt)

  return(list(p_persist=p_persist))

}


#====== visualisation of the hazard-based function ======#
# persistence_curve <- data.frame(suitability=seq(from=0, to=1, by=0.02))
# persistence_curve$p_persistence <- calc_persistence(persistence_curve$suitability)$p_persist
# persistence_curve_vis <- ggplot(persistence_curve, aes(x=suitability, y=p_persistence)) +
#   geom_line() +
#   geom_point(aes(fill=p_persistence), shape=21, size=2) +
#   scale_fill_viridis_c(option='D') +
#   scale_x_continuous('Suitability score') +
#   scale_y_continuous('Probability of agent persisting to next timestep') +
#   theme_bw() +
#   theme(legend.position='none')
# persistence_curve_vis 
# 
