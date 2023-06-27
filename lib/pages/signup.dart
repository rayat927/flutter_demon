import 'package:flutter/material.dart';
import 'package:untitled/components/TextField.dart';
import 'package:untitled/components/Button.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart';
import 'dart:convert';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController usernameController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

   TextEditingController phoneController = TextEditingController(text: "+880");

  TextEditingController otpController = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;

  bool otpVisibility = false;

  String verificationID = "";

  String? selectedRole;

  List<String> roles = [
    'Admin',
    'Store Admin',
    'Seller',
    'Viewer'
  ];

  void signUserUp(context) {
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
    // Navigator.pushNamed(context, '/superadmin');
  }

  void verifyOTP() async {

    PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationID, smsCode: otpController.text);

    await auth.signInWithCredential(credential).then((value) async{
      print("You are registered successfully");

      final uri = Uri.parse('http://192.168.0.102:5000/users/add');
      final headers = {'Content-Type': 'application/json'};
      Map<String, dynamic> body = {'username': usernameController.text, 'phone_number': phoneController.text, 'role': selectedRole};
      String jsonBody = json.encode(body);
      final encoding = Encoding.getByName('utf-8');

      Response response = await post(
        uri,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );

      int statusCode = response.statusCode;
      String responseBody = response.body;


      print(responseBody);

      // Navigator.pushNamed(context, '/superadmin');
      Fluttertoast.showToast(
          msg: "You are registered successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const Icon(
                Icons.lock,
                size: 100,
              ),
              const SizedBox(height: 50,),

              LoginTextField(
                controller: usernameController,
                hintText: 'Username',
                obscureText: false,
                textinputtypephone: false,
              ),

              const SizedBox(height: 10),

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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Choose Role',
                    style: TextStyle(fontSize: 24),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: DropdownButton<String>(
                  value: selectedRole,
                  items: roles.map(
                      (role) => DropdownMenuItem<String>(
                        value: role,
                        child: Text(role, style: TextStyle(fontSize: 24),),
                      )
                  ).toList(),
                  onChanged: (role) => setState(() {
                    selectedRole = role;
                  }),
                  hint: Text('Choose Role'),
                  isExpanded: true,
                ),
              ),

              const SizedBox(height: 20),

              // password textfield
              // LoginTextField(
              //   controller: passwordController,
              //   hintText: 'Password',
              //   obscureText: true,
              // ),
              // const SizedBox(height: 25),

              // sign in button
              // Button(
              //   onTap: () => {
              //     if(otpVisibility){
              //       verifyOTP()
              //     }else{
              //       signUserUp(context)
              //     }
              //   },
              // ),
              Container(
                  padding: EdgeInsets.all(32),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.black,
                      minimumSize: const Size.fromHeight(50), // NEW
                    ),
                    child: Text('Sign Up'),
                    onPressed: () {
                          if(otpVisibility){
                            verifyOTP();
                          }else{
                            signUserUp(context);
                          }

                    },
                  )
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  InkWell(
                    child:  Text(
                      'Login now',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () { Navigator.pushNamed(context, '/login'); },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

