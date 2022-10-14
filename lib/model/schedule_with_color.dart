import 'package:calender_scheduler/database/drift_database.dart';
import 'package:calender_scheduler/model/category_color.dart';

class ScheduleWithColor{
  final Schedule schedule;
  final CategoryColor categoryColor;

  ScheduleWithColor({
    required this.schedule,
    required this.categoryColor,
});
}