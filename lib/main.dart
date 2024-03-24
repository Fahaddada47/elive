import 'dart:io';

import 'package:StreamFlix/ui/channel_list_page.dart';
import 'package:StreamFlix/app/myapp.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, // Corrected property name
  );
  String? token = await FirebaseMessaging.instance.getToken();

  print('FCM Token: $token');

  runApp(MyApp());
}
