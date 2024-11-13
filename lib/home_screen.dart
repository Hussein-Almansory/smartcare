// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:smartcare/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _makePhoneCall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset(
              'assets/person_logo.png',
              width: 50,
              height: 50,
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good Morning 👋',
                  style: TextStyle(
                    color: AppColors.iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                // SizedBox(
                //   height: 3,
                // ),
                Text(
                  'Mohammed',
                  style: TextStyle(
                    color: AppColors.titleColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                  textAlign: TextAlign.start,
                )
              ],
            )
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(3.0),
            child: IconButton(
              onPressed: () {},
              icon: Image.asset(
                'assets/settings.png',
                width: 30,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'search',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.titleColor,
                      ),
                      // suffixIcon: Padding(
                      //   padding: const EdgeInsets.all(8.0),
                      //   child: SvgPicture.asset(
                      //     'assets/filter.svg',
                      //   ),
                      // ),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Our Services',
                      style: TextStyle(
                        color: AppColors.subtitleColor,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(0, 5),
                            blurRadius: 10,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/Notification.png',
                      width: 30,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Wrap(
                  spacing: 20,
                  runSpacing: 10,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _makePhoneCall('tel:0597924917');
                      },
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Color(0xffF4F4F4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/sppourt.png',
                                width: 50,
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Text(
                                'Smart Call',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.titleColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Color(0xffF4F4F4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/chatbot_svgrepo.png',
                                width: 50,
                              ),
                              SizedBox(
                                height: 25,
                              ),
                              Text(
                                'Smart Chat',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppColors.titleColor,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Color(0xffF4F4F4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/Frequent.png',
                              width: 50,
                            ),
                            SizedBox(
                              height: 13,
                            ),
                            Text(
                              'Frequent Complaints',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.titleColor,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Color(0xffF4F4F4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/wirning.png',
                              width: 50,
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Emergency Services',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.titleColor,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Color(0xffF4F4F4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/speaker.png',
                              width: 50,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Advertisements and Offers',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.titleColor,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Color(0xffF4F4F4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: [
                            Image.asset(
                              'assets/House.png',
                              width: 50,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              'Shared  Facilities',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.titleColor,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
