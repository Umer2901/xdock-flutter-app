import 'package:coldxpress/export.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

int tabIndex = 1;

class _DashboardViewState extends State<DashboardView> {
  @override
  Widget build(BuildContext context) {
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
        currentIndex: tabIndex,
        selectedItemColor: AppColors.blue,
        unselectedItemColor: AppColors.navyBlue,
        selectedLabelStyle:
            GoogleFonts.nunito(fontSize: 10.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle:
            GoogleFonts.nunito(fontSize: 10.sp, fontWeight: FontWeight.w600),
        onTap: (int index) {
          setState(() {
            tabIndex = index;
            print(index);
          });
        },
      ),
      body: tabIndex == 0
          ? const MyConsigmentTab()
          : tabIndex == 1
              ? const HomeTab()
              : const SingleConsigmentView(),
    );
  }
}
