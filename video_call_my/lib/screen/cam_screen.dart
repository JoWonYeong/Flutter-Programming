import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:video_call_my/const/agora.dart';

class CamScreen extends StatefulWidget {
  const CamScreen({Key? key}) : super(key: key);

  @override
  _CamScreenState createState() =>_CamScreenState();
}

class _CamScreenState extends State<CamScreen> {
  RtcEngine? engine; // 아고라 엔진 저장할 변수
  int? uid; // 내 id
  int? otherUid; // 상대방 id

  Future<bool> init() async{
    final resp = await [Permission.camera, Permission.microphone].request();

    final cameraPermission = resp[Permission.camera];
    final micPermission = resp[Permission.microphone];

    if(cameraPermission!= PermissionStatus.granted ||
    micPermission!= PermissionStatus.granted){
      throw '카메라 또는 마이크 권한이 없습니다.';
    }

    if(engine == null){
      // 엔진 정의되지 않았으면 새로 정의
      engine = createAgoraRtcEngine();

      // 아고라 엔진 초기화
      await engine.initialize(
        // 초기화할 때 사용할 설정
        RtcEngineContext(
          appId: APP_ID,
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        )
      );

      engine!.registerEventHandler(
      //   아고라 엔진에서 받을 수 있는 이벤트 값들 등록
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed){
          //   채널 접속에 성공했을 때
            print("🩷채널에 입장했습니다. uid : ${connection.localUid}🩷");
            setState(() {
              this.uid = connection.localUid;
            });
          },
          onLeaveChannel: (RtcConnection connection,RtcStats stats){
          //   채널 퇴장했을 때
            print("👽채널 퇴장👽");
            setState(() {
              uid = null;
            });
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed){
          //   다른 사용자가 접속했을 때 실행
            print("‼️상대가 채널에 입장했습니다. uid : $uid️️️‼️");
            setState(() {
              otherUid = remoteUid;
            });
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason){
            print("💦상대가 채널에서 나갔습니다. uid : $uid💦");
            setState(() {
              otherUid= null;
            });
          }
        )
      );

      await engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await engine!.enableVideo();
      await engine!.startPreview();
    //   채널에 들어가기
      await engine!.joinChannel(
          token: TEMP_TOKEN,
          channelId: CHANNEL_NAME,
          // 영상과 관련된 여러 설정 가능, 이 프로젝트에서는 불필요
          uid: 0,
          options: ChannelMediaOptions()
      );
    }
    return true;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('LIVE'),
      ),
      body: FutureBuilder(
        future: init(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if(snapshot.hasError){
            return Center(
              child: Text(
                snapshot.error.toString()
              ),
            );
          }
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  child:Stack(
                    children: [
                      renderMainView(),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          color: Colors.grey,
                          height: 160,
                          width: 120,
                          child: renderSubView(),
                        ),
                      )
                    ],
                  )
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: ElevatedButton(
                  onPressed: () async{
                    if(engine != null){
                      await engine!.leaveChannel();
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text('채널 나가기'),
                ),
              )
            ],
          );
        },
      )
    );
  }

//   내 핸드폰이 찍는 화면 렌더링
  Widget renderSubView(){
    if(uid!=null){
      // AgoraVideoView 위젯 : 동영상을 화면에 보여주는 위젯 구현
      return AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: engine!,
            canvas: const VideoCanvas(uid:0)
          )
      );
    }
    else {
    //   아직 채널에 접속하지 않았다면 로딩 화면
      return CircularProgressIndicator();
    }
  }

  // 상대 핸드폰이 찍는 화면 렌더링
  Widget renderMainView(){
    if(otherUid != null){
      return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: engine!,
            canvas: VideoCanvas(uid: otherUid),
            connection: const RtcConnection(channelId: CHANNEL_NAME),
          ),
      );
    }
    else{
      return Center(
        child: const Text(
          '다른 사용자가 입장할 때까지 대기해주세요',
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}