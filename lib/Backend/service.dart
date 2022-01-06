import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'dart:io';
import 'package:universal_html/html.dart' as html;
import 'package:universal_html/parsing.dart';
import 'package:tuple/tuple.dart';
import './../Storage/storage.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class Session {
  Map<String, String> headers = {
    "User-Agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36",
    "Access-Control-Allow-Origin": "*", // Required for CORS support to work
    "Access-Control-Allow-Credentials":
        'true', // Required for cookies, authorization headers with HTTPS
    "Access-Control-Allow-Headers":
        "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale",
    "Access-Control-Allow-Headers": "Access-Control-Allow-Origin, Accept"
  };
  Map<String, String> cookies = {"_ga": "GA1.3.1448855449.1637037718"};

  void _updateCookie(http.Response response) {
    String? allSetCookie = response.headers['set-cookie'];

    if (allSetCookie != null) {
      var setCookies = allSetCookie.split(',');
      for (var setCookie in setCookies) {
        var cookies = setCookie.split(';');
        for (var cookie in cookies) {
          _setCookie(cookie);
        }
      }

      headers['Cookie'] = _generateCookieHeader();
    }
  }

  void _setCookie(String rawCookie) {
    if (rawCookie.length > 0) {
      int idx = rawCookie.indexOf("=");
      if (idx >= 0) {
        var key = rawCookie.substring(0, idx).trim();
        var value = rawCookie.substring(idx + 1).trim();
        if (key == 'path' ||
            key == 'Path' ||
            key == 'expires' ||
            key == 'domain' ||
            key == 'SameSite') return;
        cookies[key] = value;
      }
    }
  }

  String _generateCookieHeader() {
    String cookie = "";

    for (var key in cookies.keys) {
      if (cookie.isNotEmpty) cookie += ";";
      cookie += key + "=" + cookies[key]!;
    }

    return cookie;
  }

  Future<dynamic> get(String url) {
    HttpOverrides.global = new MyHttpOverrides();
    return http
        .get(Uri.parse(url), headers: headers)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      _updateCookie(response);

      if (statusCode < 200 || statusCode > 400) {
        throw Exception("Error while fetching data");
      }
      return res;
    });
  }

  Future<dynamic> post(String url, Map<String, String?> body) {
    HttpOverrides.global = new MyHttpOverrides();
    return http
        .post(Uri.parse(url), headers: headers, body: body)
        .then((http.Response response) {
      final String res = response.body;
      final int statusCode = response.statusCode;

      _updateCookie(response);

      if (statusCode < 200 || statusCode > 400) {
        print(res);
        throw Exception("Error while fetching data");
      }
      return res;
    });
  }
}

Future<Tuple2<int, int>?> inDB(dataio db, int weekday, int prior) async {
  List<int>? res = await db.get([weekday, prior]);
  if (res == null) {
    return null;
  } else {
    return Tuple2(res[0], res[1]);
  }
}

class Ntou_service {
  Map<int, Tuple2<int, int>> courseTime = {
    1: const Tuple2(6, 20),
    2: const Tuple2(8, 20),
    3: const Tuple2(9, 20),
    4: const Tuple2(10, 20),
    5: const Tuple2(11, 15),
    6: const Tuple2(12, 10),
    7: const Tuple2(13, 10),
    8: const Tuple2(14, 10),
    9: const Tuple2(15, 10),
    10: const Tuple2(16, 5),
    11: const Tuple2(17, 30),
    12: const Tuple2(18, 30),
    13: const Tuple2(19, 25),
    14: const Tuple2(20, 20),
    15: const Tuple2(21, 15),
  };
  var s = Session();
  String account = "";
  String password = "";
  final dataio db = dataio();
  Future<bool> init(String acc, String pass) async {
    await s.get("https://ais.ntou.edu.tw/Default.aspx");
    await s.get("https://ais.ntou.edu.tw/DefaultQ.aspx");
    var htmlDocument =
        parseHtmlDocument(await s.get("https://ais.ntou.edu.tw/Default.aspx"));

    List<String> ids = [
      "__VIEWSTATE",
      "__VIEWSTATEGENERATOR",
      "__VIEWSTATEENCRYPTED",
      "__EVENTVALIDATION"
    ];
    Map<String, String> loginData = {
      "M_PORTAL_LOGIN_ACNT": acc,
      "M_PW": pass,
      "LGOIN_BTN": "登入/Login"
    };
    ids.forEach((id) {
      loginData[id] =
          htmlDocument.getElementById(id)!.attributes["value"] as String;
    });
    var res = await s.post("https://ais.ntou.edu.tw/Default.aspx", loginData);
    if (res.toString().contains('alert')) {
      return false;
    }
    await s.get("https://ais.ntou.edu.tw/MainFrame.aspx");
    await s.get("https://ais.ntou.edu.tw/MenuTree.aspx");
    return true;
  }

