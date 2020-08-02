import queue

import numpy as np
import pandas as pd

from ballistic_filter import BallisticFilter

# todo convert from Queue to df?
observations = queue.Queue()
observations.put(np.array([[4000], [280]]))
observations.put(np.array([[4260], [282]]))
observations.put(np.array([[4550], [285]]))
observations.put(np.array([[4860], [286]]))
observations.put(np.array([[5110], [290]]))

filter = BallisticFilter(acceleration_x=2,
                         time_step_size=1,
                         process_error_x=20,
                         process_error_dx=5,
                         observation_error_x=25,
                         observation_error_dx=6,
                         verbose=False)


df = pd.DataFrame()

for step in range(observations.qsize()):
    observation = observations.get()
    row = filter.iterate(observation)
    df = df.append(pd.DataFrame(row), ignore_index=True)

df.columns=['seconds', 'x', 'x_dot']
print('df\n', df)

# todo add plots
