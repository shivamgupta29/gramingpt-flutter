import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
void main(){
  runApp(const MyApp());
}
class MyApp extends StatelessWidget{
  const MyApp({super.key});
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'GraminGPT',
      theme: ThemeData(),
      home: const ChatScreen(),
    );
  }
}