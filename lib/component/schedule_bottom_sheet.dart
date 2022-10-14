import 'package:calender_scheduler/component/custom_text_field.dart';
import 'package:calender_scheduler/const/color.dart';
import 'package:calender_scheduler/model/category_color.dart';
import 'package:calender_scheduler/model/schedule.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:calender_scheduler/database/drift_database.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final int? scheduleId;

  const ScheduleBottomSheet(
      {required this.selectedDate, this.scheduleId, Key? key})
      : super(key: key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey();

  int? startTime;
  int? endTime;
  String? content;
  int? selectedColorId;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context)
        .viewInsets
        .bottom; //키보드로 가려지는 부분의 크기를 가지고 올 수 있다.

    return GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode()); //키보드 어디든 눌러서 닫기
        },
        child: FutureBuilder<Schedule>(
            future: widget.scheduleId == null
                ? null
                : GetIt.I<LocalDatabase>().getScheduleById(widget.scheduleId!),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('스케줄을 불러올 수 없습니다.'),
                );
              }

              //FutureBuilder 처음 실행됐고
              // 로딩중일때
              if (snapshot.connectionState != ConnectionState.none &&
                  !snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              //Future가 실행이되고
              //값이 있는데 단 한번도 startTime이 세팅되지 않았을때
              if (snapshot.hasData && startTime == null) {
                startTime = snapshot.data!.startTime;
                endTime = snapshot.data!.endTime;
                content = snapshot.data!.content;
                selectedColorId = snapshot.data!.colorId;
              }
              return SafeArea(
                child: Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height / 2 + bottomInset,
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: bottomInset), //padding을 바텀인셋만큼 줄수있따.
                    child: Padding(
                      padding: EdgeInsets.only(left: 8, right: 8, top: 16),
                      child: Form(
                        key:
                            formKey, // form의 컨트롤러같은 친구, 폼아래있는 텍스트 필드를 다 컨트롤할 수 있다.
                        autovalidateMode: AutovalidateMode
                            .always, //자동으로 검증해주는거 밑에 계속 떠서 어떻게해라 말하는거
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Time(
                              onStartSaved: (String? val) {
                                startTime = int.parse(val!);
                              },
                              onEndSaved: (String? val) {
                                endTime = int.parse(val!);
                              },
                              startInitialValue: startTime?.toString() ?? '',
                              endInitialValue: endTime?.toString() ?? '',
                            ),
                            const SizedBox(height: 16),
                            _Content(
                              onSaved: (String? val) {
                                content = val;
                              },
                              initialValue: content ?? '',
                            ),
                            SizedBox(height: 8),
                            FutureBuilder<List<CategoryColor>>(
                                future: GetIt.I<LocalDatabase>()
                                    .getCategoryColors(),
                                builder: (context, snapshot) {
                                  //자동으로 첫번쨰(빨간색) 선택되게
                                  if (snapshot.hasData &&
                                      selectedColorId == null &&
                                      snapshot.data!.isNotEmpty) {
                                    selectedColorId = snapshot.data![0].id;
                                  }
                                  return _ColorPicker(
                                    colors: snapshot.hasData
                                        ? snapshot.data!.toList()
                                        : [],
                                    selectedColorId: selectedColorId,
                                    colorIdSetter: (int id) {
                                      setState(() {
                                        selectedColorId = id;
                                      });
                                    },
                                  );
                                }),
                            SizedBox(height: 8),
                            _SaveButton(
                              onPressed: onSavePressed,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }));
  }

  void onSavePressed() async {
    //formKey는 생성을 했는데
    //Form 위젯과 결합을 안했을때
    if (formKey.currentState == null) {
      return;
    }
    //폼을 쓸떄 항상 같은 패턴, validate는 Form 밑에 있는 텍스트필드에 있는애들 전체에 해당함
    if (formKey.currentState!.validate()) {
      //에러가 하나도 없으면 이코드 실행 true, 에러없으면 폼을 저장함 저장해서 onStartSaved 등 온세이브가 모두 실행됨,
      print('yes');
      formKey.currentState!.save();

      if (widget.scheduleId == null) {
        await GetIt.I<LocalDatabase>().createSchedule(SchedulesCompanion(
          date: Value(widget.selectedDate),
          startTime: Value(startTime!),
          endTime: Value(endTime!),
          content: Value(content!),
          colorId: Value(selectedColorId!),
        ));
      } else {
        await GetIt.I<LocalDatabase>().updateScheduleById(
            widget.scheduleId!,
            SchedulesCompanion(
              date: Value(widget.selectedDate),
              startTime: Value(startTime!),
              endTime: Value(endTime!),
              content: Value(content!),
              colorId: Value(selectedColorId!),
            ));
      }

      Navigator.of(context).pop();
    } else {
      //글자가없으면 에러메세지 알려줌
      print('에러가 있습니다.');
    }
  }
}

//텍스트필드위에 글자
class _Time extends StatelessWidget {
  final FormFieldSetter<String> onStartSaved;
  final FormFieldSetter<String> onEndSaved;
  final String startInitialValue;
  final String endInitialValue;

  const _Time(
      {required this.onEndSaved,
      required this.onStartSaved,
      required this.endInitialValue,
      required this.startInitialValue,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            label: '시작시간',
            isTime: true,
            onSaved: onStartSaved,
            initialValue: startInitialValue,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: CustomTextField(
            label: '마감시간',
            isTime: true,
            onSaved: onEndSaved,
            initialValue: endInitialValue,
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final FormFieldSetter<String> onSaved;
  final String initialValue;

  const _Content({required this.onSaved, required this.initialValue, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomTextField(
        label: '내용',
        isTime: false,
        onSaved: onSaved,
        initialValue: initialValue,
      ),
    );
  }
}

typedef ColorIdSetter = Function(int id);

//동그라미 색깔
class _ColorPicker extends StatelessWidget {
  final List<CategoryColor> colors;
  final int? selectedColorId;
  final ColorIdSetter colorIdSetter;

  const _ColorPicker(
      {required this.colors,
      required this.selectedColorId,
      required this.colorIdSetter,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      //Wrap는 ROW의 단점인 옆으로 튀어나갔을때 에러뜨는걸 밑으로 내려줘서 자연스럽게 여러개가 화면에 보인다.
      spacing: 8.0, //각각의 차일드의 사이를 벌려준다.
      runSpacing: 10.0, //차일드의 위아래를 벌려준다.
      children: colors
          .map((e) => GestureDetector(
                onTap: () {
                  colorIdSetter(e.id);
                },
                child: renderColor(
                  e,
                  selectedColorId == e.id,
                ),
              ))
          .toList(),
    );
  }

  Widget renderColor(CategoryColor color, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color(
          int.parse('FF${color.hexCode}', radix: 16),
        ),
        border: isSelected
            ? Border.all(
                color: Colors.black,
                width: 4.0,
              )
            : null,
      ),
      width: 32.0,
      height: 32.0,
    );
  }
}

//저장버튼
class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveButton({required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              primary: PRIMARY_COLOR,
            ),
            child: Text('저장'),
          ),
        ),
      ],
    );
  }
}
