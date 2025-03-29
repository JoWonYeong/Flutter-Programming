import 'package:flutter/material.dart';
//
// // 스티커 그리는 위젯
class EmoticonSticker extends StatefulWidget {
  final VoidCallback onTransform; // ➏
  final String imgPath; // ➋ 이미지 경로
  final bool isSelected;

  const EmoticonSticker({
    required this.onTransform,
    required this.imgPath,
    required this.isSelected,
    Key? key,
  }) : super(key: key);

  @override
  State<EmoticonSticker> createState() => _EmoticonStickerState();
}

class _EmoticonStickerState extends State<EmoticonSticker> {
  double scale = 1;
  double hTransform = 0;  // 가로 움직임
  double vTransform = 0;  // 세로 움직임
  double actualScale = 1; // 초기 확대/축소 비율

  @override
  Widget build (BuildContext context){
    return Transform(
      transform: Matrix4.identity()
        ..translate(hTransform,vTransform)
        ..scale(scale, scale),
      child: Container(
          decoration: widget.isSelected
              ? BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(
                color: Colors.blue,
                width: 1.0,
              )
          )
            : BoxDecoration(
              border: Border.all(
                width: 1.0,
                color: Colors.transparent,
              ),
          ),
          child: GestureDetector(
            // 스티커 눌렀을 때 실행할 함수
            onTap: (){
              widget.onTransform();
              },
            // 스티커의 확대 비율이 변경됐을 때 실행
            onScaleUpdate: (ScaleUpdateDetails details){
              widget.onTransform();
              setState(() {
                scale = details.scale * actualScale;
                vTransform += details.focalPointDelta.dy;
                hTransform += details.focalPointDelta.dx;
              });
              },
            // 스티커의 확대 비율이 변경됐을 때 실행
            onScaleEnd: (ScaleEndDetails details) {
              actualScale = scale;
              },
            child: Image.asset(
              widget.imgPath,
            ),
          )
      ),
    );
  }
}