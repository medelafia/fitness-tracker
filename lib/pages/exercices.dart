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
  bool isStop = true ; 

  
  @override
  void initState() {
    super.initState();

    
    SquatState squatState = SquatState.standing ; 
    userAccelerometerEventStream().listen((event) {
      if(exerciceNumber == 1 ) {
        double vertical = event.y ; 
        print(event.y) ; 
        if(squatState == SquatState.standing && vertical < -1.2 ) { 
          squatState = SquatState.goingDown ; 
        }

        if(squatState == SquatState.goingDown && vertical.abs() < 0.3 ){
          squatState = SquatState.bottom ; 
        }

        if(squatState == SquatState.bottom && vertical > 1.2 ) { 
          squatState = SquatState.goingUp ; 
        }

        if(squatState == SquatState.goingUp && vertical.abs() > 0.3 ) {
          setState(() {
            count++;
          });
          squatState = SquatState.standing ; 
          if(count >= 15) { 
            setState(() {
              exerciceNumber++ ; 
              isStop = true ; 
            });
          }
        }
      }
    }) ; 
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("App bar")) , 
      body: Column(
        children: [
          if(isStop) Text("Stop") else Text("Exercice ${exerciceNumber}") , 
          if(!isStop) Image.asset("assets/squats.png")
          else ElevatedButton(
            onPressed: () {
              setState(() {
                isStop = false ; 
              });
            }, 
            child: Text("Start Now")),
          if(exerciceNumber == 1) Text("count : ${count}") 
        ],
      ),


    ); 
  }
}