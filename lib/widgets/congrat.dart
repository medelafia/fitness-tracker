import 'package:flutter/material.dart';

class Congrat extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CongratState() ; 
} 


class _CongratState extends State<Congrat> with SingleTickerProviderStateMixin { 



  int count = 0 ; 
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    
    return Scaffold(
      backgroundColor: Colors.white ,
      body: 
      Padding(
        padding: EdgeInsets.fromLTRB(0, 100, 0, 100) ,
        child : 
          
          Center(
            child: Column(
              children: [
                Text( 
                  "Congratulations!" , 
                  style: TextStyle(color: Colors.orange , fontFamily: "Open Sans" , fontSize: 40 , fontWeight: FontWeight.bold),
                ), 
                Text( 
                  "You have completed this workout series" , 
                  style: TextStyle(color: Colors.grey[500] , fontFamily: "Open Sans" , fontSize: 16 ),
                  textAlign: TextAlign.center,
                )
                , 
                Container(
                  margin: EdgeInsets.only(top: 50 , bottom: 50 ),
                  width: 200 ,
                  height: 80 , 
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.all(Radius.circular(30.0))
                  ),
                  alignment: Alignment.center,
                  child: Text("+1" , style: TextStyle(color: Colors.grey[800] , fontFamily: "Open Sans" , fontSize: 40 , fontWeight: FontWeight.bold)) 

                ) ,
                ElevatedButton.icon(
                    onPressed: (){}, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange , 
                      side: BorderSide.none , 
                      alignment: Alignment.center , 
                      shape: RoundedRectangleBorder(borderRadius:  BorderRadius.circular(10.0)),
                      padding: EdgeInsets.fromLTRB(30 , 10 , 30 , 10 ),
                      iconSize: 24 , 
                      iconColor: Colors.white ,
                    ),
                    icon: Icon(Icons.home),
                    label: Text("Back to home" , style: TextStyle(color: Colors.white , fontFamily: "Open Sans" , fontSize: 20 , fontWeight: FontWeight.bold))
                ),
                
              ]
            ) 
            )
          )
        ); 
               
  }
}