import numpy as np
import pandas as pd


from ballistic_filter import BallisticFilter
from ballistic_data import BallisticData

x_std = 1
x_dot_std = 2

filter = BallisticFilter(acceleration_x=2,
                         time_step_size=1,
                         process_error_x=20,
                         process_error_dx=5,
                         observation_error_x=x_std**2,
                         observation_error_dx=x_dot_std**2,
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

kalmanized_df = pd.DataFrame()
for observation in observations:
    state_row = filter.iterate(observation)
    kalmanized_df = kalmanized_df.append(pd.DataFrame(state_row), ignore_index=True)

kalmanized_df.columns=['seconds', 'x', 'x_dot']
print('kalmanized_df\n', kalmanized_df )

actual_df = pd.DataFrame()
seconds = 0
for observation in noiseless_observations:
    state_row = np.array([seconds, observation[0][0], observation[1][0]])
    state_row.shape = (1,3)
    actual_df = actual_df.append(pd.DataFrame(state_row), ignore_index=True)
    seconds = seconds + 1

actual_df.columns=['seconds', 'x', 'x_dot']
print('actual_df\n', actual_df)

observed_df = pd.DataFrame()
seconds = 0
for observation in observations:
    state_row = np.array([seconds, observation[0][0], observation[1][0]])
    state_row.shape = (1,3)
    observed_df = observed_df.append(pd.DataFrame(state_row), ignore_index=True)
    seconds = seconds + 1

observed_df.columns=['seconds', 'x', 'x_dot']
print('observed_df\n', observed_df)
