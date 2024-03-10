from typing import Annotated, Literal, Union

from fastapi import FastAPI, File, UploadFile

import pandas as pd
import json

from helper.GestureAuthentication import GestureAuthenticator as GA

# Define Logger and color it blue
import logging
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)



app = FastAPI(debug=True)

ga = GA()

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.post("/register-gesture/")
async def register_gesture( 
        files: list[UploadFile],
        category: str = "default"
        ):
    gestureDicts = [json.load(file.file) for file in files]
    gesture_dfs = [pd.DataFrame(json_data) for json_data in gestureDicts]
    
    ga.register_gesture(category, gesture_dfs)
    
    logger.info("Succesfully registered gesture.")
    
    return {"message": f"Gesture ({category}) registered successfully", "status": "success", "length": len(ga.storedGesture_dfs)}


@app.post("/authenticate-gesture/")
async def authenticate_gesture(
        file: UploadFile,
        algorithm: Literal['dtw', 'fastdtw', 'ctw', 'softdtw', 'euclidean', 'correlation'] = 'dtw',
        threshold: float = 0.15
        ):
    
    logger.info("Loading JSON file")
    newGesture = json.load(file.file)
    newGesture_df = pd.DataFrame(newGesture)

    logger.info("Authenticating gesture")
    auth_result, score, time_taken = ga.authenticateGesture(newGesture_df, algorithm=algorithm, threshold=threshold)
    
    logger.info("Gesture authenticated")
    logger.info({"authenticated": auth_result, "distance": score, "time_taken": time_taken})
    
    return {"authenticated": auth_result, "distance": score, "time_taken": time_taken}
    
    
