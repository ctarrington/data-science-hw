import queue

import numpy as np
import pandas as pd

from io import StringIO

from ballistic_filter import BallisticFilter

data = StringIO("""
    x,x_dot
    4000,280
    4260,282
    4550,285
    4860,286
    5110,290
    """)

observations_df = pd.read_csv(data)
filter = BallisticFilter(acceleration_x=2,
                         time_step_size=1,
                         process_error_x=20,
                         process_error_dx=5,
                         observation_error_x=25,
                         observation_error_dx=6,
                         verbose=False)


df = pd.DataFrame()
for step, observation in observations_df.iterrows():
    column_vector = observation.to_numpy()
    column_vector.shape = (2, 1)
    state_row = filter.iterate(column_vector)
    df = df.append(pd.DataFrame(state_row), ignore_index=True)

df.columns=['seconds', 'x', 'x_dot']
print('df\n', df)

# todo add plots
