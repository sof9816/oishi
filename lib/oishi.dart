import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oishi/screens/web_screen.dart';
import 'configuration.dart';

class Oishi extends StatelessWidget {
  final List<ScreenConfig> screens;
  final List<ButtonConfig> buttons;
  final String? logo;
  final ActionConfig? action;

  const Oishi({
    super.key,
    this.logo,
    required this.screens,
    required this.buttons,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'AE'), // Set to Arabic (UAE)
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('ar', 'AE'), // Arabic
      ],
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.grey,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        ),
      ),
      home: MainScreen(
        logo: logo,
        screens: screens,
        buttons: buttons,
        action: action,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final String? logo;
  final List<ScreenConfig> screens;
  final List<ButtonConfig> buttons;
  final ActionConfig? action;

  const MainScreen({
    super.key,
    this.logo,
    required this.screens,
    required this.buttons,
    this.action,
  });

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  late List<Widget?> _screens;
  final Queue<int> _screenQueue = Queue();
  bool _isQueueProcessing = false;

  @override
  bool get wantKeepAlive => true;
  double iconSize = 24;

  @override
  void initState() {
    super.initState();
    // Initialize the list with actual instances of your screens
    _screens = List<Widget?>.filled(widget.screens.length, null);
    _screenQueue.addAll(List.generate(widget.screens.length, (index) => index));
    _processQueue();
  }

  void _processQueue() {
    if (_isQueueProcessing || _screenQueue.isEmpty) return;
    _isQueueProcessing = true;
    final index = _screenQueue.removeFirst();

    final webScreen = WebScreen(
      logo: widget.logo,
      url: widget.screens[index].endpoint,
      pageTitle: widget.screens[index].pageTitle,
      hasPageTitle: false,
      onLoadFinished: () {
        _isQueueProcessing = false;
        _processQueue();
      },
      buttons: widget.buttons,
      action: widget.action,
    );
    _screens[index] = webScreen;
    setState(() {});
  }

  Widget _buildScreen(int index) {
    return _screens[index] ?? const Center(child: Text('Screen not found'));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(
            widget.screens.length, (index) => _buildScreen(index)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromRGBO(212, 2, 67, 1),
        items: List.generate(widget.screens.length, (index) {
          return BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Image.asset(
              widget.screens[index].icon,
              width: iconSize,
              height: iconSize,
            ),
            activeIcon: Image.asset(
              widget.screens[index].hoveredIcon,
              width: iconSize,
              height: iconSize,
            ),
            label: widget.screens[index].tabTitle,
          );
        }),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
