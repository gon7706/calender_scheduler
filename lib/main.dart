import 'package:calender_scheduler/model/category_color.dart';
import 'package:calender_scheduler/screen/home_screen.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:calender_scheduler/database/drift_database.dart';

const DEFAUALT_COLORS = [
  //빨강
  'F44336',
  //주황
  'FF9800',
  //노랑
  'FFEB3B',
  //초록
  'FCAF50',
  //파랑
  '2196F3',
  //남색
  '3F51B5',
  //보라
  '9C27B0',
];

void main() async {
  //메인함수에 사용가능하대
  WidgetsFlutterBinding
      .ensureInitialized(); //이코드는 플러터프레임워크가 준비됐는지 확인하는 코드, 원래는 런앱할떄 자동으로 됨

  await initializeDateFormatting(); //intl패키지를 런앱하기전에 초기화해줌

  final database = LocalDatabase(); //데이터 베이스 생성

  GetIt.I.registerSingleton<LocalDatabase>(
      database); //GetIT를 사용하여 어디서든 (dateabase)값을 가져올수 있음 따로 파라미터를 안들고와도 상관없음

  final colors = await database.getCategoryColors();

  if (colors.isEmpty) {
    for (String hexCode in DEFAUALT_COLORS) {
      await database.createCategoryColor(
        CategoryColorsCompanion(
          hexCode: Value(hexCode),
        ),
      );
    }
  }

  runApp(
    MaterialApp(
      theme: ThemeData(fontFamily: 'NotoSans'),
      home: HomeScreen(),
    ),
  );
}
