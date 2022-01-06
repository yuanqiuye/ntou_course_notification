import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuple/tuple.dart';
import './../Storage/notification.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State {
  final Map<int, String> weekday = {
    1: "星期一",
    2: "星期二",
    3: "星期三",
    4: "星期四",
    5: "星期五",
  };
  @override
  GlobalKey<FormState> _formKey = GlobalKey();
  FocusNode _focusNodeHr = FocusNode();
  FocusNode _focusNodeMin = FocusNode();
  var _Hrcontrol = TextEditingController();
  var _Mincontrol = TextEditingController();
  @override
  Widget build(BuildContext context) {
    int _hr = 0;
    int _min = 0;
    Map<String, dynamic>? data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: const Size(840, 1425));
    if (data!["setTime"] != null &&
        _Hrcontrol.text.length == 0 &&
        _Mincontrol.text.length == 0) {
      _Hrcontrol.text = data["setTime"].item1.toString();
      _Mincontrol.text = data["setTime"].item2.toString();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("提醒設定"),
      ),
      body: ListView(
        children: <Widget>[
          const ListTile(leading: Icon(Icons.access_time), title: Text('課程名稱')),
          Padding(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(160)),
            child: Text(
              data["cName"] ?? "",
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(40),
                  height: ScreenUtil().setHeight(2)),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: ScreenUtil().setHeight(2))),
          const ListTile(
              leading: Icon(Icons.calendar_today_rounded), title: Text('課程星期')),
          Padding(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(160)),
            child: Text(
              weekday[data["weekday"]]!,
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(40),
                  height: ScreenUtil().setHeight(2)),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: ScreenUtil().setHeight(2))),
          const ListTile(
              leading: Icon(Icons.access_time), title: Text('課程開始時間')),
          Padding(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(160)),
            child: Text(
              data["time"].item1.toString().padLeft(2, "0") +
                  ":" +
                  data["time"].item2.toString().padLeft(2, "0"),
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(40),
                  height: ScreenUtil().setHeight(2)),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: ScreenUtil().setHeight(2))),
          const ListTile(leading: Icon(Icons.location_on), title: Text('課程地點')),
          Padding(
            padding: EdgeInsets.only(left: ScreenUtil().setWidth(160)),
            child: Text(
              data["loc"],
              style: TextStyle(
                  fontSize: ScreenUtil().setSp(40),
                  height: ScreenUtil().setHeight(2)),
            ),
          ),
          Padding(padding: EdgeInsets.only(top: ScreenUtil().setHeight(2))),
          const ListTile(
              leading: Icon(Icons.alarm_add_rounded), title: Text('要多久之前提醒')),
          Form(
            key: _formKey,
            child: Column(
              children: [
                Row(children: [
                  SizedBox(
                    width: ScreenUtil().setWidth(60),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _Hrcontrol,
                      decoration: const InputDecoration(
                        hintText: "小時",
                        labelText: "請輸入小時",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return '時間不能為空!';
                        } else if (0 > int.parse(value) ||
                            9 < int.parse(value)) {
                          return '請輸入正確時間';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _hr = int.parse(value!);
                      },
                    ),
                  ),
                  SizedBox(
                    width: ScreenUtil().setWidth(60),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _Mincontrol,
                      focusNode: _focusNodeMin,
                      decoration: const InputDecoration(
                        hintText: "分鐘",
                        labelText: "請輸入分鐘",
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return '時間不能為空!';
                        } else if (0 > int.parse(value) ||
                            60 < int.parse(value)) {
                          return '請輸入正確時間';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _min = int.parse(value!);
                      },
                    ),
                  ),
                  SizedBox(
                    width: ScreenUtil().setWidth(60),
                  ),
                ]),
                Divider(height: ScreenUtil().setHeight(2)),
                SizedBox(
                  height: ScreenUtil().setHeight(60),
                ),
                Row(children: [
                  SizedBox(
                    width: ScreenUtil().setWidth(60),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        _focusNodeHr.unfocus();
                        _focusNodeMin.unfocus();
                        final form = _formKey.currentState!;
                        if (form.validate()) {
                          form.save();
                          Future<String> setTime =
                              setNotification(data, _hr, _min);
                          Navigator.pop(context, setTime);
                        }
                      },
                      child: const Text("確定"),
                    ),
                  ),
                  if (data["setTime"] != null) ...[
                    Padding(
                      padding: EdgeInsets.only(
                        left: ScreenUtil().setWidth(60),
                      ),
                    ),
                    Expanded(
                      child: ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red[400])),
                        onPressed: () async {
                          _focusNodeHr.unfocus();
                          _focusNodeMin.unfocus();
                          Future<bool> status = cancelNotification(
                              data["weekday"] * 20 + data["prior"]);
                          Navigator.pop(context, status);
                        },
                        child: const Text("刪除提醒"),
                      ),
                    ),
                  ],
                  SizedBox(
                    width: ScreenUtil().setWidth(60),
                  ),
                ])
              ],
            ),
          )
        ],
      ),
    );
  }
}
