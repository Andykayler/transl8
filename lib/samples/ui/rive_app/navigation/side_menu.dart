import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_samples/samples/ui/rive_app/fevorites.dart';
import 'package:flutter_samples/samples/ui/rive_app/navigation/history.dart';
import 'package:rive/rive.dart';
import 'package:flutter_samples/samples/ui/rive_app/components/menu_row.dart';
import 'package:flutter_samples/samples/ui/rive_app/models/menu_item.dart';
import 'package:flutter_samples/samples/ui/rive_app/theme.dart';
import 'package:flutter_samples/samples/ui/rive_app/assets.dart' as app_assets;

class SideMenu extends StatefulWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  final List<MenuItemModel> _browseMenuIcons = MenuItemModel.menuItems;
  final List<MenuItemModel> _historyMenuIcons = MenuItemModel.menuItems2;
  final List<MenuItemModel> _themeMenuIcon = MenuItemModel.menuItems3;
  String _selectedMenu = MenuItemModel.menuItems[0].title;
  bool _isDarkMode = false;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _fetchUserEmail();
  }

  void _fetchUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _userEmail = user?.email ?? "Unknown User";
    });
  }

  void onThemeRiveIconInit(artboard) {
    final controller = StateMachineController.fromArtboard(
        artboard, _themeMenuIcon[0].riveIcon.stateMachine);
    artboard.addController(controller!);
    _themeMenuIcon[0].riveIcon.status =
        controller.findInput<bool>("active") as SMIBool;
  }

  void onMenuPress(MenuItemModel menu) {
    setState(() {
      _selectedMenu = menu.title;
    });

    if (menu.title == "History") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => TranslationHistoryPage()),
      );
    } else if (menu.title == "Favorites") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => FavoritesPage()),
      );
    }
  }

  void onThemeToggle(value) {
    setState(() {
      _isDarkMode = value;
    });
    _themeMenuIcon[0].riveIcon.status!.change(value);
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding =
        MediaQuery.of(context).padding.top > 0 ? MediaQuery.of(context).padding.top : 0;
    final double bottomPadding = MediaQuery.of(context).padding.bottom > 60
        ? MediaQuery.of(context).padding.bottom - 60
        : 0;
    return Container(
      padding: EdgeInsets.only(top: topPadding, bottom: bottomPadding),
      constraints: const BoxConstraints(maxWidth: 288),
      decoration: BoxDecoration(
        color: RiveAppTheme.background2,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.person_outline),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userEmail ?? "Loading...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontFamily: "Inter",
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  MenuButtonSection(
                    title: "BROWSE",
                    selectedMenu: _selectedMenu,
                    menuIcons: _browseMenuIcons,
                    onMenuPress: onMenuPress,
                  ),
                  MenuButtonSection(
                    title: "HISTORY",
                    selectedMenu: _selectedMenu,
                    menuIcons: _historyMenuIcons,
                    onMenuPress: onMenuPress,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: Opacity(
                    opacity: 0.6,
                    child: RiveAnimation.asset(
                      app_assets.iconsRiv,
                      stateMachines: [_themeMenuIcon[0].riveIcon.stateMachine],
                      artboard: _themeMenuIcon[0].riveIcon.artboard,
                      onInit: onThemeRiveIconInit,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    _themeMenuIcon[0].title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                CupertinoSwitch(value: _isDarkMode, onChanged: onThemeToggle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MenuButtonSection extends StatelessWidget {
  const MenuButtonSection({
    Key? key,
    required this.title,
    required this.menuIcons,
    this.selectedMenu = "Home",
    this.onMenuPress,
  }) : super(key: key);

  final String title;
  final String selectedMenu;
  final List<MenuItemModel> menuIcons;
  final Function(MenuItemModel menu)? onMenuPress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 15,
              fontFamily: "Inter",
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(8),
          child: Column(
            children: [
              for (var menu in menuIcons) ...[
                Divider(
                  color: Colors.white.withOpacity(0.1),
                  thickness: 1,
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                ),
                MenuRow(
                  menu: menu,
                  selectedMenu: selectedMenu,
                  onMenuPress: () => onMenuPress!(menu),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
