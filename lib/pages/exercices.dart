import 'dart:async';
import 'package:fitness_tracker/widgets/congrat.dart';
import 'package:fitness_tracker/widgets/exercice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';



enum SquatState { 
  standing , goingDown , goingUp , bottom 
}

enum LungeState { 
  center , goingRight , goingLeft , left , right
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
  List<Exercice> exercices = [ 
    Exercice("Squat", "assets/squats.png", 20 ) , 
    Exercice("Lunge Side", "assets/side_lunge.png", 20 )  ,
    Exercice("Split Squats", "assets/splitSquats.png", 20 ) 
    ] ; 
  int stopTimer = 0 ; 
  bool done = false ; 


  void startTiming() { 
    if(!isStop.value) return ; 
    
    Timer.periodic(
      const Duration(seconds: 1), 
      (Timer timer) {
        setState(() {
          stopTimer++ ; 
          if(stopTimer >= 20) { 
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
    bool wentLeft = false;
    bool wentRight = false;
    userAccelerometerEventStream().listen((event) {
      
      if( (exerciceNumber == 1 || exerciceNumber == 3) && !startPage && !isStop.value) {
        double verticale = event.y ; 
        
        if(squatState == SquatState.standing && verticale < -1.2 ) { 
          squatState = SquatState.goingDown ; 
        }
        if(squatState == SquatState.goingDown && verticale.abs() < 0.3 ){
          squatState = SquatState.bottom ; 
        }
        if(squatState == SquatState.bottom && verticale > 1.2 ) { 
          squatState = SquatState.goingUp ; 
        }
        if(squatState == SquatState.goingUp && verticale.abs() < 0.3 ) {
          setState(() {
            count++;
          });
          squatState = SquatState.standing ; 
          if(count > this.exercices[0].units!) { 
            setState(() {
              if(this.exerciceNumber == 1) {
                exerciceNumber++ ; 
                isStop.value = true ; 
                count = 0 ; 
              }else { 
                done = true ; 
                count = 0 ; 
              }

            });
          }
        }
      }else if(exerciceNumber == 2 && !startPage && !isStop.value) { 
        double x = event.x;

        if (x < -0.4) wentLeft = true;
        if (x > 0.4) wentRight = true;

        if (wentLeft && wentRight && x.abs() < 0.15) {
          setState(() => count++);

          wentLeft = false;
          wentRight = false; 

          if(count > this.exercices[1].units!) { 
              exerciceNumber++ ; 
              isStop.value = true ; 
              count = 0 ; 
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
                ...exercices.map((element) => ExerciceWidget(exercice: element,)) , 
                Container(
                  margin: EdgeInsets.only(top: 30),
                  alignment: Alignment.bottomRight,
                  child: 
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom( 
                      backgroundColor: Colors.orange , 
                      side: BorderSide.none , 
                      foregroundColor: Colors.white , 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)) ,
                        side: BorderSide.none
                      ) ,
                      iconSize: 24 , 
                      padding: EdgeInsets.fromLTRB(30, 10, 30, 10) 
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
                  "Break" , 
                  style: TextStyle(color: Colors.grey[800] , fontFamily: "Open Sans" , fontSize: 40 , fontWeight: FontWeight.bold)
                ) ,  
                Text(
                  "take your time to respirate , and we will start again after 30 seconds" , 
                  style: TextStyle(color: Colors.grey[500] , fontFamily: "Open Sans" , fontSize: 16 , fontWeight: FontWeight.normal ) , 
                  textAlign: TextAlign.center,
                ) , 
                Image.asset("assets/break.png") , 
                Container( 
                  margin: EdgeInsets.only(top: 30 ),
                  padding: EdgeInsets.all(10), 
                  decoration: BoxDecoration(
                    color: Colors.grey[100] , 
                    borderRadius: BorderRadius.circular(20)   
                  ),
                  alignment: Alignment.center,
                  child: 
                    Text("${stopTimer}" , style: TextStyle(color: Colors.black , fontFamily: "Open Sans" , fontSize: 40 , fontWeight: FontWeight.bold ))  , 
                  width: 80 , 
                  height: 80 
                ) 
              ]
            ) 
          )     
        ) 
      )  ; 
    }
    if(done) { 
      return Congrat() ;  
    }
    return Scaffold(
      backgroundColor: Colors.white ,
      appBar:  
          AppBar(
            backgroundColor: Colors.grey[100] ,
            title: Text("Workout"),
            leading: IconButton(
              icon: Icon(Icons.arrow_back) , 
              onPressed: () {
                setState(() {
                  this.startPage = true ; 
                });
              },
            ),
            actions: [
              
            ],
          ),
      body: 
      Padding(
        padding: EdgeInsets.fromLTRB(0, 80, 0, 80) ,
        child : Center(
            child: Column(
            children: [
              Text( 
                "Exercice ${exerciceNumber}" , 
                style: TextStyle(color: Colors.grey[800] , fontFamily: "Open Sans" , fontSize: 40 , fontWeight: FontWeight.bold),
                ) , 
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 30, 10, 30) , 
                child: Image.asset(this.exercices[this.exerciceNumber - 1].imagePath!),
                ) , 
              Container( 
                padding: EdgeInsets.all(10), 
                decoration: BoxDecoration(
                  color: Colors.grey[100] , 
                  borderRadius: BorderRadius.circular(20)   
                ),
                alignment: Alignment.center ,
                child: Text("${count} / ${this.exercices[this.exerciceNumber - 1].units}" , style: TextStyle(color: Colors.black , fontFamily: "Open Sans" , fontSize: 40 , fontWeight: FontWeight.bold ))  , 
                width: 200 , 
                height: 80 
              ) 
            ],
          ),
        )
      )
    ); 
  }
}