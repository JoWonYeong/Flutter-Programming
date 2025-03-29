import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_editor_my/component/main_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image_editor_my/component/footer.dart';
import 'package:image_editor_my/model/sticker_model.dart';
import 'package:image_editor_my/component/emoticon_sticker.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'package:image_gallery_saver/image_gallery_saver.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 선택할 이미지 저장할 변수
  XFile? image;
  Set<StickerModel> stickers = {}; // 화면에 추가된 스티커를 저장할 변수
  String? selectedId; // 현재 선택된 스티커의 ID
  GlobalKey imgKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            renderBody(),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: MainAppBar(
                onPickImage: onPickImage,
                onSaveImage: onSaveImage,
                onDeleteItem: onDeleteItem,
              ),
            ),
            if(image != null)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Footer(
                  onEmoticonTap: onEmoticonTap,
                ),
              )
          ],
        )
    );
  }

  Widget renderBody() {
    if (image != null) {
      // Stack 크기의 최대 크기만큼 차지하기
      return RepaintBoundary(
        key: imgKey,
        child: Positioned.fill(
          child: InteractiveViewer( // 위젯 확대, 좌우 이동 가능하게 하는 위젯
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(image!.path),
                    fit: BoxFit.cover,
                  ),
                  ...stickers.map(
                          (sticker) =>
                          Center(
                            child: EmoticonSticker(
                              key: ObjectKey(sticker.id),
                              onTransform: () {
                                onTransform(sticker.id);
                              },
                              imgPath: sticker.imgPath,
                              isSelected: selectedId == sticker.id,
                            ),
                          )
                  )
                ],
              )
          ),
        ),
      );
    } else {
      return Center(
        child: TextButton(
          style: TextButton.styleFrom(
            primary: Colors.grey,
          ),
          onPressed: onPickImage,
          child: Text('이미지 선택하기'),
        ),
      );
    }
  }

  void onEmoticonTap(int index) async {
    setState(() {
      stickers = {
        ...stickers,
        StickerModel(
          id: Uuid().v4(),
          imgPath: 'asset/img/emoticon_$index.png',
        )
      };
    });
  }

  void onPickImage() async {
    // 갤러리에서 이미지 선택
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      this.image = image;
    });
  }

  void onSaveImage() async {
    RenderRepaintBoundary boundary = imgKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    await ImageGallerySaver.saveImage(pngBytes, quality: 100);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('저장되었습니다!'),
        )
    );
  }

  void onDeleteItem() async {
    setState(() {
      stickers = stickers.where((sticker) => sticker.id != selectedId).toSet();
    });
  }

  void onTransform(String id) {
    setState(() {
      selectedId = id;
    });
  }
}