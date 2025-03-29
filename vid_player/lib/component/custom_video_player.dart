import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:vid_player/component/custom_icon_button.dart';


class CustomVideoPlayer extends StatefulWidget {
  // 선택한 동영상을 저장할 변수
  // XFile은 ImagePicker로 영상, 이미지 선택했을때 반환받을 타입
  final XFile video;
  final GestureTapCallback onNewVideoPressed;

  const CustomVideoPlayer({
    required this.video,
    required this.onNewVideoPressed,
    Key? key
  }):super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  // 동영상 조작하는 아이콘 보일지 여부
  bool showControls = false;
  // 동영상 조작하는 컨트롤러
  VideoPlayerController? videoController;

  @override
  // StatefulWidget 생명주기의 함수 didUpdateWidget()으로 새로운 동영상이 선택되면 videoController 새로 실행
  // covariant 키워드는 CustomVideoPlayer 클래스의 상속된 값도 허가해줌
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget){
    super.didUpdateWidget(oldWidget);
    print("💦올드 위젯💦 : ${oldWidget.video.path}");
    print("❗뉴 위젯❗ : ${widget.video.path}");


    // 새로 선택한 동영상이 같은 동영상인지 확인
    if(oldWidget.video.path != widget.video.path){
      // 같은 동영상인데도 들어오는데..? => 같은 동영상이라도 할때마다 경로 다름
      print("🩷새로 선택한 동영상이 같은 동영상인지 확인🩷");
      initializeController();
    }
  }

  @override
  void initState() {
    super.initState();

    initializeController();
  }

  initializeController() async {
    print("😄새로 실행됨😄");
    final videoController = VideoPlayerController.file(
        File(widget.video.path)
    );

    await videoController.initialize();

    // 컨트롤러의 속성이 변경될 때마다 실행할 함수 등록
    videoController.addListener(videoControllerListener);

    setState(() {
      // 이 부분이 실행이 안됨
      print("👽setState 실행됨👽");
      this.videoController = videoController;
    });
  }

  // 동영상의 재생 상태가 변경될 때마다
  // setState() 실행해서 build() 재실행
  void videoControllerListener() {
    setState(() {});
  }

  // State 폐기될 때 같이 폐기할 함수 실행
  @override
  void dispose() {
    videoController?.removeListener(videoControllerListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (videoController == null) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    // 동영상 비율에 따른 화면 렌더링
    return GestureDetector(
      onTap: (){
        setState((){
          showControls = !showControls;
        });
      },
      child: AspectRatio(
        aspectRatio: videoController!.value.aspectRatio,
        child: Stack(
            children: [
              VideoPlayer(
                videoController!,
              ),
              if(showControls)
                Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      renderTimeTextFromDuration(
                        // 동영상 현재 위치
                        videoController!.value.position,
                      ),
                      Expanded(
                        child: Slider(
                          onChanged: (double val) {
                            // VideoPlayerController의 seekTo() : 재생위치 변경
                            videoController!.seekTo(
                                Duration(seconds: val.toInt())
                            );
                            },
                          // VideoPlayerController의 value.positon : 동영상이 현재 재생되고 있는 위치
                          value: videoController!.value.position.inSeconds.toDouble(),
                          min: 0,
                          max: videoController!.value.duration.inSeconds.toDouble(),
                        ),
                      ),
                      renderTimeTextFromDuration(
                        videoController!.value.duration,
                      )
                    ],
                  ),
                )
              ),
              if(showControls)
                Align(
                  alignment: Alignment.topRight,
                  child: CustomIconButton(
                    onPressed: widget.onNewVideoPressed,
                    iconData: Icons.photo_camera_back,
                  ),
                ),
              if(showControls)
                Align(
                  alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CustomIconButton(
                          onPressed: onReversePressed,
                          iconData: Icons.rotate_left,
                        ),
                        CustomIconButton(
                          onPressed: onPlayPressed,
                          iconData: videoController!.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        ),
                        CustomIconButton(
                          onPressed: onFowardPressed,
                          iconData: Icons.rotate_right,
                        ),
                      ],
                    )
                ),
            ]
        )
      )
    );
  }

  Widget renderTimeTextFromDuration(Duration duration){
    return Text(
        '${duration.inMinutes.toString().padLeft(2,'0')}:${(duration.inSeconds%60).toString().padLeft(2,'0')}',
      style: TextStyle(
        color: Colors.white,
      ),
    );
  }

  void onReversePressed() {
    final currentPosition = videoController!.value.position;

    Duration position = Duration();

    if (currentPosition.inSeconds > 3) {
      position = currentPosition - Duration(seconds: 3);
    }

    videoController!.seekTo(position);
  }

  void onFowardPressed() {
    final maxPosition = videoController!.value.duration; // 동영상 길이
    final currentPosition = videoController!.value.position;

    Duration position = maxPosition;

    if ((maxPosition - Duration(seconds: 3)).inSeconds >
        currentPosition.inSeconds) {
      position = currentPosition + Duration(seconds: 3);
    }

    videoController!.seekTo(position);
  }

  void onPlayPressed() {
    if (videoController!.value.isPlaying) {
      videoController!.pause();
    }
    else {
      videoController!.play();
    }
  }

}