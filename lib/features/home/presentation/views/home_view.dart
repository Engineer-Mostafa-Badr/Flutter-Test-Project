import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_text_project/core/resources/app_assets_manager.dart';
import 'package:flutter_text_project/core/resources/app_color_manager.dart';
import 'package:flutter_text_project/features/profile/views/profile_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 0;
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    await _loadUserData();
    await _showWelcomeIfNeeded();
    await _showLastFCMMessage();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('name');
    if (name != null && name.isNotEmpty) {
      setState(() => _userName = name);
    }
  }

  Future<void> _showWelcomeIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final bool welcomeShown = prefs.getBool('welcomeShown') ?? false;
    if (!welcomeShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar("مرحبًا بك, $_userName 👋");
      });
      await prefs.setBool('welcomeShown', true);
    }
  }

  Future<void> _showLastFCMMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final String? msg = prefs.getString("lastMessage");
    if (msg != null && msg.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSnackBar(msg);
      });
      await prefs.remove("lastMessage");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  void _onNavTap(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeContent(userName: _userName),
      const Center(child: Text("Favorites Page")),
      const ProfileView(),
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      selectedItemColor: ColorManager.primaryColor,
      unselectedItemColor: Colors.grey,
      onTap: _onNavTap,
      items: [
        _buildNavItem(AppAssetsManager.home, "Home", 0),
        _buildNavItem(AppAssetsManager.heart, "Favorites", 1),
        _buildNavItem(AppAssetsManager.name, "Profile", 2),
      ],
    );
  }

  BottomNavigationBarItem _buildNavItem(String asset, String label, int index) {
    final color = _currentIndex == index
        ? ColorManager.primaryColor
        : Colors.grey;
    return BottomNavigationBarItem(
      icon: SvgPicture.asset(asset, width: 24, height: 24, color: color),
      label: label,
    );
  }
}

// -------------------- Home Content --------------------
class HomeContent extends StatelessWidget {
  final String userName;

  const HomeContent({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 4.h),
          ProfileCard(name: userName, role: "Investor"),
          SizedBox(height: 4.h),
          const StocksList(),
          SizedBox(height: 4.h),
          const StockChart(),
        ],
      ),
    );
  }
}

// -------------------- Profile Card --------------------
class ProfileCard extends StatelessWidget {
  final String name;
  final String role;

  const ProfileCard({super.key, required this.name, required this.role});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(fontSize: 16.px, fontWeight: FontWeight.bold),
              ),
              Text(
                role,
                style: TextStyle(fontSize: 14.px, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// -------------------- Stocks List --------------------
class StocksList extends StatelessWidget {
  const StocksList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => SizedBox(width: 4.w),
        itemBuilder: (context, index) => const StockCard(
          symbol: "AAPL",
          name: "Apple Inc.",
          price: "\$145.32",
          priceColor: Colors.green,
        ),
      ),
    );
  }
}

class StockCard extends StatelessWidget {
  final String symbol;
  final String name;
  final String price;
  final Color priceColor;

  const StockCard({
    super.key,
    required this.symbol,
    required this.name,
    required this.price,
    required this.priceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            symbol,
            style: TextStyle(fontSize: 16.px, fontWeight: FontWeight.bold),
          ),
          Text(
            name,
            style: TextStyle(fontSize: 14.px, color: Colors.grey),
          ),
          const Spacer(),
          Text(
            price,
            style: TextStyle(
              fontSize: 16.px,
              color: priceColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------- Stock Chart --------------------
class StockChart extends StatelessWidget {
  const StockChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3.w),
      ),
      height: 30.h,
      child: LineChart(
        LineChartData(
          titlesData: FlTitlesData(show: false),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              spots: const [
                FlSpot(0, 1),
                FlSpot(1, 1.5),
                FlSpot(2, 1.4),
                FlSpot(3, 2),
                FlSpot(4, 1.8),
                FlSpot(5, 2.2),
                FlSpot(6, 2.1),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
