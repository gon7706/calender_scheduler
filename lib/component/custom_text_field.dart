import 'package:calender_scheduler/const/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String initialValue;

  // true- 시간, false- 내용
  final bool isTime;
  final FormFieldSetter<String> onSaved;

  const CustomTextField(
      {required this.label,
      required this.isTime,
      required this.onSaved,
        required this.initialValue,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: PRIMARY_COLOR,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isTime) renderTextField(),
        if (!isTime)
          Expanded(
            child: renderTextField(),
          )
      ],
    );
  }

  Widget renderTextField() {
    return TextFormField(
      //TextFormField 폼사용
      //값을 받는거
      /*onChanged: (String? val){

      },*/
      // 마지막으로 저장을 눌렀을때 값을 가져오기 때문에 외부에서 입력을 해주도록한다.
      onSaved: onSaved,
      //null이 return 되면 에러가 없다.
      //에러가 있으면 에러를 String 값으로 리턴해준다., validator느 검증할때 쓰는거
      validator: (String? val) {
        if (val == null || val.isEmpty) {
          return '값을 입력해주세요';
        }

        if (isTime) {
          int time = int.parse(val);

          if (time < 0) {
            return '0 이상의 숫자를 입력해주세요.';
          }
          if (time > 24) {
            return '24 이하의 숫자를 입력해주세요.';
          }
        } else {
          if (val.length > 500) {
            return '500 이하의 글자를 입력해주세요.';
          }
        }

        return null;
      },
      cursorColor: Colors.grey,
      maxLines: isTime ? 1 : null, //최대 줄의 갯수 널은 무한, isTime 이면은 1줄 아니면 무한
      expands: !isTime, // expands 세로로 최대한 늘리겟다
      initialValue: initialValue,
      keyboardType: isTime
          ? TextInputType.number
          : TextInputType
              .multiline, //키보드 타입을 숫자로 바꾸는기능, 키보드타입이 isTime이면 숫자 아니면 멀티라인(여러줄쓸수 있는거)
      inputFormatters: isTime
          ? [FilteringTextInputFormatter.digitsOnly]
          : [], //isTime 이 아니면 아무것도 안주는거
      decoration: InputDecoration(
        border: InputBorder.none,
        filled: true,
        fillColor: Colors.grey[300],
        suffixText: isTime ? '시' : null, //포커스되면 글자 나오게하게
      ),
    );
  }
}
