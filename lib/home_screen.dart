import 'package:flutter/material.dart';
import 'package:news_app/favorites_screen.dart';
import 'package:news_app/item.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:news_app/news_api_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Item> favorites = [];
  List<Item> articles = [];

  void toggleFavorite(Item item) {
    setState(() {
      if (favorites.contains(item)) {
        favorites.remove(item);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Removed from favorites'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        favorites.add(item);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added to favorites'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void removeFavorite(Item item) {
    setState(() {
      favorites.remove(item);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int lastCallTimestamp = prefs.getInt('lastCallTimestamp') ?? 0;
    int apiCallCount = prefs.getInt('apiCallCount') ?? 0;

    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int oneDayInMillis = 24 * 60 * 60 * 1000;
    if (currentTime - lastCallTimestamp > oneDayInMillis) {
      apiCallCount = 0;
      lastCallTimestamp = currentTime;
    }
    if (apiCallCount < 100) {
      DateTime currentDate = DateTime.now();
      String formattedDate =
          '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
      String url =
          'https://newsapi.org/v2/everything?q=tesla&from=2023-12-03&sortBy=$formattedDate&apiKey=$newsIndiaApiKey';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final jsonData = json.decode(response.body);
          final List<dynamic> articleList = jsonData['articles'];

          final limitedArticles = articleList.take(10).toList();

          setState(() {
            articles = limitedArticles
                .map(
                  (article) => Item(
                    article['title'],
                    article['content'],
                    article['publishedAt'],
                  ),
                )
                .toList();
          });
          apiCallCount++;
          lastCallTimestamp = currentTime;
          prefs.setInt('lastCallTimestamp', lastCallTimestamp);
          prefs.setInt('apiCallCount', apiCallCount);
        } else {
          throw Exception('Failed to load data: ${response.statusCode}');
        }
      } catch (e) {
        throw Exception('Error fetching data: $e');
      }
    } else {
      throw Exception('API call limit reached for today');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          itemCount: articles.length,
          itemBuilder: (context, index) {
            final article = articles[index];
            return Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 4.0,
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(8.0),
                leading: IconButton(
                  icon: Icon(
                    favorites.contains(article)
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: favorites.contains(article) ? Colors.red : null,
                    size: 35,
                  ),
                  onPressed: () {
                    toggleFavorite(article);
                  },
                ),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 2,
                    ),
                    Text(
                      article.content,
                      style: const TextStyle(fontSize: 15),
                      maxLines: 2,
                    ),
                    Row(
                      children: [
                        Text(
                          article.publishedAt,
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = 0;
                    Navigator.popUntil(context,
                        ModalRoute.withName(Navigator.defaultRouteName));
                  });
                },
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: _selectedIndex == 0 ? Colors.blue : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(5),
                      topRight: Radius.circular(5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.list,
                        color:
                            _selectedIndex == 0 ? Colors.white : Colors.black,
                        size: 50,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'News',
                        style: TextStyle(
                          color:
                              _selectedIndex == 0 ? Colors.white : Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = 1;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FavoritesScreen(
                          favorites: favorites,
                          removeFavorite: removeFavorite,
                          selectedIndex: _selectedIndex,
                        ),
                      ),
                    ).then((value) {
                      setState(() {
                        _selectedIndex = value ?? 0;
                      });
                    });
                  });
                },
                child: Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: _selectedIndex == 1 ? Colors.blue : Colors.white,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(5),
                      topLeft: Radius.circular(5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite,
                        color: _selectedIndex == 1 ? Colors.white : Colors.red,
                        size: 50,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Favs',
                        style: TextStyle(
                          color:
                              _selectedIndex == 1 ? Colors.white : Colors.black,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
