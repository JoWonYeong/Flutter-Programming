import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';

class HomeScreen extends StatelessWidget {
  // 컨트롤러 변수 생성
  WebViewController? controller;
  HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Code Factory'),
        centerTitle: true,

        actions: [
          IconButton(
            onPressed: (){
              if(controller!=null){
                controller!.loadUrl('https://blog.codefactory.ai');
              }
            },
            icon:Icon(
              Icons.home,
            )
          )
        ],
      ),
      body: WebView(
        onWebViewCreated: (WebViewController controller){
          // 위젯에 컨트롤러 저장
          this.controller = controller;
        },
        initialUrl: 'https://blog.codefactory.ai',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}