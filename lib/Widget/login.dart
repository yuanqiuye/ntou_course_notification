import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ntou_course_notification/Backend/service.dart';
import './../Storage/storage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State {
  //焦點
  FocusNode _focusNodeUserName = FocusNode();
  FocusNode _focusNodePassWord = FocusNode();
  bool isNotLoading = true;
  //使用者名稱輸入框控制器，此控制器可以監聽使用者名稱輸入框操作
  TextEditingController _userNameController = TextEditingController();
  //表單狀態
  GlobalKey<FormState> _formKey = GlobalKey();
  String _password = ''; //使用者名稱
  String _username = ''; //密碼
  var _isShowPwd = false; //是否顯示密碼
  var _isShowClear = false; //是否顯示輸入框尾部的清除按鈕
  @override
  void initState() {
    // TODO: implement initState
    //設定焦點監聽
    _focusNodeUserName.addListener(_focusNodeListener);
    _focusNodePassWord.addListener(_focusNodeListener);
    //監聽使用者名稱框的輸入改變
    _userNameController.addListener(() {
      print(_userNameController.text);
      // 監聽文字框輸入變化，當有內容的時候，顯示尾部清除按鈕，否則不顯示
      if (_userNameController.text.length > 0) {
        _isShowClear = true;
      } else {
        _isShowClear = false;
      }
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // 移除焦點監聽
    _focusNodeUserName.removeListener(_focusNodeListener);
    _focusNodePassWord.removeListener(_focusNodeListener);
    _userNameController.dispose();
    super.dispose();
  }

  // 監聽焦點
  Future _focusNodeListener() async {
    if (_focusNodeUserName.hasFocus) {
      print("使用者名稱框獲取焦點");
      // 取消密碼框的焦點狀態
      _focusNodePassWord.unfocus();
    }
    if (_focusNodePassWord.hasFocus) {
      print("密碼框獲取焦點");
      // 取消使用者名稱框焦點狀態
      _focusNodeUserName.unfocus();
    }
  }

  /**
   * 驗證使用者名稱
   */
  String? validateUserName(value) {
    // 正則匹配手機號
    RegExp exp = RegExp(r'^\d{8}$');
    if (value.isEmpty) {
      return '使用者名稱不能為空!';
    } else if (!exp.hasMatch(value)) {
      return '請輸入正確帳號';
    }
    return null;
  }

  /**
   * 驗證密碼
   */
  String? validatePassWord(value) {
    if (value.isEmpty) {
      return '密碼不能為空';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: const Size(750, 1334));
    print(ScreenUtil().scaleHeight);
    //logo 圖片區域
    Widget logoImageArea = Container(
      alignment: Alignment.topCenter,
      //設定圖片為圓形
      child: ClipOval(
        child: Image.asset(
          "assets/logo.jpg",
          height: 100,
          width: 100,
          fit: BoxFit.cover,
        ),
      ),
    );

    //輸入文字框區域
    Widget inputTextArea = Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: Colors.white),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _userNameController,
              focusNode: _focusNodeUserName,
              //設定鍵盤型別
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "使用者名稱",
                hintText: "請輸入帳號",
                prefixIcon: Icon(Icons.person),
                //尾部新增清除按鈕
                suffixIcon: (_isShowClear)
                    ? IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          // 清空輸入框內容
                          _userNameController.clear();
                        },
                      )
                    : null,
              ),
              //驗證使用者名稱
              validator: validateUserName,
              //儲存資料
              onSaved: (value) {
                _username = value!;
              },
            ),
            TextFormField(
              focusNode: _focusNodePassWord,
              decoration: InputDecoration(
                  labelText: "密碼",
                  hintText: "請輸入密碼",
                  prefixIcon: Icon(Icons.lock),
                  // 是否顯示密碼
                  suffixIcon: IconButton(
                    icon: Icon(
                        (_isShowPwd) ? Icons.visibility : Icons.visibility_off),
                    // 點選改變顯示或隱藏密碼
                    onPressed: () {
                      setState(() {
                        _isShowPwd = !_isShowPwd;
                      });
                    },
                  )),
              obscureText: !_isShowPwd,
              //密碼驗證
              validator: validatePassWord,
              //儲存資料
              onSaved: (value) {
                _password = value!;
              },
            )
          ],
        ),
      ),
    );
    // 登入按鈕區域
    Widget loginButtonArea = isNotLoading
        ? Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            height: 45.0,
            child: RaisedButton(
              color: Colors.blue[300],
              child: Text("登入"),
              // 設定按鈕圓角
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              onPressed: () async {
                //點選登入按鈕，解除焦點，回收鍵盤
                _focusNodePassWord.unfocus();
                _focusNodeUserName.unfocus();
                final form = _formKey.currentState!;
                if (form.validate()) {
                  setState(() {
                    isNotLoading = !isNotLoading;
                  });
                  //只有輸入通過驗證，才會執行這裡
                  form.save();
                  var student = Ntou_service();
                  var loginState = await student.init(_username, _password);

                  if (loginState == false) {
                    setState(() {
                      isNotLoading = !isNotLoading;
                    });
                    ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 4),
                          content: Text(
                            "登入失敗!",
                          ),
                        ),
                      );
                  } else {
                    var syear = int.parse(_username.substring(1, 3));
                    var data = await student.get_course(100 + syear, 110, 1);
                    setState(() {
                      isNotLoading = !isNotLoading;
                    });
                    print("$_username + $_password");
                    print(data);
                    Navigator.pushNamed(context, '/table', arguments: data);
                  }
                }
              },
            ),
          )
        : const Center(child: CircularProgressIndicator());
    //第三方登入區域

    //忘記密碼  立即註冊
    // Widget bottomArea = Container(
    //   margin: EdgeInsets.only(right: 20,left: 30),
    //   child: Row(
    //     mainAxisSize: MainAxisSize.max,
    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //     children: [
    //       FlatButton(
    //         child: Text(
    //           "忘記密碼?",
    //           style: TextStyle(
    //             color: Colors.blue[400],
    //             fontSize: 16.0,
    //           ),
    //         ),
    //         //忘記密碼按鈕，點選執行事件
    //         onPressed: (){
    //         },
    //       ),
    //       FlatButton(
    //         child: Text(
    //           "快速註冊",
    //           style: TextStyle(
    //             color: Colors.blue[400],
    //             fontSize: 16.0,
    //           ),
    //         ),
    //         //點選快速註冊、執行事件
    //         onPressed: (){
    //         },
    //       )
    //     ],
    //   ),
    // );
    return Scaffold(
      backgroundColor: Colors.white,
      // 外層新增一個手勢，用於點選空白部分，回收鍵盤
      body: GestureDetector(
        onTap: () {
          // 點選空白區域，回收鍵盤
          print("點選了空白區域");
          _focusNodePassWord.unfocus();
          _focusNodeUserName.unfocus();
        },
        child: ListView(
          children: [
            SizedBox(
              height: ScreenUtil().setHeight(80),
            ),
            logoImageArea,
            SizedBox(
              height: ScreenUtil().setHeight(70),
            ),
            inputTextArea,
            SizedBox(
              height: ScreenUtil().setHeight(80),
            ),
            loginButtonArea,
            SizedBox(
              height: ScreenUtil().setHeight(60),
            ),
            SizedBox(
              height: ScreenUtil().setHeight(60),
            ),
          ],
        ),
      ),
    );
  }
}
