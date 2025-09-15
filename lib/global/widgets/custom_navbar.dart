import 'package:flutter/material.dart';

import '../constant/app_constants.dart';
import '../constant/my_colors.dart';

class CustomNavbar extends StatefulWidget {
  const CustomNavbar({super.key, required this.pages, required this.tabs});

  final List<Widget> pages;
  final List<Tab> tabs;

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
    return widget.tabs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          // Sayfaların gösterildiği alan
          Expanded(child: TabBarView(controller: _tabController, physics: const NeverScrollableScrollPhysics(), children: widget.pages)),

          // Alttaki tab bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: AppConstants.cardShadow, // AppConstants'tan shadow
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: AppConstants.buttonHeight + AppConstants.paddingMedium * 2, // Sabit yükseklik
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorWeight: 1,
                  dividerColor: Colors.transparent,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: MyColors.grey_20,
                  labelStyle: const TextStyle(
                    fontSize: AppConstants.fontSizeSmall, // 12.0
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: AppConstants.fontSizeSmall, // 12.0
                    fontWeight: FontWeight.normal,
                    height: 1.2,
                  ),
                  tabs:
                      getTabs().map((tab) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.paddingSmall, // 4.0
                            vertical: AppConstants.paddingSmall, // 4.0
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (tab.icon != null)
                                SizedBox(
                                  height: AppConstants.iconSizeSmall, // 16.0
                                  child: tab.icon!,
                                ),
                              SizedBox(height: AppConstants.paddingMedium),
                              if (tab.text != null)
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: AppConstants.paddingExtraSmall), // 2.0
                                    child: Text(
                                      tab.text!,
                                      textAlign: TextAlign.center,
                                      maxLines: AppConstants.maxLinesMedium, // 2 satır
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: AppConstants.fontSizeExtraSmall, // 10.0 → 12.0 yaptık
                                        height: 1.1,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
