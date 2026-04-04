import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie UI',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

// ---------------- HOME SCREEN ----------------

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> allMovies = [
    {
      "title": "Inception",
      "image":
          "https://image.tmdb.org/t/p/w500/8IB2e4r4oVhHnANbnm7O3Tj6tF8.jpg"
    },
    {
      "title": "Interstellar",
      "image":
          "https://image.tmdb.org/t/p/w500/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg"
    },
    {
      "title": "Joker",
      "image":
          "https://image.tmdb.org/t/p/w500/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg"
    },
    {
      "title": "Avengers",
      "image":
          "https://image.tmdb.org/t/p/w500/RYMX2wcKCBAr24UyPD7xwmjaTn.jpg"
    },
  ];

  List<Map<String, String>> filteredMovies = [];
  List<Map> favorites = [];

  @override
  void initState() {
    super.initState();
    filteredMovies = allMovies;
  }

  void searchMovies(String query) {
    final results = allMovies.where((movie) {
      return movie["title"]!
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredMovies = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.grey.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "MovieHub",
                    style: TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  // 🔥 HERO BANNER
                  Container(
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: NetworkImage(
                          "https://image.tmdb.org/t/p/w500/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.7),
                            Colors.transparent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Text(
                              "Bodies",
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "⭐ 7.5  •  2023  •  18+",
                              style: TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.play_arrow,
                                          color: Colors.black),
                                      SizedBox(width: 5),
                                      Text(
                                        "Watch Now",
                                        style: TextStyle(
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.white54),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: const Text("Watchlist"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // 🔍 Search
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: searchMovies,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        icon:
                            Icon(Icons.search, color: Colors.white54),
                        hintText: "Search movies...",
                        hintStyle:
                            TextStyle(color: Colors.white54),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Movies",
                    style: TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  GridView.builder(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    itemCount: filteredMovies.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) {
                      final movie = filteredMovies[index];
                      final isFav = favorites.contains(movie);

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetailScreen(movie: movie),
                            ),
                          );
                        },
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Hero(
                                    tag: movie["image"]!,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(
                                                15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black54,
                                            blurRadius: 8,
                                            offset:
                                                const Offset(0, 4),
                                          )
                                        ],
                                        image: DecorationImage(
                                          image: NetworkImage(
                                              movie["image"]!),
                                          fit: BoxFit.cover,
                                          colorFilter:
                                              ColorFilter.mode(
                                            Colors.black
                                                .withValues(alpha: 0.2),
                                            BlendMode.darken,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          if (isFav) {
                                            favorites
                                                .remove(movie);
                                          } else {
                                            favorites
                                                .add(movie);
                                          }
                                        });
                                      },
                                      child: Icon(
                                        isFav
                                            ? Icons.favorite
                                            : Icons
                                                .favorite_border,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              movie["title"]!,
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: "Favorites"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

// ---------------- DETAIL SCREEN ----------------

class DetailScreen extends StatelessWidget {
  final Map movie;

  const DetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar:
          AppBar(backgroundColor: Colors.black, elevation: 0),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: movie["image"],
            child: Image.network(
              movie["image"],
              height: 300,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(movie["title"],
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("⭐ 8.5 / 10",
                    style: TextStyle(color: Colors.white70)),
                const SizedBox(height: 15),
                const Text(
                  "This is a sample movie description for UI demonstration.",
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 25),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text("Watch Now",
                        style: TextStyle(
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}