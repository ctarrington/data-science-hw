import numpy as np
import pandas as pd


def convert_observations_to_data_frame(vectors, dt = 1):
    df = pd.DataFrame()
    time = 0
    for vector in vectors:
        row = np.array([time, vector[0][0], vector[1][0]])
        row.shape = (1, 3)
        df = df.append(pd.DataFrame(row), ignore_index=True)
        time = time + dt

    df.columns = ['seconds', 'x', 'x_dot']
    return df


def filter_observations(kf, observations):
    df = pd.DataFrame()
    for observation in observations:
        state_row = kf.iterate(observation)
        df = df.append(pd.DataFrame(state_row), ignore_index=True)

    df.columns = ['seconds', 'x', 'x_dot']
    return df