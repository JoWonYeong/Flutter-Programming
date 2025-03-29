import 'package:calendar_scheduler/model/schedule_model.dart';
import 'package:calendar_scheduler/repository/schedule_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ScheduleProvider extends ChangeNotifier {
  final ScheduleRepository repository;

  DateTime selectedDate = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  Map<DateTime, List<ScheduleModel>> cache = {};

  ScheduleProvider({required this.repository}) : super() {
    getSchedules(date: selectedDate);
  }

  void getSchedules({required DateTime date}) async {
    // Get 요청 보냄
    final resp = await repository.getSchedules(date: date);

    // 가져온 일정들을 시작 시간 기준으로 오름차순으로 정렬
    resp.sort((a, b) => a.startTime.compareTo(b.startTime));

    // 선택한 날짜의 일정들 업데이트
    cache.update(date, (value) => resp, ifAbsent: () => resp);
    // 리슨하는 위젯들 업데이트 (위젯 다시 빌드)
    notifyListeners();
  }

  void createSchedule({required ScheduleModel schedule}) async {
    final targetDate = schedule.date;
    final uuid = Uuid();
    final tempId = uuid.v4();
    final newSchedule = schedule.copyWith(
      id: tempId,
    );

    // 긍정적 응답 구간
    // 서버에서 응답을 받기 전에 캐시 먼저 업데이트
    cache.update(
        targetDate,
        (value) => [...value, newSchedule]..sort(
            (a, b) => a.startTime.compareTo(b.startTime),
          ),
        ifAbsent: () => [newSchedule]);
    notifyListeners();

    try {
      final savedSchedule = await repository.createSchedule(schedule: schedule);
      cache.update(
          targetDate,
          (value) => value
              .map((e) => e.id == tempId ? e.copyWith(id: savedSchedule) : e)
              .toList());
    } catch (e) {
      cache.update(
          targetDate, (value) => value.where((e) => e.id != tempId).toList());
    }
    notifyListeners();
  }

  void deleteSchedule({required DateTime date, required String id}) async {
    final targetSchedule = cache[date]!.firstWhere((e) => e.id == id);

    cache.update(date, (value) => value.where((e) => e.id != id).toList(),
        ifAbsent: () => []);
    notifyListeners();

    try {
      await repository.deleteSchedule(id: id);
    } catch (e) {
      cache.update(
          date,
          (value) => [...value, targetSchedule]
            ..sort((a, b) => a.startTime.compareTo(b.startTime)));
    }
    notifyListeners();
  }

  void changeSelectedDate({required DateTime date}) {
    selectedDate = date;
    notifyListeners();
  }
}
