import 'package:calender_scheduler/component/calendar.dart';
import 'package:calender_scheduler/component/schedule_card.dart';
import 'package:calender_scheduler/component/today_banner.dart';
import 'package:calender_scheduler/const/color.dart';
import 'package:calender_scheduler/model/schedule_with_color.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
//import '../component/schedule_bottom_sheet.dart';
import 'package:calender_scheduler/component/schedule_bottom_sheet.dart';
import 'package:calender_scheduler/database/drift_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // selectedDay 상태관리
  DateTime selectedDay = DateTime.utc(
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );
  DateTime focusedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton:
          renderFloatingActionButton(), //floatingActionButton 는 하단 바
      body: SafeArea(
        child: Column(
          children: [
            Calendar(
              selectedDay: selectedDay,
              focusedDay: focusedDay,
              onDaySelected: onDaySelected,
            ),
            SizedBox(height: 8.0),
            TodayBanner(
              selectedDay: selectedDay,
              //scheduleCount: 3,
            ),
            SizedBox(height: 8.0),
            _ScheduleList(
              selectedDate: selectedDay,
            ),
          ],
        ),
      ),
    );
  }

  //하단바 세팅
  FloatingActionButton renderFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        showModalBottomSheet(
          //밑에서 나오는 다이얼
          context: context,
          isScrollControlled:
              true, //기본적으로 화면 반만 쓰지만 이 코드를 넣으면 화면 전체를 사용할 수 있다. 사용하는 이유는 키보드나오면 바텀시트도 올라가기 위해서 사용함
          builder: (_) {
            return ScheduleBottomSheet(
              selectedDate: selectedDay,
            );
          },
        );
      },
      backgroundColor: PRIMARY_COLOR,
      child: Icon(Icons.add),
    );
  }

  //처음에 며칠을 보여줄지
  onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      this.selectedDay = selectedDay; //캘린더가 바라보고있는 날짜 선택시
      this.focusedDay =
          selectedDay; //캘린더가 바라보지 않고 있는 날짜 누르면 2월에서 1월 31일을 누르면 1월로 이동되는거
    });
  }
}

//리스트뷰
class _ScheduleList extends StatelessWidget {
  final DateTime selectedDate;

  const _ScheduleList({required this.selectedDate, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: StreamBuilder<List<ScheduleWithColor>>(
            stream: GetIt.I<LocalDatabase>()
                .watchSchedules(selectedDate), // 왜 오류인지 모르겟음
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasData && snapshot.data!.isEmpty) {
                return Center(
                  child: Text('스케줄이 없습니다.'),
                );
              }

              return ListView.separated(
                //ListView.separated는 리스트사이에 먼가를 넣을 수 있음     //ListView.builder는 한번에 화면에 그리는 것이 아닌 스크롤을 내려서 해당인덱스에 도달하면 그떄서야 그림 메모리에 상당히 유리함
                itemCount: snapshot.data!.length, //리스트뷰를 몇개 할건지
                separatorBuilder: (context, index) {
                  //ListView.separated를 사용하여 넣은 거 리스트사이에 사이즈드박스로 빈공간을 만듬
                  return const SizedBox(height: 8.0);
                },
                itemBuilder: (context, index) {
                  final scheduleWithColor = snapshot.data![index];

                  return Dismissible(
                    //밀어서 삭제하기
                    key: ObjectKey(scheduleWithColor.schedule.id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (DismissDirection direction) {
                      GetIt.I<LocalDatabase>()
                          .removeSchedule(scheduleWithColor.schedule.id);
                    },
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          //밑에서 나오는 다이얼
                          context: context,
                          isScrollControlled:
                              true, //기본적으로 화면 반만 쓰지만 이 코드를 넣으면 화면 전체를 사용할 수 있다. 사용하는 이유는 키보드나오면 바텀시트도 올라가기 위해서 사용함
                          builder: (_) {
                            return ScheduleBottomSheet(
                              selectedDate: selectedDate,
                              scheduleId: scheduleWithColor.schedule.id,
                            );
                          },
                        );
                      },
                      child: ScheduleCard(
                        startTime: scheduleWithColor.schedule.startTime,
                        endTime: scheduleWithColor.schedule.endTime,
                        content: scheduleWithColor.schedule.content,
                        color: Color(int.parse(
                            'FF${scheduleWithColor.categoryColor.hexCode}',
                            radix: 16)),
                      ),
                    ),
                  );
                },
              );
            }),
      ),
    );
  }
}
