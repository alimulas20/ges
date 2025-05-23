import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constant/my_colors.dart';

class CustomNavbar extends StatefulWidget {
  const CustomNavbar({super.key, required this.pages, required this.icons, required this.title});

  final List<Widget> pages;
  final List<Icon> icons;
  final String title;

  @override
  CustomNavbarState createState() => CustomNavbarState();
}

class CustomNavbarState extends State<CustomNavbar> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.pages.length, vsync: this);

    // Dinamik rebuild için dinleyici ekliyoruz
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Tab> getTabs() {
    return widget.icons.map((icon) => Tab(icon: icon)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle(statusBarBrightness: Brightness.dark),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MyColors.primary),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          // Sayfaların gösterildiği alan
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: widget.pages, // Swipe ile geçişi engellemek için
            ),
          ),

          // Alttaki tab bar
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            margin: EdgeInsets.all(0),
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 1,
                unselectedLabelColor: MyColors.grey_20,
                labelColor: MyColors.primary,
                tabs: getTabs(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
