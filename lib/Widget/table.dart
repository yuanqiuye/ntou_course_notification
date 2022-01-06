import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ntou_course_notification/Storage/notification.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tuple/tuple.dart';
import './../Storage/storage.dart';

class CourseTable extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TableState();
}

class TableState extends State {
  final dataio db = dataio();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final Map<int, String> weekday = {
    1: "星期一",
    2: "星期二",
    3: "星期三",
    4: "星期四",
    5: "星期五",
  };
  @override
  void initState() {
    db.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: const Size(840, 1425));
    List<List<Map<String, dynamic>?>> data = ModalRoute.of(context)!
        .settings
        .arguments as List<List<Map<String, dynamic>?>>;
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      title: '課表',
      home: Scaffold(
          appBar: AppBar(
            title: const Text("課表"),
          ),
          body: SingleChildScrollView(
              child: Center(
            child: Table(
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                columnWidths: {
                  0: FixedColumnWidth(ScreenUtil().setWidth(168)),
                  1: FixedColumnWidth(ScreenUtil().setWidth(168)),
                  2: FixedColumnWidth(ScreenUtil().setWidth(168)),
                  3: FixedColumnWidth(ScreenUtil().setWidth(168)),
                  4: FixedColumnWidth(ScreenUtil().setWidth(168)),
                },
                border: TableBorder.all(
                  color: Colors.black,
                  width: 2.0,
                  style: BorderStyle.solid,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                children: [
                  TableRow(
                      decoration: BoxDecoration(
                        color: Colors.lightBlue[50],
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                      ),
                      children: [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Text(
                            "M",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(40),
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Text(
                            "T",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(40),
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Text(
                            "W",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(40),
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Text(
                            "T",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(40),
                            ),
                          ),
                        ),
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Text(
                            "F",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: ScreenUtil().setSp(40),
                            ),
                          ),
                        ),
                      ]),
                  ...data.map((prior) {
                    return TableRow(children: [
                      ...prior.sublist(0, 5).map((course) {
                        Color bgColor;
                        if (course != null && course["setTime"] != null) {
                          bgColor = Colors.lightBlue[50]!;
                        } else {
                          bgColor = Colors.white;
                        }
                        return TextButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(bgColor),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            fixedSize: MaterialStateProperty.all(
                              Size.fromHeight(
                                ScreenUtil().setHeight(150),
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: ScreenUtil().setHeight(10),
                                bottom: ScreenUtil().setHeight(10)),
                            child: Text(
                              course != null ? course["cName"]!.toString() : "",
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              softWrap: true,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: ScreenUtil().setSp(33)),
                            ),
                          ),
                          onPressed: () async {
                            await db.waitUntilDone();
                            if (course != null) {
                              final fu = Navigator.pushNamed(
                                  context, '/setting',
                                  arguments: course);
                              fu.then((result) async {
                                if (result == false) {
                                  setState(() => course["setTime"] = null);

                                  await db.dataremove(
                                      [course["weekday"], course["prior"]]);
                                  _scaffoldMessengerKey.currentState!
                                    ..removeCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        duration: const Duration(seconds: 5),
                                        content:
                                            Text(course["cName"] + "的提醒已被刪除"),
                                      ),
                                    );
                                } else if (result != null) {
                                  setState(() => course["setTime"] = Tuple2(
                                      int.parse(
                                          result.toString().substring(5, 7)),
                                      int.parse(
                                          result.toString().substring(7, 9))));
                                  print(result.toString().substring(0, 2));
                                  await db.add([
                                    course["weekday"],
                                    course["prior"]
                                  ], [
                                    course["setTime"].item1,
                                    course["setTime"].item2
                                  ]);
                                  _scaffoldMessengerKey.currentState!
                                    ..removeCurrentSnackBar()
                                    ..showSnackBar(
                                      SnackBar(
                                        duration: const Duration(seconds: 5),
                                        content: Text("提醒已設定在" +
                                            weekday[course["weekday"]]! +
                                            "的" +
                                            result.toString().substring(0, 5)),
                                      ),
                                    );
                                }
                              });
                            }
                          },
                        );
                      }).toList()
                    ]);
                  }).toList()
                ]),
          ))),
    );
  }
}
