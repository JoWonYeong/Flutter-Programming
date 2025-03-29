import 'package:flutter/material.dart';

void main() {
  // SplashScreen 위젯을 첫 화면으로 지정
  runApp(SplashScreen());
}

// StatelessWidget 선언
class SplashScreen extends StatelessWidget {
  // build() 필수적으로 오버라이드
  @override
  Widget build(BuildContext context){
  //   위젯 UI 구현
    return MaterialApp( // 항상 최상단에 입력되는 위젯
      home: Scaffold( // 항상 두번째로 입력되는 위젯
        body: Container(
          decoration: BoxDecoration(
            color: Color(0xFFF99231),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      // width: 200,
                    ),
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(
                        Colors.white,
                      ),
                    ),
                  ]
              ),
            ],
          )
        )
      ),
    );
  }
}
