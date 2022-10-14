import 'package:calender_scheduler/const/color.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

/*
class Calendar extends StatefulWidget { stl되면서 없어진 한줄
 아래 stl로 이사감
  final DateTime? selectedDay; //외부에서 상태관리해서 받아옴
  final DateTime focusedDay;
  final OnDaySelected? onDaySelected;

  const Calendar(
      {required this.selectedDay,
      required this.focusedDay,
      required this.onDaySelected,
      Key? key})
      : super(key: key);

 stl 되면서 없어짐
  @override
  State<Calendar> createState() => _CalendarState();
}*/
// selectedDay를 home_screen에서 받아와서 사용함 그래서 widget. 이거 없어됨
class Calendar extends StatelessWidget {  //state에서 StatelessWidget으로 변경 stf보다 stl이 메모리 효율이 더좋아서
  final DateTime? selectedDay; //외부에서 상태관리해서 받아옴
  final DateTime focusedDay;
  final OnDaySelected? onDaySelected;

  const Calendar(
      {required this.selectedDay,
        required this.focusedDay,
        required this.onDaySelected,
        Key? key})
      : super(key: key);

  /* 이코드는 home_screen.dart에서 사용하기 떄문에 상태관리를 홈스크린에서 해줄려고 이사감
  여기있던 관련 코드들은 widget.selectedDay 를 해주면 사용가능함
  DateTime?
      selectedDay; //선택된 날짜 (기본으로 오늘 선택되있게 하고 싶으면  = DateTime.now() 사용하면 됨, 이건 널값으로 선택이 안되어있는다는 가정)
  DateTime focusedDay = DateTime.now();*/

  @override
  Widget build(BuildContext context) {
    //기본 박스데코
    final defaultBoxDeco = BoxDecoration(
      //날짜 요소가 각 컨테이너에 들어있는데 그걸 스타일링할 수 있는거
      borderRadius: BorderRadius.circular(6.0), //박스 조금 둥글게 깍기
      color: Colors.grey[200],
    );
    final defaultTextStyle = TextStyle(
      color: Colors.grey[600],
      fontWeight: FontWeight.w700,
    );
    return TableCalendar(
      locale: 'ko_KR', //한글로 변경(intl 패키지없으면 애러뜸, 메인에 intl패키지 불러옴)
      focusedDay: focusedDay, //처음에 몇월을 보여줘야하는지, 단순 월만 보여짐 날짜에 동그라미되있는거는 오늘날짜, 변수사용하는 이유는 선택한 날짜가 포커스 될수 있게 하기위해서
      firstDay: DateTime(1800), //제일 옛날 날짜를 어떤 날짜로 할지
      lastDay: DateTime(3000), //제일 미래의 날짜를
      headerStyle: HeaderStyle(
        //헤드쪽 스타일 변경
        formatButtonVisible: false, //옆에 2위크 버튼 없애기
        titleCentered: true, //날짜 중앙으로 오게하기
        titleTextStyle: TextStyle(
            //헤더쪽 글짜 스타일 변경
            fontWeight: FontWeight.w700,
            fontSize: 16.0),
      ),
      calendarStyle: CalendarStyle(
        isTodayHighlighted: false, //오늘 날짜가 하이라이트할건지
        defaultDecoration: defaultBoxDeco, //평일 컨테이너 데코
        weekendDecoration: defaultBoxDeco, //주말 컨테이너 데코
        selectedDecoration: BoxDecoration(
          //선택된 컨테이너 데코
          color: Colors.white,
          borderRadius: BorderRadius.circular(6.0),
          border: Border.all(
            color: PRIMARY_COLOR,
            width: 1.0,
          ),
        ),
        outsideDecoration: BoxDecoration(
          //에니메이션 에러 있었는데 잡음, 동그라미에서 네모로 바뀔대 에러났는데 박스데코를 네모를 만들어서 해결함
          shape: BoxShape.rectangle,
        ),
        defaultTextStyle: defaultTextStyle,
        weekendTextStyle: defaultTextStyle,
        selectedTextStyle: defaultTextStyle.copyWith(
          //copyWith = 내가 설정한 거에서 특정값만 바꾸는 기능
          color: PRIMARY_COLOR,
        ),
      ),

      //처음에 캘린더에서 날짜를 고를 떄 실행됨
      onDaySelected: onDaySelected,
      // 선택한 날짜 값을 받아서 테이블캘린더에 넘겨줘야함
      selectedDayPredicate: (DateTime date) {
        //실제 어떤 날짜를 선택했을때(입력받았을때) selectedDay와 같은지 판단하는 코드 세가지 년월일이 같은지 비교하여 조건 맞으면 true를 리턴해줌
        if (selectedDay == null) {
          // selectedDay가 널이면 그냥 넘겨, 밑에 if문에서 !있는 이유 없으면 에러
          return false;
        }
        return date.year == selectedDay!.year &&
            date.month == selectedDay!.month &&
            date.day == selectedDay!.day;
      },
    );
  }
}