  Future<List<List<Map<String, dynamic>?>>> get_course(
      int SAYEAR, int Q_AYEAR, int Q_SMS) async {
    await db.init();
    var re = await s
        .get("https://ais.ntou.edu.tw/Application/TKE/TKE22/TKE2240_01.aspx");

    var htmlDocument = parseHtmlDocument(re);

    var ids = ["__VIEWSTATE", "__EVENTVALIDATION"];
    Map<String, String?> TKE2240_data = {
      "__VIEWSTATEGENERATOR": "9BE5177E",
      "__CRYSTALSTATECrystalReportViewer":
          "{'common':{'width':'','Height':'','enableDrillDown':true,'drillDownTarget':'_self','printMode':'ActiveX','displayToolbar':true,'pageToTreeRatio':6,'pdfOCP':true,'promptingType':'html','viewerState':'/wEXBAUDY3NzZQUkU3lzdGVtLldlYi5VSS5XZWJDb250cm9scy5XZWJDb250cm9sDxYCHgdWaXNpYmxlaGQFD1JlcG9ydFZpZXdTdGF0ZRcEBQdJTE9JVUlTaAUHUmVmcmVzaGgFB0ZhY3RvcnkFlgFDcnlzdGFsRGVjaXNpb25zLlJlcG9ydFNvdXJjZS5SZXBvcnRTb3VyY2VGYWN0b3J5LENyeXN0YWxEZWNpc2lvbnMuUmVwb3J0U291cmNlLCBWZXJzaW9uPTEzLjAuMjAwMC4wLCBDdWx0dXJlPW5ldXRyYWwsIFB1YmxpY0tleVRva2VuPTY5MmZiZWE1NTIxZTEzMDQFElBhZ2VSZXF1ZXN0Q29udGV4dBcEBRVJc0xhc3RQYWdlTnVtYmVyS25vd25oBQ5MYXN0UGFnZU51bWJlcmYFClBhZ2VOdW1iZXICAQUUSW50ZXJhY3RpdmVTb3J0SW5mb3MUKVhTeXN0ZW0uQnl0ZSwgbXNjb3JsaWIsIFZlcnNpb249NC4wLjAuMCwgQ3VsdHVyZT1uZXV0cmFsLCBQdWJsaWNLZXlUb2tlbj1iNzdhNWM1NjE5MzRlMDg5jQEDPAM/A3gDbQNsAyADdgNlA3IDcwNpA28DbgM9AyIDMQMuAzADIgM/Az4DDQMKAzwDQQNyA3IDYQN5A08DZgNTA28DcgN0A0kDbgNmA28DIAN4A20DbANuA3MDOgN4A3MDaQM9AyIDaAN0A3QDcAM6Ay8DLwN3A3cDdwMuA3cDMwMuA28DcgNnAy8DMgMwAzADMQMvA1gDTQNMA1MDYwNoA2UDbQNhAy0DaQNuA3MDdANhA24DYwNlAyIDIAN4A20DbANuA3MDOgN4A3MDZAM9AyIDaAN0A3QDcAM6Ay8DLwN3A3cDdwMuA3cDMwMuA28DcgNnAy8DMgMwAzADMQMvA1gDTQNMA1MDYwNoA2UDbQNhAyIDIAMvAz4FBHJzSUQFE0NyeXN0YWxSZXBvcnRTb3VyY2U=','rptAlbumOrder':['0'],'toolPanelType':'GroupTree','toolPanelWidth':200,'toolPanelWidthUnit':'px','paramOpts':{'numberFormat':{'groupSeperator':',','decimalSeperator':'.'},'dateFormat':'yyyy/M/d','timeFormat':'H:mm:ss','dateTimeFormat':'yyyy/M/d H:mm:ss','booleanFormat':{'true':'True','false':'False'},'maxNumParameterDefaultValues':'200','canOpenAdvancedDialog':true},'zoom':100,'zoomFromUI':false,'lastRefresh':'0001/1/1 上午 12:00:00'},'curViewId':'0','0':{'rptViewLabel':'主報表','gpTreeCurrentExpandedPaths':{},'vCtxt':'/wEXAwUVSXNMYXN0UGFnZU51bWJlcktub3duaAUOTGFzdFBhZ2VOdW1iZXJmBQpQYWdlTnVtYmVyAgE=','pageNum':1}}",
      "ScriptManager1": "AjaxPanel|QUERY_BTN3",
      "__EVENTTARGET": "",
      "__EVENTARGUMENT": "",
      "__VIEWSTATEENCRYPTED": "",
      "ActivePageControl": "",
      "ColumnFilter": "",
      "SAYEAR": SAYEAR.toString(),
      "printType": "PRINT_2",
      "Q_AYEAR": Q_AYEAR.toString(),
      "Q_SMS": Q_SMS.toString(),
      "PC\$PageSize": "1000",
      "PC\$PageNo": "1",
      "PC2\$PageSize": "1000",
      "PC2\$PageNo": "1",
      "__ASYNCPOST": "true",
      "QUERY_BTN3": "選課課表"
    };
    ids.forEach((id) async {
      TKE2240_data[id] =
          htmlDocument.querySelector("#$id")!.attributes["value"];
    });

    re = await s.post(
        "https://ais.ntou.edu.tw/Application/TKE/TKE22/TKE2240_01.aspx",
        TKE2240_data);
    htmlDocument = parseHtmlDocument(re.replaceAll("<br>", "_"));
    List<List<Map<String, dynamic>?>> week = [];
    Map<int, html.Element> table = htmlDocument
        .querySelector('table[id="table2"]')!
        .children[0]
        .children
        .asMap();
    for (int prior in table.keys) {
      for (int weekday in table[prior]!.children.asMap().keys) {
        if (weekday != 0 && prior != 0) {
          var ell = table[prior]!.children.asMap()[weekday];
          if (!week.asMap().containsKey(prior - 1)) {
            week.add([]);
          }
          Map<String, dynamic> courseData = {};
          print(ell!.text);

          if (ell.text!.length != 1) {
            List<String> dataspl = ell.children[0].text!.split("_");
            courseData["prior"] = prior;
            courseData["cName"] = dataspl[0];
            courseData["cNum"] = dataspl[1];
            courseData["dep"] = dataspl[2];
            courseData["class"] = dataspl[3];
            courseData["loc"] = dataspl[4];
            courseData["time"] = courseTime[prior];
            courseData["weekday"] = weekday;
            courseData["setTime"] = await inDB(db, weekday, prior);
            week[prior - 1].add(courseData);
          } else {
            week[prior - 1].add(null);
          }
        }
      }
    }
    return week;
  }
}

void main() async {
  var student = Ntou_service();
  await student.init("01057101", "d3bzgea3PDcr");
  var week = await student.get_course(110, 110, 1);
  print(week);
}
