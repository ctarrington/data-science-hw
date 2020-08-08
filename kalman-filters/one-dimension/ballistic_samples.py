from matplotlib.pyplot import plot
from matplotlib import pyplot as plt

from ballistic_data import BallisticData
from ballistic_filter import BallisticFilter
from utils import convert_observations_to_data_frame, filter_observations, plot_states, plot_noise, plot_improvement

x_std = 1
x_dot_std = 2
max_iterations = 100

kf = BallisticFilter(acceleration_x=2,
                     time_step_size=1,
                     process_error_x=20,
                     process_error_dx=5,
                     observation_error_x=x_std ** 2,
                     observation_error_dx=x_dot_std ** 2,
                     verbose=False)

observations = BallisticData(initial_x=0,
                             initial_x_dot=0,
                             acceleration_function=lambda x: 2,
                             noise=(x_std, x_dot_std),
                             max_iterations=max_iterations)

noiseless_observations = BallisticData(initial_x=0,
                                       initial_x_dot=0,
                                       acceleration_function=lambda x: 2,
                                       noise=(0, 0),
                                       max_iterations=max_iterations)

filtered_df = filter_observations(kf, observations)
print('filtered_df\n', filtered_df)

actual_df = convert_observations_to_data_frame(noiseless_observations)
print('actual_df\n', actual_df)

observed_df = convert_observations_to_data_frame(observations)
print('observed_df\n', observed_df)

plot_states(actual_df, observed_df, filtered_df)
plot_noise(actual_df, observed_df, filtered_df)
plot_improvement(actual_df, observed_df, filtered_df)


