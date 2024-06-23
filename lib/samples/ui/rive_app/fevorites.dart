import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_samples/samples/ui/rive_app/navigation/history.dart';
import 'package:flutter_samples/samples/ui/rive_app/theme.dart';

class FavoritesPage extends StatefulWidget {
  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<TranslationHistory> favorites = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('favorites')
            .where('userId', isEqualTo: user.uid)
            .get();
        setState(() {
          favorites = querySnapshot.docs.map((doc) {
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
        _errorMessage = 'Failed to load favorites: $e';
      });
      print('Error fetching favorites: $e');
    }
  }

  Future<void> _deleteFavorite(TranslationHistory entry) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('favorites')
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
          favorites.remove(entry);
        });
      }
    } catch (e) {
      print('Error deleting favorite: $e');
      setState(() {
        _errorMessage = 'Failed to delete favorite: $e';
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
                  'Favorites',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6E6AE8),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: Colors.blue,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : favorites.isEmpty
                        ? Center(child: Text('No favorites available'))
                        : ListView.builder(
                            itemCount: favorites.length,
                            itemBuilder: (context, index) {
                              final entry = favorites[index];
                              return HistoryCard(
                                entry: entry,
                                onDelete: () => _deleteFavorite(entry),
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
