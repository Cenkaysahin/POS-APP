import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'cart_screen.dart';
import 'analytics_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POSApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    HomeContent(),
    CartScreen(),
    AnalyticsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onItemTapped(1),
        backgroundColor: _selectedIndex == 1 ? Color(0xff8d714a) : Colors.white,
        child: Icon(Icons.shopping_cart),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onTabChanged: _onItemTapped,
        items: [
          NavigationBarItem(
            iconName: 'home',
            label: 'Anasayfa',
            screenIndex: 0,
          ),
          NavigationBarItem(
            iconName: 'analytics',
            label: 'Analiz',
            screenIndex: 2,
          ),
        ],
        background: Colors.white,
        selectedItemColor: Color(0xff8d714a),
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        HomeDateTime(),
        SizedBox(height: 50),
        SlideTransitionExample(),
        SizedBox(height: 50),
        Text(
          'İşlem yapmak için alttaki sekmeleri kullanabilirsiniz',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        Icon(
          Icons.arrow_downward,
          size: 30,
        ),
      ],
    );
  }
}

class HomeDateTime extends StatefulWidget {
  @override
  _HomeDateTimeState createState() => _HomeDateTimeState();
}

class _HomeDateTimeState extends State<HomeDateTime> {
  late String _currentTime;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _currentTime = _getCurrentTime();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
  }

  String _getCurrentTime() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  }

  void _updateTime() {
    setState(() {
      _currentTime = _getCurrentTime();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _currentTime,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

class SlideTransitionExample extends StatefulWidget {
  @override
  _SlideTransitionExampleState createState() => _SlideTransitionExampleState();
}

class _SlideTransitionExampleState extends State<SlideTransitionExample> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/images/logo.png'),
          Text(
            'POS',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          Text(
            'UYGULAMASINA',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            'HOŞGELDİNİZ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class NavigationBarItem {
  final String iconName;
  final String label;
  final int screenIndex;

  NavigationBarItem({required this.iconName, required this.label, required this.screenIndex});
}

class NavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTabChanged;
  final List<NavigationBarItem> items;
  final Color background;
  final Color selectedItemColor;
  final Color unselectedItemColor;

  NavigationBar({
    required this.selectedIndex,
    required this.onTabChanged,
    required this.items,
    this.background = Colors.white,
    this.selectedItemColor = Colors.blue,
    this.unselectedItemColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 8.0,
      color: background,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(1),
              spreadRadius: 2,
              blurRadius: 0,
              offset: Offset(0, -3),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: items.map((item) {
              var index = items.indexOf(item);
              return InkWell(
                onTap: () {
                  onTabChanged(item.screenIndex);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getIconData(item.iconName),
                      color: selectedIndex == item.screenIndex ? selectedItemColor : unselectedItemColor,
                    ),
                    SizedBox(height: 4),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: selectedIndex == item.screenIndex ? selectedItemColor : unselectedItemColor,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'analytics':
        return Icons.analytics;
      default:
        return Icons.error;
    }
  }
}
