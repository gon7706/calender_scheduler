import 'package:drift/drift.dart';

//column 구현 한거임, 스케쥴이라는 테이블안에 각 속성들 생성
class Schedules extends Table{
  //PRIMARY KEY , autoIncrement = 자동으로 숫자를 늘리라는 말
  IntColumn get id => integer().autoIncrement()();

  //내용
  TextColumn get content => text()();

  //일정 날짜
  DateTimeColumn get date => dateTime()();

  //시작 시간
  IntColumn get startTime => integer()();

  // 끝시간
  IntColumn get endTime => integer()();

  //Category Color Table ID
  IntColumn get colorId => integer()();

  //생성날짜, clientDefault(() => DateTime.now()) = 시스템 날짜
  DateTimeColumn get createdAt => dateTime().clientDefault(() => DateTime.now())();


}