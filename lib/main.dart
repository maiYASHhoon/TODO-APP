import 'package:flutter/material.dart';
import 'package:flutter_todo/Ui/home_page.dart';
import 'package:flutter_todo/Ui/splash_screen.dart';
import 'package:flutter_todo/Ui/widgets/add_task_bar.dart';
import 'package:flutter_todo/date_calendar.dart';
import 'package:flutter_todo/db/db_helper.dart';
import 'package:flutter_todo/services/theme_services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'Ui/theme.dart';
/*
author:
description:
date:
*/


// database initializer
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDb();
  await GetStorage.init();
  runApp(const MyApp());
}

// main class of the appliaction
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
        title: 'Do-Todo',
        debugShowCheckedModeBanner: false,
        theme: Themes.light,
        darkTheme: Themes.dark,
        themeMode: ThemeServices().theme,
        home: SplashScreen());
  }
}
