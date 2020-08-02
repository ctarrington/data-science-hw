# Goals
Simple Kalman 1-D filter from video X
 * cycle
 * visualization
 
For 1D
 * generate determinisitic observations by passing
   * an initial position (shaped)
   * an initial velocity (shaped)
   * an acceleration function (shaped) based on elapsed time
   * a noise factor (shaped)
   * a simulation resolution (internal step period)
   * a sampling resolution (how often to record an observation)
   * a seed to make it really really deterministic 
   
 * Factor out so a scenario file gets observations, contructs a filter, passes each observations and gets results, accumulates its own df, calls plot utility with df
   
* plot predicted, observed and kalmanized
* before next round of reading experiment some with 
  * make the KG change or revert based on the error between pred and observed
  * make control be based on acceleration calculated from last N observed velocities (or kalmanized velocities)
* given the results of several models, plot model kalmanized with actual

Repeat for 2D and 3D ?

# Resources
