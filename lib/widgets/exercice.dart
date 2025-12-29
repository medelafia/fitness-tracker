import 'package:flutter/material.dart';


class Exercice { 
  String? name ; 
  String? imagePath ; 
  int? units ; 

  Exercice(this.name , this.imagePath , this.units ) ; 
}
class ExerciceWidget extends StatelessWidget { 
  final Exercice exercice ; 
  ExerciceWidget({super.key , required this.exercice});
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
          Image.asset(this.exercice.imagePath! , width: 100, height: 100,) , 
          Padding(
            padding: EdgeInsets.all(10) , 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(this.exercice.name! , style: TextStyle(color: Colors.grey[800] , fontFamily: "Open Sans" , fontSize: 20 , fontWeight: FontWeight.bold),) , 
                Text("${this.exercice.units!} units" , style: TextStyle(color: Colors.grey[500] , fontFamily: "Open Sans" , fontSize: 16 , fontWeight: FontWeight.normal),) 
              ],
            )
          )
        ],
      ),
    );
  }
}