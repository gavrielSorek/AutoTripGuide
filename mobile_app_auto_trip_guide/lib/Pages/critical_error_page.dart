import 'package:flutter/material.dart';
import 'dart:io';

class CriticalErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Image.asset(
                  'assets/images/error.jpg', // Replace this with your error image path
                  height: 300,
                  width: 300,
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Something went wrong',
                  textAlign: TextAlign.center, // Centers the text
                  style: TextStyle(
                    fontSize: 35,
                    color: Colors.black,
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0, bottom: 10),
                child: Center(
                  child: Text(
                    "Oops! Technical glitch. We're on it. Please check back shortly. Thanks!",
                    textAlign: TextAlign.center, // Centers the text
                    style: TextStyle(
                      fontSize: 18,
                      color: Color(0xff6C6F70),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 30.0, right: 30.0, bottom: 10),
                child: ElevatedButton(
                  onPressed: () => exit(0),
                  child: Text('Close', style: TextStyle(
                    fontSize: 18,
                  ),),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                    minimumSize: MaterialStateProperty.all(
                        Size(double.infinity, 40)), // Change the height here
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // Change the border radius here
                    )),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
