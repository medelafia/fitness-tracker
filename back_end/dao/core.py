from pydantic import BaseModel , Field
import sqlite3
from fastapi import HTTPException ,status 

class Activity(BaseModel) :
    activity_date : str = Field(description="Date in format 30-12-2025" )
    start_time : str = Field(description="Start time with format 12:10") 
    end_time : str = Field(description="Start time with format 12:10") 

class Course(Activity) : 
    id : int = Field()
    distance : float = Field() 

class Workout(Activity) : 
    id : int = Field()
    number_of_exercices_completed : int = Field() 

class Dao : 
    def init_schema(self) : 
        with sqlite3.connect("dao/database.sql") as db :
            cursor = db.cursor()
            sql = """
                CREATE TABLE IF NOT EXISTS Course(
                    id INTEGER PRIMARY KEY AUTOINCREMENT  ,  
                    distance REAL , 
                    date TEXT ,
                    startTime TEXT , 
                    endTime TEXT 
                );
                CREATE TABLE IF NOT EXISTS Workout (
                    id INTEGER PRIMARY KEY AUTOINCREMENT ,  
                    number_of_exercices_completed REAL , 
                    date TEXT ,
                    startTime TEXT , 
                    endTime TEXT 
                );
            """
            
            try :
                cursor.executescript(sql)
            except sqlite3.Error as e :  
                print(f"an error occured in database :  {e}")
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR  ,
                    detail="Please try again there's an internal server error"
                )
            finally : 
                cursor.close()
    

    def getObjects(self , object_class ):
        with sqlite3.connect("dao/database.sql") as db :
            cursor = db.cursor()
            sql = "SELECT * FROM " + ("Course" if object_class.lower() == "course" else "Workout")

            try : 
                cursor.execute(sql) 

                return [ 
                    Course( id=int(item[0]) ,distance=float(item[1]) , activity_date=item[2] , start_time=item[3] , end_time=item[4])
                    if object_class.lower() == "course" 
                    else Workout(id=int(item[0]) , number_of_exercices_completed =int(item[1]) , activity_date=item[2] , start_time=item[3] , end_time=item[4])
                    for item in cursor.fetchall() 
                ]
            except sqlite3.Error as e : 
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR  ,
                    detail=f"Please try again there's an internal server error {e}"
                )
            finally:
                cursor.close()


    def insert_workout(self , workout : Workout) : 
        with sqlite3.connect("dao/database.sql") as db :
            cursor = db.cursor()
            sql = "INSERT INTO Workout(number_of_exercices_completed , date , startTime ,endTime) VALUES (:number_of_exercices_completed , :date , :startTime , :endTime)" 
            
            try : 
                cursor.execute(sql, { 
                        "id": workout.id , 
                        "number_of_exercices_completed" : workout.number_of_exercices_completed, 
                        "date" : workout.activity_date , 
                        "startTime" :  workout.start_time , 
                        "endTime" : workout.end_time 
                    }) 
                db.commit()
                return workout
            except sqlite3.Error as e : 
                db.rollback()
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR  ,
                    detail=f"Please try again there's an internal server error {e}"
                )

            finally :
                cursor.close()
        

    def insert_course(self , course : Course) : 
        with sqlite3.connect("dao/database.sql") as db :
            cursor = db.cursor()
            sql = "INSERT INTO Course(distance , date , startTime ,endTime) VALUES (:distance , :date , :startTime , :endTime)" 
            
            try : 
                cursor.execute(sql, { 
                        "id": course.id , 
                        "distance" : course.distance, 
                        "date" : course.activity_date , 
                        "startTime" :  course.start_time , 
                        "endTime" : course.end_time 
                    }) 
                db.commit()
                return course
            except sqlite3.Error as e : 
                db.rollback()
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR  ,
                    detail=f"Please try again there's an internal server error {e}"
                )
            finally :
                cursor.close()
