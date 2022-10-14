// private 값들은 불러올 수 없다.
import 'dart:io';

import 'package:calender_scheduler/model/category_color.dart';
import 'package:calender_scheduler/model/schedule.dart';
import 'package:calender_scheduler/model/schedule_with_color.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

// private 값도 불러올 수 있따.
part 'drift_database.g.dart';

//데코레이터, 어떤 테이블을 쓸지
@DriftDatabase(tables: [
  Schedules,
  CategoryColors,
])
//디비 만듬
// _$ 붙은 애들은 시스템에서 알아서 만들어지고 part 'drift_database.g.dart'; 여기에 만들어짐 이름은 클래스 이름복붙에 _$앞에 붙어줘야함
class LocalDatabase extends _$LocalDatabase {
  LocalDatabase() : super(_openConnection());

  //데이터 가져오는 쿼리
  Future<Schedule> getScheduleById(int id) =>
      (select(schedules)..where((tbl) => tbl.id.equals(id))).getSingle(); //.getSingle() 하나만 가져와라

  Future<int> createSchedule(SchedulesCompanion data) =>
      into(schedules).insert(data);

  Future<int> createCategoryColor(CategoryColorsCompanion data) =>
      into(categoryColors).insert(data);

  Future<List<CategoryColor>> getCategoryColors() =>
      select(categoryColors).get();

  //삭제하는 쿼리
  Future<int> removeSchedule(int id) => (delete(schedules)..where((tbl) => tbl.id.equals(id))).go();

  //업데이트 쿼리
  Future<int> updateScheduleById(int id, SchedulesCompanion data) =>
      (update(schedules)..where((tbl) => tbl.id.equals(id))).write(data);

  Stream<List<ScheduleWithColor>> watchSchedules(DateTime date) {
    final query = select(schedules).join([
      innerJoin(categoryColors, categoryColors.id.equalsExp(schedules.colorId))
    ]);

    query.where(schedules.date.equals(date));
    query.orderBy([
      OrderingTerm.asc(schedules.startTime),
    ]);

    return query.watch().map(
          (rows) => rows.map(
            (row) => ScheduleWithColor(
              schedule: row.readTable(schedules),
              categoryColor: row.readTable(categoryColors),
            ),
          ).toList(),
        );
  }
  //스트림과 워치를 사용해서 변경된 값을 지속적으로 받을 수 있따.
  //where 문 위에꺼, ..설명은 강의보삼

  //테이블 변경마다 숫자를 늘려줘야한다.
  @override
  int get schemaVersion => 1;
}

//_openConnection 연결하는 방법
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory(); //디비 배정받은 폴더위치에
    final file = File(p.join(dbFolder.path,
        'db.sqlite')); //배정받은 폴더 경로에 db.sqlite라는 이름으로 저장, 위에 정보들을 저장
    return NativeDatabase(file);
  });
}
