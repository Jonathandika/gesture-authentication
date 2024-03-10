import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns

import json
import os
import time

from matplotlib.gridspec import GridSpec, GridSpecFromSubplotSpec

from scipy.spatial.distance import euclidean

from typing import List

from dtaidistance import dtw_ndim
from dtaidistance import dtw
from dtaidistance import dtw_visualisation as dtwvis

from fastdtw import fastdtw

from tslearn.metrics import ctw, soft_dtw


class GestureAuthenticator:
    
    def __init__(self) -> None:
        self.gesture_category = None
        self.storedGesture_dfs = []
        
    def register_gesture(self, category: str, gesture_df: List[pd.DataFrame]):
        self.gesture_category = category
        self.storedGesture_dfs = gesture_df
        
    
    def convert_to_array(self, gesture_df):
    
        def flatten_dict_col(df, column):
            return df[column].apply(pd.Series)

        acceleration_df = flatten_dict_col(gesture_df, 'acceleration')
        acceleration_df = acceleration_df[['x', 'y', 'z']]
        
        rotation_rate_df = flatten_dict_col(gesture_df, 'rotationRate')
        rotation_rate_df = rotation_rate_df[['x', 'y', 'z']]
        
        combined_df = pd.concat([acceleration_df, rotation_rate_df], axis=1)
        
        gesture_array = combined_df.to_numpy(dtype=np.double)
        
        return gesture_array
    
    def authenticateGesture(self,
                            newGesture_df: pd.DataFrame,
                            storedGesture_dfs: list[pd.DataFrame] = None, 
                            algorithm: str = 'dtw',
                            threshold: float = 100) ->  tuple[bool, float]:
        
        if storedGesture_dfs is None:
            storedGesture_dfs = self.storedGesture_dfs
        
        storedGesture_arrays = [self.convert_to_array(storedGesture_df) for storedGesture_df in storedGesture_dfs]
        newGesture_array = self.convert_to_array(newGesture_df)
        
        distances = []
        
        start = time.time()
        
        for storedGesture_array in storedGesture_arrays:
            if algorithm == 'dtw':
                distance = dtw_ndim.distance(storedGesture_array, newGesture_array)
                normalized_distance = distance / (len(newGesture_array) + len(storedGesture_array))
                distances.append(normalized_distance)
                
            elif algorithm == 'fastdtw':
                distance, path = fastdtw(storedGesture_array, newGesture_array, dist=2)
                normalized_distance = distance**(0.5) / (len(newGesture_array) + len(storedGesture_array))
                distances.append(normalized_distance)
                
            elif algorithm == 'ctw':
                distance = abs(ctw(storedGesture_array, newGesture_array))
                normalized_distance = distance / (len(newGesture_array) + len(storedGesture_array))
                distances.append(normalized_distance)

            elif algorithm == 'softdtw':
                distance = abs(soft_dtw(storedGesture_array, newGesture_array))
                normalized_distance = distance / (len(newGesture_array) + len(storedGesture_array))
                distances.append(normalized_distance)
            
            elif algorithm == 'euclidean':
                distance = dtw_ndim.ub_euclidean(storedGesture_array, newGesture_array)
                distances.append(distance) 
                
            elif algorithm == 'correlation':
                distance = self.__correlation(storedGesture_array, newGesture_array)
                distances.append(distance)
                
            else:
                print("Algorithm not supported")
                return None, None
            
        end = time.time()
        time_taken = end - start

        avg_distance = np.mean(distances)
        
        if (avg_distance <= threshold):
            return True, float(avg_distance), float(time_taken)
        else:
            return False, float(avg_distance), float(time_taken)
            
        
        
    def plot_dtw_path(self, 
                      gesture_a_df, 
                      gesture_b_df, 
                      algorithm: str = 'dtw'):
    
        gesture_a_array = self.convert_to_array(gesture_a_df)
        gesture_b_array = self.convert_to_array(gesture_b_df)
        
        if algorithm == 'dtw':
            distance = dtw_ndim.distance(gesture_a_array, gesture_b_array)
            print(distance)

            n_dimensions = 6
            dimension_labels = ['Acceleration X', 'Acceleration Y', 'Acceleration Z', 'Rotation X', 'Rotation Y', 'Rotation Z']

            fig = plt.figure(figsize=(15, 10))

            outer_grid = GridSpec(2, 3, wspace=0.2, hspace=0.3)

            for i in range(n_dimensions):
                inner_grid = GridSpecFromSubplotSpec(2, 1, subplot_spec=outer_grid[i], hspace=0.4)
                
                path = dtw_ndim.warping_path(gesture_a_array[:, i], gesture_b_array[:, i])

                ax1 = plt.Subplot(fig, inner_grid[0])
                fig.add_subplot(ax1)

                ax2 = plt.Subplot(fig, inner_grid[1])
                fig.add_subplot(ax2)
                
                dtwvis.plot_warping(gesture_a_array[:, i], gesture_b_array[:, i], path, fig=fig, axs=[ax1, ax2])

                ax1.set_title(dimension_labels[i])

            plt.show()
            
            
        else:
            print("Algorithm not supported")
            
    def load_gestures(self, folder_path):
        storedGesture_dfs = []
        newGesture_dfs = []
        otherGesture_dfs = []

        for gestureFile in os.listdir(folder_path):
            
            if gestureFile.startswith('gestureData'):
                with open(folder_path + gestureFile) as f:
                    storedGesture = json.load(f)
                storedGesture_df =  pd.DataFrame(storedGesture)
                storedGesture_dfs.append(storedGesture_df)
                
            elif gestureFile.startswith('newGesture'):
                with open(folder_path + gestureFile) as f:
                    newGesture = json.load(f)
                newGesture_df = pd.DataFrame(newGesture)
                newGesture_dfs.append(newGesture_df)
                
            elif gestureFile.startswith('other'):
                with open(folder_path + gestureFile) as f:
                    otherGesture = json.load(f)
                otherGesture_df = pd.DataFrame(otherGesture)
                otherGesture_dfs.append(otherGesture_df)

        print(f"Stored Gestures: {len(storedGesture_dfs)}")
        print(f"New Gestures: {len(newGesture_dfs)}")
        print(f"Other Gestures: {len(otherGesture_dfs)}")
        
        return storedGesture_dfs, newGesture_dfs, otherGesture_dfs
        
    def get_FRR(self, storedGesture_dfs, newGesture_dfs, algorithm: str = 'dtw', threshold: float = 0.15):
        print(f"Threshold: {threshold}\n")

        res_list = []
        time_list = []

        print("\tAuthenticated\tDistance\tTime Taken")
        for i, newGesture_df in enumerate(newGesture_dfs):
            
            res, dist, time = self.authenticateGesture(storedGesture_dfs, 
                                                                  newGesture_df,
                                                                  algorithm=algorithm, 
                                                                  threshold=threshold)
            res_list.append(res)
            time_list.append(time)
            
            print(f"{i+1}"
                f"\t{res}"
                f"\t\t{dist:.4f}"
                f"\t\t{time:.4f}")
            
        FRR = (1 - (sum(res_list) / len(res_list))) * 100
        average_time = np.mean(time_list)
        
        print(f"\nFalse Rejection Rate (FRR): {FRR:.3f} %")
        print(f"Average Time: {average_time:.4f}")
        
        return FRR, time
        
    def get_FAR(self, storedGesture_dfs, otherGesture_dfs, algorithm: str = 'dtw', threshold: float = 0.15):
        print(f"Threshold: {threshold}\n")

        res_list = []
        time_list = []

        print("\tAuthenticated\tDistance\tTime Taken")
        for i, otherGesture_df in enumerate(otherGesture_dfs):
            
            res, dist, time = self.authenticateGesture(storedGesture_dfs, 
                                                            otherGesture_df,
                                                            algorithm=algorithm, 
                                                            threshold=threshold)
            res_list.append(res)
            time_list.append(time)
            
            print(f"{i+1}"
                f"\t{res}"
                f"\t\t{dist:.4f}"
                f"\t\t{time:.4f}")
            
        FAR = (sum(res_list) / len(res_list)) * 100
        average_time = np.mean(time_list)
        
        print(f"\nFalse Acceptance Rate (FAR): {FAR:.3f} %")
        print(f"Average Time: {average_time:.4f}")
        
        return FAR, time
        
        
    def __correlation(x: np.array, y: np.array) -> float:
        
        if (len(x) > len(y)):
            for i in range(len(x) - len(y)):
                y = np.append(y, [y[-1]], axis=0)
        else:
            for i in range(len(y) - len(x)):
                x = np.append(x, [x[-1]], axis=0)
        
        dim_cor = []
        for i in range(6):
            dim_cor.append(np.corrcoef(x[:, i], y[:, i])[0, 1])
        
        return np.sum(dim_cor)
            
        
        