import numpy as np
from numpy.random import randn

from matplotlib.pyplot import plot
from matplotlib import pyplot as plt

from filterpy.kalman import KalmanFilter
from filterpy.common import Q_discrete_white_noise


def create_linear_data(initial_position=0, velocity=1, count=10, dt=1):
    xs = []
    position = initial_position
    for ctr in range(count):
        xs.append(position + ctr * dt * velocity)

    return np.array(xs)


def create_noise_maker(std=1):
    nm = lambda x: x + randn() * std
    return np.vectorize(nm)


count = 50
initial_position = 20
velocity = 2
std = 2
dt = 1
ts = range(count)
noise_maker = create_noise_maker(std)
clean_xs = create_linear_data(initial_position=initial_position, velocity=velocity, count=count)
measurements_zs = noise_maker(clean_xs)

kf = KalmanFilter(dim_x=2, dim_z=1)
kf.x = np.array([initial_position, velocity])  # location and velocity
kf.F = np.array([[1., dt],
                 [0., 1.]])  # state transition matrix
kf.H = np.array([[1., 0]])  # Measurement function
kf.R *= std**2  # measurement uncertainty
kf.P *= 1  # covariance matrix
kf.Q = Q_discrete_white_noise(dim=2, dt=dt, var=0.5)

# run the kalman filter and store the results
filtered_xs, cov = [], []
for z in measurements_zs:
    kf.predict()
    kf.update(z)
    filtered_xs.append(kf.x)
    cov.append(kf.P)

filtered_xs = np.array(filtered_xs)
filtered_xs.shape = (count, 2)

plot(ts, clean_xs, label="Actual")
plot(ts, measurements_zs, 'o', label="Measured")
plot(ts, filtered_xs[:,0], 'o', label="Filtered")
plt.legend()
plt.show()