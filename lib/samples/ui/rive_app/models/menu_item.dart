import 'package:flutter/material.dart';
import 'package:flutter_samples/samples/ui/rive_app/fevorites.dart';
import 'package:flutter_samples/samples/ui/rive_app/home.dart';
import 'package:flutter_samples/samples/ui/rive_app/models/tab_item.dart';
import 'package:flutter_samples/samples/ui/rive_app/navigation/history.dart';

class MenuItemModel {
  MenuItemModel({
    this.id,
    this.title = "",
    required this.riveIcon,
    this.onMenuPress, // Add onMenuPress function here
  });

  UniqueKey? id = UniqueKey();
  String title;
  TabItem riveIcon;
  void Function(BuildContext context)? onMenuPress; // Define onMenuPress function here

  static List<MenuItemModel> menuItems = [
    MenuItemModel(
      title: "Home",
      riveIcon: TabItem(stateMachine: "HOME_interactivity", artboard: "HOME"),
      onMenuPress: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RiveAppHome()),
        );
      },
    ),
  
    MenuItemModel(
      title: "Favorites",
      riveIcon: TabItem(stateMachine: "STAR_Interactivity", artboard: "LIKE/STAR"),
      onMenuPress: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FavoritesPage()),
        );
      },
    ),
   
  ];

  static List<MenuItemModel> menuItems2 = [
    MenuItemModel(
      title: "History",
      riveIcon: TabItem(stateMachine: "TIMER_Interactivity", artboard: "TIMER"),
      onMenuPress: (context) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => TranslationHistoryPage()),
        );
      },
    ),
  ];

  static List<MenuItemModel> menuItems3 = [
    MenuItemModel(
      title: "Dark Mode",
      riveIcon: TabItem(stateMachine: "SETTINGS_Interactivity", artboard: "SETTINGS"),
    ),
  ];
}
