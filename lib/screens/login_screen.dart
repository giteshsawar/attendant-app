import '../providers/data_provider.dart';
import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:provider/provider.dart';
import 'home_page.dart';
import 'package:toast/toast.dart';
import 'login_with_otp.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'fragments/confirmExit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

TextEditingController password = new TextEditingController();
TextEditingController emid = new TextEditingController();
final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

class _LoginScreenState extends State<LoginScreen> {
  @override
  void initState() {
    password.clear();
    emid.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var authVar = Provider.of<DataProviderClass>(context);

    Future<void> _tryLogin() async {
      var res = await authVar.loginwithPassword(emid.text, password.text);
      if (res == "OK") {
        _btnController.success();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false,
        );
        //_btnController.reset();
      } else {
        Toast.show("⚠️ " + res + " !", context, duration: 2, gravity: Toast.BOTTOM);
        _btnController.reset();
      }
    }

    return new WillPopScope(
      onWillPop: () {
        confirmExit(context);
        return Future<bool>.value(true);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text("Attendant Login"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(25.0)),
          ),
        ),
        body: Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Image.asset(
                'assets/logo.png',
                height: 70,
              ),
              Text(
                "Complete Car Care",
                style: TextStyle(
                  color: mainColor,
                  fontSize: 22,
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Text(
                  "Sign In to the Revolutionary Complete Car Care Experience",
                  style: TextStyle(
                    color: textLight,
                    fontSize: 17,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: TextField(
                  controller: emid,
                  autofocus: false,
                  decoration: InputDecoration(
                    labelText: "Employee ID",
                    labelStyle: TextStyle(color: mainColor, fontSize: 18),
                    hintStyle: TextStyle(
                      color: Colors.black26,
                    ),
                    border: new UnderlineInputBorder(
                      borderSide: new BorderSide(
                        width: 0.5,
                        color: mainColor,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: TextField(
                  controller: password,
                  autofocus: false,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: TextStyle(color: mainColor, fontSize: 18),
                    hintStyle: TextStyle(
                      color: Colors.black26,
                    ),
                    border: new UnderlineInputBorder(
                      borderSide: new BorderSide(
                        width: 0.5,
                        color: mainColor,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginWithOTP(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.all(24),
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Forgot Password ? ",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(10),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.85,
            height: MediaQuery.of(context).size.height * 0.06,
            child: RoundedLoadingButton(
              color: mainColor,
              borderRadius: 5,
              width: MediaQuery.of(context).size.width,
              child: Text('Login', style: TextStyle(color: Colors.white, fontSize: 20)),
              controller: _btnController,
              onPressed: () {
                FocusManager.instance.primaryFocus.unfocus();
                if (emid.text == '') {
                  Toast.show("⚠️  Employee ID is Required !", context, duration: 2, gravity: Toast.BOTTOM);
                  _btnController.reset();
                } else {
                  if (password.text == '') {
                    Toast.show("⚠️  Password is Required !", context, duration: 2, gravity: Toast.BOTTOM);
                    _btnController.reset();
                  } else {
                    _tryLogin();
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
