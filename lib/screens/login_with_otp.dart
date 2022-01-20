import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import 'package:toast/toast.dart';
import 'home_page.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';

class LoginWithOTP extends StatefulWidget {
  const LoginWithOTP({Key key}) : super(key: key);

  @override
  _LoginWithOTPState createState() => _LoginWithOTPState();
}

enum OTPView { PHONE, OTP }

TextEditingController phoneNmr = new TextEditingController();
TextEditingController otpController = new TextEditingController();
final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();

class _LoginWithOTPState extends State<LoginWithOTP> {
  var currentView = OTPView.PHONE;

  @override
  void initState() {
    currentView = OTPView.PHONE;
    phoneNmr.clear();
    otpController.clear();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var authVar = Provider.of<DataProviderClass>(context);

    Future<void> _sendOTP() async {
      var res = await authVar.sendOTP(phoneNmr.text.trim());
      if (res == "SENT") {
        _btnController.reset();
        setState(() {
          currentView = OTPView.OTP;
        });
      } else {
        Toast.show("⚠️ Invalid Mobile Number !", context, duration: 2, gravity: Toast.BOTTOM);
        _btnController.reset();
      }
    }

    Future<void> _verifyOTP() async {
      var res = await authVar.verifyOTP(phoneNmr.text.trim(), otpController.text);
      if (res == "OK") {
        _btnController.success();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (Route<dynamic> route) => false,
        );
      } else {
        Toast.show("⚠️ " + res + " !", context, duration: 2, gravity: Toast.BOTTOM);
        _btnController.reset();
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
        title: Text("Login with OTP"),
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
            currentView == OTPView.PHONE
                ? Column(
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
                          controller: phoneNmr,
                          autofocus: false,
                          decoration: InputDecoration(
                            labelText: "Mobile Number",
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
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: MediaQuery.of(context).size.height * 0.06,
                        child: RoundedLoadingButton(
                          color: mainColor,
                          borderRadius: 5,
                          width: MediaQuery.of(context).size.width,
                          child: Text('Get Verification Code', style: TextStyle(color: Colors.white, fontSize: 20)),
                          controller: _btnController,
                          onPressed: () {
                            FocusManager.instance.primaryFocus.unfocus();
                            if (phoneNmr.text == '') {
                              Toast.show("⚠️ Enter Mobile Number !", context, duration: 2, gravity: Toast.BOTTOM);
                              _btnController.reset();
                            } else {
                              if (phoneNmr.text.trim().length != 10) {
                                Toast.show("⚠️ Invalid Mobile Number !", context, duration: 2, gravity: Toast.BOTTOM);
                                _btnController.reset();
                              } else {
                                _sendOTP();
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                      Text(
                        "Please Enter Your verification Code\nsent to your Mobile",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textLight,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                      Container(
                        child: OTPTextField(
                          onCompleted: (code) {
                            otpController.text = code;
                          },
                          onChanged: (pin) => print(pin),
                          width: MediaQuery.of(context).size.width * 0.75,
                          length: 4,
                          fieldStyle: FieldStyle.box,
                          outlineBorderRadius: 5,
                          fieldWidth: MediaQuery.of(context).size.width / 7,
                          style: TextStyle(
                            color: Colors.black45,
                            fontWeight: FontWeight.w900,
                          ),
                          otpFieldStyle: OtpFieldStyle(backgroundColor: Colors.white, focusBorderColor: mainColor),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      TextButton(
                        onPressed: () {
                          _sendOTP();
                        },
                        child: Text(
                          "Resend OTP",
                          style: TextStyle(
                            fontSize: 22,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        height: MediaQuery.of(context).size.height * 0.06,
                        child: RoundedLoadingButton(
                          color: mainColor,
                          borderRadius: 5,
                          width: MediaQuery.of(context).size.width,
                          child: Text('Verify Code', style: TextStyle(color: Colors.white, fontSize: 20)),
                          controller: _btnController,
                          onPressed: () {
                            _verifyOTP();
                          },
                        ),
                      ),
                    ],
                  ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          ],
        ),
      ),
    );
  }
}
