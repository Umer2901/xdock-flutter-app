import 'package:coldxpress/export.dart';
import 'package:flutter/material.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

int tabIndex = 1;

class _DashboardViewState extends State<DashboardView> {
  static const List<Widget> tabs = <Widget>[
    MyConsigmentTab(),
    HomeTab(),
    SizedBox(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<BottomNavProvider>(builder: (context, tab, child) {
      return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          iconSize: 20.sp,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: SvgPicture.asset(AppSvgs.cardboardBoxNav),
              label: 'Consignments',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.profile_circled),
              label: 'Profile',
            ),
          ],
          currentIndex: tab.index,
          selectedItemColor: AppColors.blue,
          unselectedItemColor: AppColors.navyBlue,
          selectedLabelStyle:
              GoogleFonts.nunito(fontSize: 10.sp, fontWeight: FontWeight.w600),
          unselectedLabelStyle:
              GoogleFonts.nunito(fontSize: 10.sp, fontWeight: FontWeight.w600),
          onTap: (int index) {
            setState(() {
              tab.changeTabView(index);
            });
          },
        ),
        body: tabs.elementAt(tab.index),
      );
    });
  }
}
