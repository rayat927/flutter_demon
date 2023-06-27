import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:untitled/components/TextField.dart';
import 'package:untitled/components/Button.dart';
import 'package:http/http.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';


class Login extends StatefulWidget {
   Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
    final usernameController = TextEditingController();

    final passwordController = TextEditingController();

    final GoogleSignIn _googleSignIn = GoogleSignIn();



    final FirebaseAuth auth = FirebaseAuth.instance;

    Map<String, dynamic> user = {};

   final TextEditingController phoneController = TextEditingController(text: "+880");

   final TextEditingController otpController = TextEditingController();

    bool otpVisibility = false;

    String verificationID = "";

  void signUserIn(context) async {
    print(phoneController.text);
    final res = await get(Uri.parse('http://192.168.0.105:5000/users/${phoneController.text}'));
    print(res.body);
    if(jsonDecode(res.body)["no_results"]){
      Fluttertoast.showToast(
          msg: "Phone number doesn't exist",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }else{
      setState(() {
        user = jsonDecode(res.body)["result"][0];
        print(user);
      });
      auth.verifyPhoneNumber(
        phoneNumber: phoneController.text,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential).then((value){
            print("You are logged in successfully");
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (String verificationId, int? resendToken) {
          print(verificationId);
          otpVisibility = true;
          verificationID = verificationId;
          setState(() {});
        },
        codeAutoRetrievalTimeout: (String verificationId) {

        },
      );

    }



      // Navigator.pushNamed(context, '/superadmin');
  }

   void verifyOTP() async {
     final SharedPreferences prefs = await SharedPreferences.getInstance();

     PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationID, smsCode: otpController.text);

     await auth.signInWithCredential(credential).then((value) async{
       print("You are logged in successfully");
       if(user["role"] == 'Admin'){
         await prefs.setString('user', jsonEncode(user));
         Navigator.pushNamed(context, '/seller');
       }

       Fluttertoast.showToast(
           msg: "You are logged in successfully",
           toastLength: Toast.LENGTH_SHORT,
           gravity: ToastGravity.CENTER,
           timeInSecForIosWeb: 1,
           backgroundColor: Colors.red,
           textColor: Colors.white,
           fontSize: 16.0
       );
     });
   }

   // void loginWithPhone() async {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body:  SafeArea(
        child: Center(
          child: Column(
            children :  [
              const Icon(
                  Icons.lock,
                  size: 100,
              ),
             const SizedBox(height: 50,),

              LoginTextField(
                controller: phoneController,
                hintText: 'Phone Number',
                obscureText: false,
                textinputtypephone: true,
              ),

              const SizedBox(height: 50,),

              Padding(
                padding:  const EdgeInsets.symmetric(horizontal: 25.0),
                child: Visibility(child: TextField(
                  controller: otpController,
                  decoration: InputDecoration(
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade400),
                      ),
                      fillColor: Colors.grey.shade200,
                      filled: true,
                      hintText: 'Otp Code',
                      hintStyle: TextStyle(color: Colors.grey[500])),
                  keyboardType: TextInputType.number,
                ),visible: otpVisibility,),
              ),


              const SizedBox(height: 10),

              // password textfield
              // LoginTextField(
              //   controller: passwordController,
              //   hintText: 'Password',
              //   obscureText: true,
              // ),
              // const SizedBox(height: 25),

              // sign in button
              Button(
                onTap: () => {
                if(otpVisibility){
                  verifyOTP()
                }else{
                  signUserIn(context)
              }
                },
              ),

              const SizedBox(height: 25),

              MaterialButton(
                onPressed: () {
                  _googleSignIn.signIn().then((userData) {
                    // setState(() {
                    //   _isLoggedIn = true;
                    //   _userObj = userData!;
                    // });
                  }).catchError((e) {
                    print(e);
                  });
                },
                height: 50,
                minWidth: 100,
                color: Colors.red,
                child: const Text('Google Signin',style: TextStyle(color: Colors.white),),
              ),

              const SizedBox(height: 32,),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'If you do not have an account',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    child:  Text(
                      'Register now',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () { Navigator.pushNamed(context, '/signup'); },
                  ),
                ],
              )
            ],
          ),
        ),
      )
    );
  }
}


// class Login extends StatefulWidget {
//   const Login({Key? key}) : super(key: key);
//
//   @override
//   State<Login> createState() => _LoginState();
// }
//
// class _LoginState extends State<Login> {
//   @override
//
//   final usernameController = TextEditingController();
//   final passwordController = TextEditingController();
//
//   void signUserIn() {
//
//   }
//
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[300],
//       body: const SafeArea(
//         child: Center(
//           child: Column(
//             children : [
//               Icon(
//                   Icons.lock,
//                   size: 100,
//               ),
//               SizedBox(height: 50,),
//
//               LoginTextField(
//                 controller: usernameController,
//                 hintText: 'Username',
//                 obscureText: false,
//               ),
//
//               const SizedBox(height: 10),
//
//               // password textfield
//               LoginTextField(
//                 controller: passwordController,
//                 hintText: 'Password',
//                 obscureText: true,
//               ),
//               const SizedBox(height: 25),
//
//               // sign in button
//               Button(
//                 onTap: signUserIn,
//               ),
//             ],
//           ),
//         ),
//       )
//     );
//   }
// }
