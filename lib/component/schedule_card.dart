import 'dart:io';

import 'package:calender_scheduler/const/color.dart';
import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final int
      startTime; //int 쓰는 이유는 13:00 처럼 나오게할려고 13:22처럼 나오게 할려면 DateTime 사용하면됨
  final int endTime;
  final String content;
  final Color color;

  const ScheduleCard(
      {required this.startTime,
      required this.endTime,
      required this.content,
      required this.color,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1.0,
          color: PRIMARY_COLOR,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: IntrinsicHeight(   //IntrinsicHeight > row가 최대한으로 차지하고 있는 높이 만큼 늘려주는 역할
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Time(
                endTime: endTime,
                startTime: startTime,
              ),
              SizedBox(width: 16.0),
              _Content(content: content),
              SizedBox(width: 16.0),
              _Category(color: color),
            ],
          ),
        ),
      ),
    );
  }
}

//시간
class _Time extends StatelessWidget {
  final int startTime;
  final int endTime;

  const _Time({required this.endTime, required this.startTime, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: PRIMARY_COLOR,
      fontSize: 16.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${startTime.toString().padLeft(2, '0')}:00',
          style: textStyle,
        ), //toString().padLeft(2,'0') 왼쪽에 최소 두글자를 쓰고싶다. 그리고 빈칸은 0으로 하겟다
        Text(
          '${endTime.toString().padLeft(2, '0')}:00',
          style: textStyle.copyWith(fontSize: 10.0),
        ),
      ],
    );
  }
}

//글자
class _Content extends StatelessWidget {
  final String content;

  const _Content({required this.content, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Text(content));
  }
}

//빨간 동그라미
class _Category extends StatelessWidget {
  final Color color;

  const _Category({required this.color, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      width: 16.0,
      height: 16.0,
    );
  }
}
