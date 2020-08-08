import numpy as np
import pandas as pd

from ballistic_data import BallisticData
from ballistic_filter import BallisticFilter
from utils import convert_observations_to_data_frame, filter_observations

x_std = 1
x_dot_std = 2

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
                             max_iterations=20)

noiseless_observations = BallisticData(initial_x=0,
                                       initial_x_dot=0,
                                       acceleration_function=lambda x: 2,
                                       noise=(0, 0),
                                       max_iterations=20)

kalmanized_df = filter_observations(kf, observations)
print('kalmanized_df\n', kalmanized_df)

actual_df = convert_observations_to_data_frame(noiseless_observations)
print('actual_df\n', actual_df)

observed_df = convert_observations_to_data_frame(observations)
print('observed_df\n', observed_df)
