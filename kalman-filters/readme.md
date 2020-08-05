# Goals
Simple Kalman 1-D filter from video X
 * cycle x
 * visualization x
 
For 1D
 * factor out first model  X
 
 * generate determinisitic observations by passing
   * an initial position X
   * an initial velocity X
   * an acceleration function  based on elapsed time - need sample
   * a noise factor 
   * a simulation resolution (internal step period) x
   * a sampling resolution (how often to record an observation) x
   * a seed to make it really really deterministic - need to test w noise
   
 * Factor out so a scenario file
   * gets observations as a DataFrame x
   * contructs a filter X
   * passes each observations and gets results X
   * accumulates results in a DataFrame X
   * calls plot utility with DataFrame
   * calls diagnostics on filter
   * plot real (0 noise), observed and kalmanized
   
* before next round of reading experiment some with 
  * make the KG change or revert based on the error between pred and observed
  * make control be based on acceleration calculated from last N observed velocities (or kalmanized velocities)
  * rubustness if model is wrong
  
* given the results of several models, plot model kalmanized with actual

Repeat for 2D and 3D ?

# Resources
