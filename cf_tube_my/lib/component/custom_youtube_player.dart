import 'package:flutter/material.dart';
import 'package:cf_tube_my/model/video_model.dart';

import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// 유튜브 동영상 재생기 위젯
class CustomYoutubePlayer extends StatefulWidget {
  final VideoModel videoModel;

  const CustomYoutubePlayer({
    required this.videoModel,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomYoutubePlayer> createState() => _CustomYoutubePlayerState();
}

class _CustomYoutubePlayerState extends State<CustomYoutubePlayer> {
  YoutubePlayerController? controller;

  @override
  void initState() {
    super.initState();
    controller = YoutubePlayerController(
        initialVideoId: widget.videoModel.id,
        flags: YoutubePlayerFlags(
          autoPlay: false,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        YoutubePlayer(
          controller: controller!,
          showVideoProgressIndicator: true,
        ),
        const SizedBox(
          height: 16.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            widget.videoModel.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 16.0,)
      ],
    );
  }

  @override
  void dispose(){
    super.dispose();
    controller!.dispose();
  }
}
