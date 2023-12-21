import 'package:flutter/material.dart';
import 'package:news_app/item.dart';

class FavoritesScreen extends StatefulWidget {
  final List<Item> favorites;
  final Function(Item) removeFavorite;
  final int selectedIndex;

  const FavoritesScreen(
      {Key? key,
      required this.favorites,
      required this.removeFavorite,
      required this.selectedIndex})
      : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  void removeFavorite(Item item) {
    setState(() {
      widget.favorites.remove(item);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Removed from favorites'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          itemCount: widget.favorites.length,
          itemBuilder: (context, index) {
            final article = widget.favorites[index];
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
                  icon: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 35,
                  ),
                  onPressed: () {
                    removeFavorite(article);
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
                  if (_selectedIndex != 0) {
                    Navigator.popUntil(
                      context,
                      ModalRoute.withName(Navigator.defaultRouteName),
                    );
                  }
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
                  if (_selectedIndex != 1) {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  }
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
