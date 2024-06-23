import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth for user authentication
import 'package:flutter_samples/samples/ui/rive_app/home.dart';
import 'package:flutter_samples/samples/ui/rive_app/theme.dart';

class TranslationHistory {
  final String sourceText;
  final String translatedText;
  final String direction;
  final DateTime timestamp;

  TranslationHistory({
    required this.sourceText,
    required this.translatedText,
    required this.direction,
    required this.timestamp,
  });

  String get sourceLanguage {
    return direction.startsWith('en') ? 'English' : 'Chichewa';
  }

  String get targetLanguage {
    return direction.endsWith('ny') ? 'Chichewa' : 'English';
  }
}

class TranslationHistoryPage extends StatefulWidget {
  @override
  _TranslationHistoryPageState createState() => _TranslationHistoryPageState();
}

class _TranslationHistoryPageState extends State<TranslationHistoryPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Authentication instance
  List<TranslationHistory> history = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchTranslationHistory();
  }

  Future<void> _fetchTranslationHistory() async {
    try {
      User? user = _auth.currentUser; // Get the current user
      if (user != null) {
        final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('translations')
            .where('userId', isEqualTo: user.uid) // Filter by user ID
            .get();
        setState(() {
          history = querySnapshot.docs.map((doc) {
            return TranslationHistory(
              sourceText: doc['original_text'],
              translatedText: doc['translated_text'],
              direction: doc['direction'],
              timestamp: (doc['timestamp'] as Timestamp).toDate(),
            );
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User not logged in.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load translation history: $e';
      });
      print('Error fetching translation history: $e');
    }
  }

  Future<void> _deleteTranslationHistory(TranslationHistory entry) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('translations')
            .where('userId', isEqualTo: user.uid)
            .where('timestamp', isEqualTo: Timestamp.fromDate(entry.timestamp))
            .where('direction', isEqualTo: entry.direction)
            .where('original_text', isEqualTo: entry.sourceText)
            .get()
            .then((querySnapshot) {
          for (QueryDocumentSnapshot doc in querySnapshot.docs) {
            doc.reference.delete();
          }
        });
        setState(() {
          history.remove(entry);
        });
      }
    } catch (e) {
      print('Error deleting translation history: $e');
      setState(() {
        _errorMessage = 'Failed to delete translation history: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.0),
            color: RiveAppTheme.background,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Translation History',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6E6AE8),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const RiveAppHome()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  child: Text('Home'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : history.isEmpty
                        ? Center(child: Text('No history available'))
                        : ListView.builder(
                            itemCount: history.length,
                            itemBuilder: (context, index) {
                              final entry = history[index];
                              return HistoryCard(
                                entry: entry,
                                onDelete: () => _deleteTranslationHistory(entry),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final TranslationHistory entry;
  final VoidCallback onDelete;

  HistoryCard({required this.entry, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${entry.sourceLanguage} to ${entry.targetLanguage}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Original: ${entry.sourceText}',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
            Text(
              'Translated: ${entry.translatedText}',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              'Timestamp: ${entry.timestamp}',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.black54,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
