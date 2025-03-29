import 'package:flutter/material.dart';
import 'package:random_dice/screen/home_screen.dart';
import 'package:random_dice/screen/settings_screen.dart';
import 'dart:math';
import 'package:shake/shake.dart';

class RootScreen extends StatefulWidget {
  const RootScreen({Key? key}) : super(key: key);

  @override
  State<RootScreen> createState() => _RootScreenState();
}
class _RootScreenState extends State<RootScreen> with TickerProviderStateMixin{
  TabController? controller;
  // 민감도 기본값 설정
  double threshold = 2.7;
  // 주사위 숫자
  int number = 1;
  ShakeDetector? shakeDetector;

  @override
  void initState(){
    super.initState();
    controller = TabController(length: 2, vsync: this);
    controller!.addListener(tabListener);

    shakeDetector = ShakeDetector.autoStart( // 흔들기 감지 즉시 시작
      shakeSlopTimeMS: 100, // 감지 주기
      shakeThresholdGravity: threshold, // 감지 민감도
      onPhoneShake: onPhoneShake, // 감지 후 실행할 함수
    );
  }

  void onPhoneShake(){
    final rand = new Random();

    setState(() {
      number = rand.nextInt(5) + 1;
    });
  }
  
  tabListener(){
    setState((){});
  }
  
  @override
  void dispose() {
    // 리스너에 등록된 함수 취소
    controller!.removeListener(tabListener);
    shakeDetector!.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: TabBarView(
        controller: controller,
        children: renderChildren(),
      ),
      bottomNavigationBar: renderBottomNavigation(),
    );
  }
  List<Widget> renderChildren(){
    return [
      HomeScreen(number: number),
      SettingScreen(threshold: threshold,onThresholdChange:onThresholdChange),
    ];
  }

  void onThresholdChange(double val){
    setState(() {
      threshold = val;
    });
  }

  BottomNavigationBar renderBottomNavigation(){
    return BottomNavigationBar(
      currentIndex: controller!.index,
        onTap: (int index){
        setState((){
          controller!.animateTo(index);
        });
        },
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.edgesensor_high_outlined,
              ),
            label: '주사위',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
            ),
            label: '설정',
          )
        ]
    );
  }
}