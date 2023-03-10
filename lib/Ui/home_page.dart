import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_todo/Ui/theme.dart';
import 'package:flutter_todo/Ui/widgets/add_task_bar.dart';
import 'package:flutter_todo/Ui/widgets/button.dart';
import 'package:flutter_todo/Ui/widgets/task_tile.dart';
import 'package:flutter_todo/controllers/task_controller.dart';
import 'package:flutter_todo/services/theme_services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../Models/task.dart';
import '../services/notification_services.dart';

/*
author: home_page.dart
description: the home page
date: 09:01:23
*/

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

// home page calling date time and notifications
class _HomePageState extends State<HomePage> {
  DateTime _selectedDate = DateTime.now();
  final _taskController = Get.put(TaskController());
  var notifyHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: _appBar(),
      backgroundColor: context.theme.backgroundColor,
      body: Column(
        children: [
          _addTaskBar(),
          _addDateBar(),
          SizedBox(
            height: currentHeight * 0.05,
          ),
          _showTasks(),
        ],
      ),
    );
  }

// show task method in the home page
  _showTasks() {
    return Expanded(
      child: Obx(() {
        return ListView.builder(
            itemCount: _taskController.taskList.length,
            itemBuilder: (_, index) {
              // print(_taskController.taskList.length);
              Task task = _taskController.taskList[index];
              print(task.toJson());
              print(task.repeat);
// beautiful representation is by staggred list
              if (task.repeat == 'Daily') {
                DateTime date =
                    DateFormat.jm().parse(task.startTime.toString());
                var myTime = DateFormat("HH:mm").format(date);
                print(myTime);
                notifyHelper.scheduledNotification(
                    int.parse(myTime.toString().split(":")[0]),
                    int.parse(myTime.toString().split(":")[1]),
                    task);

                return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                          child: Row(
                        children: [
                          GestureDetector(
                              onTap: () {
                                _showBottomSheet(context, task);
                                // print("Tapped");
                              },
                              child: TaskTile(task))
                        ],
                      )),
                    ));
              }
              if (task.date == DateFormat.yMd().format(_selectedDate)) {
                return AnimationConfiguration.staggeredList(
                    position: index,
                    child: SlideAnimation(
                      child: FadeInAnimation(
                          child: Row(
                        children: [
                          GestureDetector(
                              onTap: () {
                                _showBottomSheet(context, task);
                                // print("Tapped");
                              },
                              child: TaskTile(task))
                        ],
                      )),
                    ));
              } else {
                return Container();
              }
            });
      }),
    );
  }

// the bottom sheet which includes the delete and completed task
  _showBottomSheet(BuildContext context, Task task) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 4),
        height: task.isCompleted == 1
            ? MediaQuery.of(context).size.height * 0.24
            : MediaQuery.of(context).size.height * 0.32,
        color: Get.isDarkMode ? darkGreyClr : Colors.white,
        child: Column(
          children: [
            Container(
              height: 6,
              width: 120,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]),
            ),
            Spacer(),
            task.isCompleted == 1
                ? Container()
                : _bottomSheetButton(
                    label: "Task Completed",
                    onTap: () {
                      _taskController.markTaskCompleted(task.id!);
                      Get.back();
                    },
                    clr: primaryClr,
                    context: context),
            _bottomSheetButton(
                label: "Delete Task ",
                onTap: () {
                  _taskController.delete(task);
                  // _taskController.getTasks();
                  Get.back();
                },
                clr: Colors.red[300]!,
                context: context),
            SizedBox(
              height: 20,
            ),
            _bottomSheetButton(
                label: "Close",
                onTap: () {
                  Get.back();
                },
                clr: Colors.red[300]!,
                isClose: true,
                context: context),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  // {values are optional in curly braces}
  _bottomSheetButton(
      {required String label,
      required Function()? onTap,
      required Color clr,
      bool isClose = false,
      required BuildContext context}) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          height: 55,
          width: MediaQuery.of(context).size.width * 0.9,
          // color: isClose == true ? Colors.red : clr,
          decoration: BoxDecoration(
            border: Border.all(
                width: 2,
                color: isClose == true
                    ? Get.isDarkMode
                        ? Colors.grey[600]!
                        : Colors.grey[300]!
                    : clr),
            borderRadius: BorderRadius.circular(20),
            color: isClose == true ? Colors.transparent : clr,
          ),
          child: Center(
            child: Text(
              label,
              style: isClose
                  ? titleStyle
                  : titleStyle.copyWith(color: Colors.white),
            ),
          ),
        ));
  }

// add date option on the top of the calander
  _addDateBar() {
    return Container(
      margin: EdgeInsets.only(
        top: 20.0,
        left: 20.0,
      ),
      child: DatePicker(
        DateTime.now(),
        height: 100,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: primaryClr,
        selectedTextColor: Colors.white,
        dateTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        )),
        dayTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        )),
        monthTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        )),
        onDateChange: (date) {
          // _selectedDate = date;
          setState(() {
            _selectedDate = date;
          });
        },
      ),
    );
  }

  _addTaskBar() {
    return Container(
      margin: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMMd().format(DateTime.now()),
                  style: subHeadingStyle,
                ),
                Text(
                  'Today',
                  style: headingStyle,
                ),
              ],
            ),
          ),
          MyButton(
              label: "+Task",
              onTap: () async {
                await Get.to(() => AddTaskPage());
                _taskController.getTasks();
              })
        ],
      ),
    );
  }

  _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          ThemeServices().switchTheme();
          notifyHelper.displayNotification(
              title: "Theme Changed",
              body: Get.isDarkMode
                  ? "Activated Light Theme"
                  : "Activated Dark Theme");
          // notifyHelper.scheduledNotification();
        },
        child: Icon(
          Get.isDarkMode ? Icons.wb_sunny_outlined : Icons.nightlight_round,
          size: 20,
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
      actions: [
        CircleAvatar(
          backgroundImage: AssetImage(
            'images/profiles.jpg',
          ),
        ),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }
}
