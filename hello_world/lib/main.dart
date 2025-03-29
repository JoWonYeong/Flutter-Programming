// material.dart : 플러터에서 기본 제공해주는 위젯 사용 가능
import 'package:flutter/material.dart';

void main() {
  // runApp() : 플러터 프로젝트 시작
  // 플러터에서 runApp 안에 MaterialApp, Scaffold 위젯 추가하는 것이 국룰
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: Stack(
              children: [
                Container(
                  height: 300.0,
                  width: 300.0,
                  color: Colors.red,
                ),
                Container(
                  height: 250.0,
                  width: 250.0,
                  color: Colors.yellow,
                ),
                Container(
                  height: 200.0,
                  width: 200.0,
                  color: Colors.green,
                )
              ],
            )
        )
    );
  }
}