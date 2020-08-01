import numpy as np
import pandas as pd

initial_x = 4000
initial_dx = 280
inital_ax = 2

process_error_x = 20
process_error_dx = 5

dt = 1


state = np.array([[initial_x], [initial_dx]])

A = np.array([[1, dt], [0, 1]])
B = np.array([[0.5*dt*dt], [dt]])
mu = np.array([inital_ax])

print('A', A)
print('B', B)
print('mu', mu)
print('inital state\n', state)

row = np.array([0, initial_x, initial_dx])
row.shape = (1,3)
df = pd.DataFrame(row)

for step in range(10):
    # state = A * state + B * mu

    left = A.dot(state)

    # numpy gets confused due to mu being 1 by 1
    right = B.dot(mu)
    right.shape = (2,1)

    state = np.add(left, right)

    elapsed = (step+1)*dt
    # print('\n----', elapsed, ' seconds\n', state)
    row = np.array([elapsed, state[0,0], state[1,0]])
    row.shape = (1,3)
    df = df.append(pd.DataFrame(row), ignore_index=True)

df.columns = ['seconds', 'x', 'x_dot']
print('df\n', df)

