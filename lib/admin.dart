import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_samples/samples/ui/rive_app/on_boarding/signin_view.dart';
import 'package:flutter_samples/trans.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(AdminPanelApp());
}

class AdminPanelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontSize: 18.0),
          bodyMedium: TextStyle(fontSize: 16.0),
        ),
      ),
      home: AdminPanelHome(),
    );
  }
}

class AdminPanelHome extends StatefulWidget {
  @override
  _AdminPanelHomeState createState() => _AdminPanelHomeState();
}

class _AdminPanelHomeState extends State<AdminPanelHome> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    UserManagementScreen(),
    ContentManagementScreen(),
    BillingSubscriptionManagementScreen(),
    AnalyticsReportingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Panel'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Admin Panel',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () {
                _onItemTapped(0);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.supervised_user_circle),
              title: Text('User Management'),
              onTap: () {
                _onItemTapped(1);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.analytics),
              title: Text('Analytics & Reporting'),
              onTap: () {
                _onItemTapped(4);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 16.0,
          children: <Widget>[
            DashboardCard(
              title: 'User Management',
              subtitle: 'Manage users',
              color: Colors.blue,
              icon: Icons.supervised_user_circle,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => UserManagementScreen()));
              },
            ),
            DashboardCard(
              title: 'Analytics & Reporting',
              subtitle: 'View analytics',
              color: Colors.purple,
              icon: Icons.analytics,
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => AnalyticsReportingScreen()));
              },
            ),
            DashboardCard(
              title: 'Log Out',
              subtitle: 'Click to log out',
              color: Colors.red,
              icon: Icons.exit_to_app,
              onTap: () async {
                try {
                  await _logout(context);
                } catch (e) {
                  // Handle error if logout fails
                  print("Error logging out: $e");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _logout(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => SignInView()), // Adjust this according to your actual SignInView widget
  );
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  DashboardCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 40, color: Colors.white),
              SizedBox(height: 16.0),
              Text(
                title,
                style: TextStyle(color: Colors.white, fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.0),
              Text(
                subtitle,
                style: TextStyle(color: Colors.white70, fontSize: 14.0),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContentManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Content Management'),
      ),
      body: Center(
        child: Text(
          'Content Management',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class BillingSubscriptionManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Billing & Subscription Management'),
      ),
      body: Center(
        child: Text(
          'Billing & Subscription Management',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

class AnalyticsReportingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Analytics & Reporting'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Quality'),
              Tab(text: 'Usage Stats'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TranslationQualityGraph(),
            UsageStatisticsGraph(),
          ],
        ),
      ),
    );
  }
}

class TranslationQualityGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('translations').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var translations = snapshot.data!.docs;
        Map<String, Map<int, int>> directionTimestampCounts = {};

        for (var doc in translations) {
          var timestamp = (doc['timestamp'] as Timestamp).toDate();
          var dayTimestamp = DateTime(timestamp.year, timestamp.month, timestamp.day).millisecondsSinceEpoch ~/ 1000;
          var direction = doc['direction'] as String;

          if (!directionTimestampCounts.containsKey(direction)) {
            directionTimestampCounts[direction] = {};
          }
          if (!directionTimestampCounts[direction]!.containsKey(dayTimestamp)) {
            directionTimestampCounts[direction]![dayTimestamp] = 0;
          }
          directionTimestampCounts[direction]![dayTimestamp] = directionTimestampCounts[direction]![dayTimestamp]! + 1;
        }

        // Create a list of dates sorted in ascending order
        List<int> allDates = directionTimestampCounts.values.expand((e) => e.keys).toSet().toList()..sort();

        List<BarChartGroupData> barGroups = [];
        int index = 0;

        // Iterate through each date
        for (var date in allDates) {
          List<BarChartRodData> barRods = [];
          int colorIndex = 0;

          // Iterate through each direction for this date
          directionTimestampCounts.forEach((direction, timestamps) {
            int count = timestamps[date] ?? 0;
            barRods.add(
              BarChartRodData(
                toY: count.toDouble(),
                color: Color.lerp(Colors.blue, Colors.red, colorIndex / directionTimestampCounts.length),
                width: 10,
                borderRadius: BorderRadius.zero,
              ),
            );
            colorIndex++;
          });

          barGroups.add(BarChartGroupData(x: index, barRods: barRods));
          index++;
        }
return Padding(
  padding: const EdgeInsets.all(16.0),
  child: BarChart(
    BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: 10,
      barGroups: barGroups,
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1, // Adjust the interval as needed
            getTitlesWidget: (value, meta) {
              return Text(value.toInt().toString());
            },
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              int dateIndex = value.toInt();
              if (dateIndex < 0 || dateIndex >= allDates.length) return const Text('');
              var date = DateTime.fromMillisecondsSinceEpoch(allDates[dateIndex] * 1000);
              return Text(DateFormat('MM/dd').format(date));
            },
          ),
        ),
      ),
    ),
  ),
);

      },
    );
  }
}

class UsageStatisticsGraph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('usage_stats').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var usageStats = snapshot.data!.docs;
        List<FlSpot> usageSpots = usageStats.map((doc) {
          var timestamp = (doc['timestamp'] as Timestamp).toDate().millisecondsSinceEpoch.toDouble();
          var usage = doc['usage'] as double;
          return FlSpot(timestamp, usage);
        }).toList();

        
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: usageSpots,
              isCurved: true,
              color: Colors.blue,
              barWidth: 2,
              dotData: FlDotData(show: false),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  var date = DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000);
                  return Text(DateFormat('MM/dd').format(date));
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(value.toInt().toString());
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey),
          ),
        ),
      ),
    );
  },
    );
  }
}