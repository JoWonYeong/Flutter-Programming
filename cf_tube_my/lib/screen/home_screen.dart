import 'package:flutter/material.dart';
import 'package:cf_tube_my/component/custom_youtube_player.dart';
import 'package:cf_tube_my/model/video_model.dart';
import 'package:cf_tube_my/repository/youtube_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            '유우튜브',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.black,
        ),
        body: FutureBuilder<List<VideoModel>>(
          future: YoutubeRepository.getVideos(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error.toString()),
              );
            }
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: snapshot.data!
                      .map((e) => CustomYoutubePlayer(videoModel: e))
                      .toList(),
                ));
          },
        )
    );
  }
}
