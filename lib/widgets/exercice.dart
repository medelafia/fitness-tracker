import 'package:flutter/material.dart';

class ExerciceWidget extends StatelessWidget { 


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
      padding: EdgeInsets.all(10), 
      width: MediaQuery.sizeOf(context).width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(10)) , 
        color: Colors.white,
        boxShadow: [ 
          BoxShadow( 
            color: const Color.fromARGB(255, 225, 225, 225) , 
            blurRadius: 1 , 
            blurStyle: BlurStyle.normal , 
            offset: Offset(1,1 ), 
            spreadRadius: 2 
            )
        ]
      ),
      child:Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset("assets/squats.png" , width: 100, height: 100,) , 
          Padding(
            padding: EdgeInsets.all(10) , 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text("Squats" , style: TextStyle(color: Colors.grey[800] , fontFamily: "Open Sans" , fontSize: 20 , fontWeight: FontWeight.bold),) , 
                Text("6 units" , style: TextStyle(color: Colors.grey[500] , fontFamily: "Open Sans" , fontSize: 16 , fontWeight: FontWeight.normal),) 
              ],
            )
          )
        ],
      ),
    );
  }
}