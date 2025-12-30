from dao.core import Dao , Workout , Course
from fastapi import FastAPI , status

app = FastAPI(openapi_prefix="/api") 
dao = Dao()

dao.init_schema()

@app.get("/course/all")
async def getAllCourses() : 
    return dao.getObjects("course") 

@app.get("/workout/all")
async def getAllWorkout() : 
    return dao.getObjects("workout") 

@app.post("/workout/" , status_code=status.HTTP_201_CREATED)
async def save_workout(workout: Workout ) :
    return dao.insert_workout(workout)

@app.post("/course/" , status_code=status.HTTP_201_CREATED)
async def save_course(course: Course) :
    return dao.insert_course(course)