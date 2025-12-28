import 'dart:async';
import 'dart:math';

import 'package:fitness_tracker/widgets/exercice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';



enum SquatState { 
  standing , goingDown , goingUp , bottom 
}
class ExercicesPage extends StatefulWidget {
  @override
  State<ExercicesPage> createState() => _ExercicesPageState(); 
}



class _ExercicesPageState extends State<ExercicesPage> {

  int count = 0 ; 
  int exerciceNumber = 1 ; 
  ValueNotifier<bool> isStop = ValueNotifier(false) ; 
  bool startPage = true ; 
  List<String> exercices = [ "1" , "2" , "3" , "4" ] ; 
  int stopTimer = 0 ; 



  void startTiming() { 
    if(!isStop.value) return ; 
    
    Timer.periodic(
      const Duration(seconds: 1), 
      (Timer timer) {
        setState(() {
          stopTimer++ ; 
          if(stopTimer >= 30) { 
            isStop.value = false ; 
            stopTimer = 0 ; 
            timer.cancel(); 
          }
        });
    }) ;
  }
  @override
  void initState() {
    super.initState();

    isStop.addListener((){
      if(isStop.value) { 
        startTiming() ; 
      }else { 
        stopTimer = 0 ; 
      }
    }) ; 
    SquatState squatState = SquatState.standing ; 
    accelerometerEventStream().listen((event) {
      
      if(exerciceNumber == 1  && !startPage && !isStop.value) {
          double magnitude = sqrt(
            event.x * event.x +
            event.y * event.y +
            event.z * event.z
          );


        if(squatState == SquatState.standing && magnitude > 12 ) { 
          squatState = SquatState.goingDown ; 
        }

        if(squatState == SquatState.goingDown && magnitude < 10 ){
          squatState = SquatState.bottom ; 
        }

        if(squatState == SquatState.bottom && magnitude < 12 ) { 
          squatState = SquatState.goingUp ; 
        }

        if(squatState == SquatState.goingUp  ) {
          setState(() {
            count++;
          });
          squatState = SquatState.standing ; 
          if(count > 15) { 
            setState(() {
              exerciceNumber++ ; 
              isStop.value = true ; 
            });
          }
        }
      }
    }) ; 
  }
  @override
  Widget build(BuildContext context) {
    if(startPage) { 
      return Scaffold(
        backgroundColor: Colors.white ,
        body: 
        Padding(
          padding: EdgeInsets.fromLTRB(20, 100, 20, 100 ),
          child: SingleChildScrollView(
            child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Container(   
                  margin: EdgeInsets.only(bottom: 20),
                  child : Text("Workouts" , style: TextStyle(color: Colors.grey[800] , fontFamily: "Open Sans" , fontSize: 40 , fontWeight: FontWeight.bold)  ) , 
                ), 
                ...exercices.map((element) => ExerciceWidget()) , 
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: 
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom( 
                      backgroundColor: Colors.orange , 
                      side: BorderSide.none , 
                      foregroundColor: Colors.white , 
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0)) , side: BorderSide.none) ,
                    ),
                    onPressed: () {
                      setState(() {
                        startPage = false ; 
                      });
                    }, 
                    icon : Icon(Icons.play_arrow) , 
                    iconAlignment: IconAlignment.end,
                    label: Text("Start Now" , style: TextStyle(color: Colors.white , fontFamily: "Open Sans" , fontSize: 20 , fontWeight: FontWeight.bold) ,)
                  ) 
                )
              ],
            ),
          )
        ) 
      ) ;  
    }
    if(isStop.value) { 
      return Scaffold(
        backgroundColor: Colors.white ,
        body: 
        Padding(
          padding: EdgeInsets.fromLTRB(20, 100, 20, 100 ),
          child: Center(
            child: Column(
              children: [
                Text(
                  "Stop" , 
                  style: TextStyle(color: Colors.grey[800] , fontFamily: "Open Sans" , fontSize: 40 , fontWeight: FontWeight.bold)
                ) ,  
                Text(
                  "take your time to respirate , and we will start again after 30 seconds" , 
                  style: TextStyle(color: Colors.grey[500] , fontFamily: "Open Sans" , fontSize: 16 , fontWeight: FontWeight.normal ) , 
                  textAlign: TextAlign.center,
                ) , 
                Image.asset("assets/squats.png") , 
                Container( 
                  margin: EdgeInsets.only(top: 30 ),
                  padding: EdgeInsets.all(10), 
                  decoration: BoxDecoration(
                    color: Colors.grey[100] , 
                    borderRadius: BorderRadius.circular(20)   
                  ),
                  alignment: Alignment.center,
                  child: Text("${stopTimer}" , style: TextStyle(color: Colors.black , fontFamily: "Open Sans" , fontSize: 40 , fontWeight: FontWeight.bold ))  , 
                  width: 80 , 
                  height: 80 
                  ) 
              ]
            ) 
          )     
        ) 
      )  ; 
    }
    return Scaffold(
      backgroundColor: Colors.white ,
      body: 
      Padding(
        padding: EdgeInsets.fromLTRB(0, 100, 0, 100) ,
        child : Center(
            child: Column(
            children: [
              Text( 
                  "Exercice ${exerciceNumber}" , 
                  style: TextStyle(color: Colors.grey[800] , fontFamily: "Open Sans" , fontSize: 40 , fontWeight: FontWeight.bold),
                ) , 
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 30) , 
                child: Image.asset("assets/squats.png"),
                ) , 
              if(exerciceNumber == 1) 
                Container( 
                  padding: EdgeInsets.all(10), 
                  decoration: BoxDecoration(
                    color: Colors.grey[100] , 
                    borderRadius: BorderRadius.circular(20)   
                  ),
                  alignment: Alignment.center,
                  child: Text("${count}" , style: TextStyle(color: Colors.black , fontFamily: "Open Sans" , fontSize: 40 , fontWeight: FontWeight.bold ))  , 
                  width: 80 , 
                  height: 80 
                  ) 
            ],
          ),
        )
      )
    ); 
  }
}