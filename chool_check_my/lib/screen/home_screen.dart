import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatelessWidget {
  static final LatLng companyLatLng = LatLng(37.413091, 127.099552);

  // 회사 위치 마커
  static final Marker marker = Marker(
    markerId: MarkerId('company'),
    position: companyLatLng,
  );

  static final Circle circle = Circle(
    circleId: CircleId('choolCheckCircle'),
    center: companyLatLng,
    fillColor: Colors.blue.withOpacity(0.5),
    radius: 100,
    strokeColor: Colors.blue,
    strokeWidth: 1,
  );

  const HomeScreen({Key? key}) : super(key:key);

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: renderAppBar(),
      body: FutureBuilder<String>(
        future: checkPermission(),
        builder: (context, snapshot) {
          // 로딩 상태
          if(!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          // 권한 허가된 상태
          if(snapshot.data == '위치 권한이 허가 되었습니다.'){
            return Column(
              children: [
                Expanded(
                    flex: 2,
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: companyLatLng,
                        zoom: 16,
                      ),
                      myLocationEnabled: true,
                      markers: Set.from([marker]),
                      circles: Set.from([circle]),
                    )
                ),
                Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timelapse_outlined,
                          color: Colors.blue,
                          size: 50.0,
                        ),
                        const SizedBox(height: 20.0,),
                        ElevatedButton(
                          onPressed: () async {
                            // 현재 위치
                            final curPosition = await Geolocator.getCurrentPosition();
                            final distance = Geolocator.distanceBetween(
                                curPosition.latitude,
                                curPosition.longitude,
                                companyLatLng.latitude,
                                companyLatLng.longitude
                            );

                            // 100미터 이내에 있으면 출근 가능
                            bool canCheck = distance < 100;
                            showDialog(
                                context: context,
                                builder: (_) {
                                  return AlertDialog(
                                    title: Text('출근하기'),
                                    // 출근 가능 여부에 따라 다른 메시지 제공
                                    content: Text(
                                      canCheck?'출근을 하시겠습니까?' : '출근할 수 없는 위치입니다.',
                                    ),
                                    actions: [
                                      TextButton(
                                          onPressed: (){
                                            Navigator.of(context).pop(false);
                                          },
                                          child: Text('취소')
                                      ),
                                      if(canCheck)
                                        TextButton(
                                            onPressed: (){
                                              Navigator.of(context).pop(true);
                                            },
                                            child: Text('출근하기')
                                        )
                                    ],
                                  );
                                }
                            );
                          },
                          child: Text('출근하기'),
                        )
                      ],
                    )
                )
              ],
            );
          }
          // 권한 없는 상태
          return Center(
            child: Text(
              snapshot.data.toString()
            ),
          );
        }
      )
    );
  }

  AppBar renderAppBar() {
    return AppBar(
      centerTitle: true,
      title: Text(
        '오늘도 출첵',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Future<String> checkPermission() async {
    // 위치 서비스 활성화 여부 확인
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    // 위치 서비스 활성화 안 된 경우
    if(!isLocationEnabled) {
      return '위치 서비스를 활성화해주세요.';
    }

    // 위치 권한 확인
    LocationPermission checkedPermission = await Geolocator.checkPermission();

    // 위치 권한 거절된 경우
    if (checkedPermission == LocationPermission.denied) {
      // 위치 권한 요청
      checkedPermission = await Geolocator.requestPermission();

      if(checkedPermission == LocationPermission.denied){
        return '위치 권한을 허가해주세요.';
      }
    }

    // 위치 권한 거절됨 (앱에서 재요청 불가)
    if(checkedPermission == LocationPermission.deniedForever){
      return '앱의 위치 권한을 설정에서 허가해주세요.';
    }

    // 위 모든 조건 통과 시 권한 허가 완료
    return '위치 권한이 허가 되었습니다.';
  }
}



