import 'package:flutter/material.dart';

import '../constant/my_colors.dart';

class CustomNavbar extends StatefulWidget {
  const CustomNavbar({super.key, required this.pages, required this.icons});

  final List<Widget> pages;
  final List<Icon> icons;

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
                tabs: getTabs(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
