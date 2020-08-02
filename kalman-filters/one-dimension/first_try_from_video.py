import queue

import numpy as np
import pandas as pd

from matplotlib.pyplot import plot
from matplotlib import pyplot as plt

# based on video by Michel van Biezen
# Special Topics - The Kalman Filter

initial_x = 4000
initial_dx = 280
inital_ax = 2

process_error_x = 20
process_error_dx = 5

observation_error_x = 25
observation_error_dx = 6

dt = 1

# initial state
state = np.array([[initial_x], [initial_dx]])

observations = queue.Queue()
observations.put(np.array([[4260], [282]]))
observations.put(np.array([[4550], [285]]))
observations.put(np.array([[4860], [286]]))
observations.put(np.array([[5110], [290]]))

# conditioning matrices
A = np.array([[1, dt], [0, 1]])
A_transposed = A.transpose()
B = np.array([[0.5*dt*dt], [dt]])

# silly in this case since I transposed == I
H = np.identity(2, dtype=int)
H_transposed = H.transpose()

# control matrix ? better name ?
mu_control = np.array([inital_ax])

# observation error matrix
R_observation_error = np.array([[observation_error_x**2, 0], [0, observation_error_dx**2]])

# initial process covariance
# for simplicity the covariances are zeroed out as assumption is independence
# also to match sample
process_covariance = np.array([
    [process_error_x*process_error_x, 0],
    [0, process_error_dx*process_error_dx]
])

print('A\n', A)
print('A_transposed\n', A_transposed)
print('B\n', B)
print('H\n', H)
print('H_transposed\n', H_transposed)
print('mu_control\n', mu_control)
print('R_observation_error \n', R_observation_error )
print('inital state\n', state)

print('process_covariance\n', process_covariance)

# set up a data frame for our results
row = np.array([0, initial_x, initial_dx, initial_x, initial_dx])
row.shape = (1,5)
df = pd.DataFrame(row)

for step in range(observations.qsize()):
    elapsed = (step + 1) * dt
    print('\n\n========', elapsed, ' seconds ==========')

    # increment the process covariance matrix
    # pc = A * PC * Atransposed
    process_covariance = A.dot(process_covariance)
    process_covariance = process_covariance.dot(A_transposed)

    # remove covariances for now to match sample
    process_covariance[0, 1] = 0
    process_covariance[1, 0] = 0
    print('process_covariance at ', elapsed, ' seconds\n', process_covariance)

    # calculate the kalman gain
    top = process_covariance.dot(H_transposed)
    bottom = H.dot(process_covariance)
    bottom = bottom.dot(H_transposed)
    bottom = np.add(bottom, R_observation_error)
    with np.errstate(divide='ignore', invalid='ignore'):
        kalman_gain = np.divide(top, bottom)
    kalman_gain[np.isnan(kalman_gain)] = 0
    print('kalman gain at ', elapsed, ' seconds\n', kalman_gain)


    # calculate the predicted state
    # state = A * state + B * control
    left = A.dot(state)

    # numpy gets confused due to mu_control being 1 by 1
    right = B.dot(mu_control)
    right.shape = (2,1)

    predicted_state = np.add(left, right)
    print('predicted state', elapsed, ' seconds\n', predicted_state)

    observation = observations.get()
    print('observation at ', elapsed, ' seconds\n', observation)

    delta_predicted_observed = np.subtract(observation, np.dot(H, predicted_state))
    state = np.add(predicted_state, kalman_gain.dot(delta_predicted_observed))

    print('\n-- state --', elapsed, ' seconds\n', state)
    row = np.array([elapsed, state[0,0], state[1,0], observation[0,0], observation[1,0]])
    row.shape = (1,5)
    df = df.append(pd.DataFrame(row), ignore_index=True)

    # Note - not updating observation error yet, so KG will diminish each iteration
    # update process covariance
    # covariance = (I - K * H) covariance
    left = np.dot(kalman_gain, H)
    left = np.subtract(np.identity(2, dtype=int), left)
    process_covariance = np.dot(left, process_covariance)
    print('process covarionace', elapsed, ' seconds\n', process_covariance)

df.columns = ['seconds', 'x', 'x_dot', 'observed_x', 'observed_x_dot']
print('df\n', df)

plot(df['seconds'], df['x'], 'o', label='State')
plot(df['seconds'], df['observed_x'], 'o', label='Observed')
plt.legend()
plt.show()
