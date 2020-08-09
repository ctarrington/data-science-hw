import numpy as np
import pandas as pd

from matplotlib.pyplot import plot
from matplotlib import pyplot as plt


def convert_observations_to_data_frame(vectors, dt=1):
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


def plot_states(actual_df, observed_df, filtered_df):
    for attribute in ('x', 'x_dot'):
        plot(actual_df['seconds'], actual_df[attribute], 'o', alpha=0.5, label='Actual')
        plot(observed_df['seconds'], observed_df[attribute], 'o', alpha=0.5, label='Observed')
        plot(filtered_df['seconds'], filtered_df[attribute], 'o', alpha=0.5, label='Filtered')
        plt.ylabel(attribute, rotation=90)
        plt.legend()
        plt.show()


def plot_noise(actual_df, observed_df, filtered_df):
    noise = observed_df - actual_df
    filtered_noise = filtered_df - actual_df
    last_time = actual_df['seconds'].tail(1).item()
    for attribute in ('x', 'x_dot'):
        plot(filtered_df['seconds'], noise[attribute], 'o', label='Noise')
        plot(filtered_df['seconds'], filtered_noise[attribute], 'o', label='Filtered Noise')
        plt.hlines(0, 0, last_time)
        plt.ylabel(attribute, rotation=90)
        plt.legend()
        plt.show()


def plot_improvement(actual_df, observed_df, filtered_df):
    noise = actual_df - observed_df
    filtered_noise = actual_df - filtered_df
    for attribute in ('x', 'x_dot'):
        improvement = noise[attribute].abs() - filtered_noise[attribute].abs()
        plot(actual_df['seconds'], improvement, 'o', label='Improvement')
        plt.ylabel(attribute, rotation=90)
        plt.legend()
        plt.show()
