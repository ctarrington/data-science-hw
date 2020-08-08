import numpy as np

class BallisticFilter:
    def __init__(self,
                 acceleration_x,
                 time_step_size,
                 process_error_x,
                 process_error_dx,
                 observation_error_x,
                 observation_error_dx,
                 verbose = False):
        self.acceleration_x = acceleration_x
        self.dt = time_step_size
        self.process_error_x = process_error_x
        self.process_error_dx = process_error_dx

        self.observation_error_x = observation_error_x
        self.observation_error_dx = observation_error_dx
        self.verbose = verbose

        self.step = 0

    def initialize(self, observation):
        # initialize all the things
        self.state = observation

        # Note: a lot of these instance varaibles could be class variables. But brittle?

        # conditioning matrices
        self.A = np.array([[1, self.dt], [0, 1]])
        self.A_transposed = self.A.transpose()
        self.B = np.array([[0.5*self.dt**2], [self.dt]])

        # silly in this case since I transposed == I
        self.H = np.identity(2, dtype=int)
        self.H_transposed = self.H.transpose()

        # control matrix ? better name ?
        self.mu_control = np.array([self.acceleration_x])

        # observation error matrix
        self.R_observation_error = np.array([[self.observation_error_x**2, 0], [0, self.observation_error_dx**2]])

        # initial process covariance
        # zero out covariances since we have no reason to believe process errors are corelated
        self.process_covariance = np.array([
            [self.process_error_x**2, 0],
            [0, self.process_error_dx**2]
        ])

        if self.verbose:
            print('A\n', self.A)
            print('A_transposed\n', self.A_transposed)
            print('B\n', self.B)
            print('H\n', self.H)
            print('H_transposed\n', self.H_transposed)
            print('mu_control\n', self.mu_control)
            print('R_observation_error \n', self.R_observation_error )
            print('inital state\n', self.state)
            print('process_covariance\n', self.process_covariance)

        self.step = self.step + 1
        row = np.append([0], self.state)
        row.shape = (1,3)
        return row

    def iterate(self, observation):
        if self.step == 0:
            return self.initialize(observation)

        elapsed = (self.step) * self.dt
        if self.verbose:
            print('\n\n========', elapsed, ' seconds ==========')

        # increment the process covariance matrix
        # pc = A * PC * Atransposed
        self.process_covariance = self.A.dot(self.process_covariance)
        self.process_covariance = self.process_covariance.dot(self.A_transposed)

        # remove covariances for now - no reason to believe they are dependent
        self.process_covariance[0, 1] = 0
        self.process_covariance[1, 0] = 0

        if self.verbose:
            print('process_covariance at ', elapsed, ' seconds\n', self.process_covariance)

        # calculate the kalman gain
        top = self.process_covariance.dot(self.H_transposed)
        bottom = self.H.dot(self.process_covariance)
        bottom = bottom.dot(self.H_transposed)
        bottom = np.add(bottom, self.R_observation_error)
        with np.errstate(divide='ignore', invalid='ignore'):
            kalman_gain = np.divide(top, bottom)
        kalman_gain[np.isnan(kalman_gain)] = 0

        if self.verbose:
            print('kalman gain at ', elapsed, ' seconds\n', kalman_gain)


        # calculate the predicted state
        # state = A * state + B * control
        left = self.A.dot(self.state)

        # numpy gets confused due to mu_control being 1 by 1
        right = self.B.dot(self.mu_control)
        right.shape = (2,1)

        predicted_state = np.add(left, right)

        if self.verbose:
            print('predicted state', elapsed, ' seconds\n', predicted_state)
            print('observation at ', elapsed, ' seconds\n', observation)

        delta_predicted_observed = np.subtract(observation, np.dot(self.H, predicted_state))
        self.state = np.add(predicted_state, kalman_gain.dot(delta_predicted_observed))

        if self.verbose:
            print('\n-- state --', elapsed, ' seconds\n', self.state)

        # Note - not updating observation error yet, so KG will diminish each iteration
        # update process covariance
        # covariance = (I - K * H) covariance
        left = np.dot(kalman_gain, self.H)
        left = np.subtract(np.identity(2, dtype=int), left)
        self.process_covariance = np.dot(left, self.process_covariance)

        if self.verbose:
            print('process covarionace', elapsed, ' seconds\n', self.process_covariance)

        self.step = self.step + 1
        row = np.append([elapsed], self.state)
        row.shape = (1,3)
        return row


# todo add a plot details?


