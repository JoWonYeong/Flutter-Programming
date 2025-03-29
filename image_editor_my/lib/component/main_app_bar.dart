import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget {
  // 이미지 선택 눌렀을 때 실행할 함수
  final VoidCallback onPickImage;
  // 이미지 저장 눌렀을 때 실행할 함수
  final VoidCallback onSaveImage;
  // 이미지 삭제 눌렀을 때 실행할 함수
  final VoidCallback onDeleteItem;

  const MainAppBar({
    required this.onPickImage,
    required this.onSaveImage,
    required this.onDeleteItem,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 이미지 선택 버튼
          IconButton(
              onPressed: onPickImage,
              icon: Icon(
                Icons.imagesearch_roller_outlined,
                color: Colors.grey[700],
              ),
          ),
          // 이미지 삭제 버튼
          IconButton(
            onPressed: onDeleteItem,
            icon: Icon(
              Icons.delete_forever_outlined,
              color: Colors.grey[700],
            ),
          ),
          // 이미지 저장 버튼
          IconButton(
            onPressed: onSaveImage,
            icon: Icon(
              Icons.save,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}