from scipy.spatial.distance import euclidean

from dtaidistance import dtw_ndim
from dtaidistance import dtw
from dtaidistance import dtw_visualisation as dtwvis

from fastdtw import fastdtw


class DistanceCalculator:
    def calculate_distance(self, storedGesture_array, newGesture_array):
        raise NotImplementedError("This method should be implemented by subclasses.")


class DTWCalculator(DistanceCalculator):
    def calculate_distance(self, storedGesture_array, newGesture_array):
        distance = dtw_ndim.distance(storedGesture_array, newGesture_array)
        normalized_distance = distance / (len(newGesture_array) + len(storedGesture_array))
        return normalized_distance


class FastDTWCalculator(DistanceCalculator):
    def calculate_distance(self, storedGesture_array, newGesture_array):
        distance, path = fastdtw(storedGesture_array, newGesture_array, dist=2)
        normalized_distance = distance**(0.5) / (len(newGesture_array) + len(storedGesture_array))
        return normalized_distance


class EuclideanCalculator(DistanceCalculator):
    def calculate_distance(self, storedGesture_array, newGesture_array):
        return dtw_ndim.ub_euclidean(storedGesture_array, newGesture_array)
