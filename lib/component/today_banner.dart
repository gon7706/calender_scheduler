import 'package:calender_scheduler/const/color.dart';
import 'package:calender_scheduler/model/schedule_with_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:calender_scheduler/database/drift_database.dart';

//캘린더 밑에 배너
class TodayBanner extends StatelessWidget {
  final DateTime selectedDay; //선택된 날짜 받기
 // final int scheduleCount; //리스트에 몇개있는지 받기

  const TodayBanner(
      {required this.selectedDay, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    return Container(
      color: PRIMARY_COLOR,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${selectedDay.year}년 ${selectedDay.month}월 ${selectedDay.day}일',
              style: textStyle,
            ),
            StreamBuilder<List<ScheduleWithColor>>(
              stream: GetIt.I<LocalDatabase>().watchSchedules(selectedDay),
              builder: (context, snapshot) {
                int count = 0;

                if(snapshot.hasData){
                  count = snapshot.data!.length;
                }

                return Text(
                  '$count개',
                  style: textStyle,
                );
              }
            )
          ],
        ),
      ),
    );
  }
}
