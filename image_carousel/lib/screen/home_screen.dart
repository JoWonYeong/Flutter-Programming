import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

// StatefulWidget 정의
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  // StatefulWidget은 createState() 함수 정의 해야함
  State<HomeScreen> createState() => _HomeScreenState();
}

// _HomeScreenState 정의
class _HomeScreenState extends State<HomeScreen>{
  // PageController 사용해서 PageView 조작 가능
  final PageController pageController = PageController();

  // initState() 함수 등록
  @override
  void initState(){
    // 부모 initState() 실행
    super.initState();

    Timer.periodic(
        Duration(seconds: 3),
        (timer) {
        //   현재 페이지 가져옴
          int? nextPage = pageController.page?.toInt();

        //   페이지 값 없을 때 예외처리
          if(nextPage == null) {
            return;
          }

        //   첫 페이지와 마지막 페이지 연결
          if(nextPage == 4){
            nextPage = 0;
          } else{
            nextPage++;
          }

        // 페이지 변경
          pageController.animateToPage(
              nextPage, 
              duration: Duration(milliseconds: 500), // 이동할 때 소요될 시간  
              curve: Curves.ease);
        },
    );
  }

  @override
  Widget build(BuildContext context){
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      body: PageView(
        controller: pageController,
        children: [1,2,3,4,5]
            .map(
              (number) => Image.asset(
            'asset/img/image_$number.jpeg',
            fit: BoxFit.cover,
          ),
        ).toList(),
      ),
    );
  }
}
