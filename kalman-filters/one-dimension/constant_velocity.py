import numpy as np
from numpy.random import randn

from matplotlib.pyplot import plot
from matplotlib import pyplot as plt

from filterpy.kalman import KalmanFilter
from filterpy.common import Saver, Q_discrete_white_noise

from filterpy.stats import plot_covariance


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
burn_in = 10
initial_position = 20
velocity = 2
std = 3
dt = 1
ts = range(count)
noise_maker = create_noise_maker(std)
clean_xs = create_linear_data(initial_position=initial_position, velocity=velocity, count=count)
measurements_zs = noise_maker(clean_xs)

kf = KalmanFilter(dim_x=2, dim_z=1)
kf.x = np.array([0, 0])  # default location and velocity

kf.F = np.array([[1., dt],
                 [0., 1.]])  # state transition matrix
kf.H = np.array([[1., 0]])  # Measurement function
kf.R *= std**2  # measurement uncertainty
kf.P *= 1  # covariance matrix
kf.Q = Q_discrete_white_noise(dim=2, dt=dt, var=0.5)


# run the kalman filter and store the results
filtered_xs, cov = [], []
for index, z in enumerate(measurements_zs):
    kf.predict()
    kf.update(z)
    filtered_xs.append(kf.x)
    cov.append(kf.P)
    if index % 5 == 0:
        plot_covariance(kf.x, kf.P, edgecolor='r')
plt.show()


filtered_xs = np.array(filtered_xs)
filtered_xs.shape = (count, 2)

ts = ts[burn_in:]
clean_xs = clean_xs[burn_in:]
measurements_zs = measurements_zs[burn_in:]
filtered_xs = filtered_xs[burn_in:]

plot(ts, clean_xs, label='Actual')
plot(ts, measurements_zs, 'o', label='Measured')
plot(ts, filtered_xs[:,0], 'o', label='Filtered')
plt.ylabel('position')
plt.legend()
plt.show()

plot(ts, filtered_xs[:,1], 'o', label='Filtered')
plt.ylabel('velocity')
plt.legend()
plt.show()

measured_error = measurements_zs - clean_xs
filtered_error = filtered_xs[:,0] - clean_xs
plot(ts, measured_error, 'o', label='Measured')
plot(ts, filtered_error, 'o', label='Filtered')
plt.ylabel('error')
plt.hlines(0, 0, ts[-1])
plt.legend()
plt.show()

improvement = np.abs(measured_error) - np.abs(filtered_error)
plot(ts, improvement, 'o', label='Improvement')
plt.ylabel('improvement')
plt.hlines(0, 0, ts[-1])
plt.legend()
plt.show()

print('mean improvement', np.mean(improvement))