import numpy as np
import pandas as pd


from ballistic_filter import BallisticFilter
from ballistic_data import BallisticData

filter = BallisticFilter(acceleration_x=2,
                         time_step_size=1,
                         process_error_x=20,
                         process_error_dx=5,
                         observation_error_x=25,
                         observation_error_dx=6,
                         verbose=False)


observations = BallisticData(0, 0, lambda t: 2)

df = pd.DataFrame()
for observation in observations:
    state_row = filter.iterate(observation)
    df = df.append(pd.DataFrame(state_row), ignore_index=True)

df.columns=['seconds', 'x', 'x_dot']
print('df\n', df)
