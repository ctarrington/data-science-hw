import numpy as np

class BallisticData:
    def __init__(self, initial_x, initial_x_dot, acceleration_function, noise = 1, steps_per_iteration = 500, time_per_iteration = 1, max_iterations = 5, seed = 123):
        self.x = initial_x
        self.x_dot = initial_x_dot
        self.acceleration_function = acceleration_function
        self.steps_per_iteration = steps_per_iteration
        self.time_per_iteration = time_per_iteration
        self.max_iterations = max_iterations
        self.seed = seed

        self.step = 0
        self.iterations = 0
        self.step_time = time_per_iteration / steps_per_iteration


    def __iter__(self):
        return self

    def __increment_step(self):
        current_time = self.step*self.step_time
        acceleration = self.acceleration_function(current_time)
        old_x_dot = self.x_dot
        self.x_dot = self.x_dot + acceleration * self.step_time
        adjusted_x_dot = (old_x_dot + self.x_dot) /2
        self.x = self.x + adjusted_x_dot * self.step_time
        self.step = self.step + 1


    def __next__(self):
        column_vector = np.array([[self.x], [self.x_dot]])

        self.iterations = self.iterations + 1
        if self.iterations == self.max_iterations:
            raise StopIteration

        for step in range(self.steps_per_iteration):
            self.__increment_step()

        return column_vector

