import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:untitled/pages/login.dart';
import 'package:untitled/pages/seller/seller.dart';
import 'package:untitled/pages/signup.dart';
import 'package:untitled/pages/store_admin/store_admin.dart';
import 'package:untitled/pages/superadmin/superadmin.dart';
import 'package:untitled/pages/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    initialRoute: '/login',
    routes: {
      '/': (context) => Home(),
      '/login': (context) => Login(),
      '/superadmin': (context) => SuperAdmin(),
      '/store_admin': (context) => StoreAdmin(),
      '/signup': (context) => Signup(),
      '/seller': (context) => Seller(),

    },
  ));
}

