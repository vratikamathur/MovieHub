import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

void main() => runApp(const MyApp());

const _bg = Color(0xFF0A0A0F);
const _surface = Color(0xFF13131A);
const _accent = Color(0xFFE50914);
const _card = Color(0xFF1C1C26);

const _movies = [
  {"title": "Inception", "genre": "Sci-Fi", "year": "2010", "rating": "8.8", "image": "https://image.tmdb.org/t/p/w500/8IB2e4r4oVhHnANbnm7O3Tj6tF8.jpg"},
  {"title": "Interstellar", "genre": "Sci-Fi", "year": "2014", "rating": "8.6", "image": "https://image.tmdb.org/t/p/w500/rAiYTfKGqDCRIIqo664sY9XZIvQ.jpg"},
  {"title": "Joker", "genre": "Drama", "year": "2019", "rating": "8.4", "image": "https://image.tmdb.org/t/p/w500/udDclJoHjfjb8Ekgsd4FDteOkCU.jpg"},
  {"title": "Avengers", "genre": "Action", "year": "2019", "rating": "8.4", "image": "https://image.tmdb.org/t/p/w500/RYMX2wcKCBAr24UyPD7xwmjaTn.jpg"},
  {"title": "The Dark Knight", "genre": "Action", "year": "2008", "rating": "9.0", "image": "https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg"},
  {"title": "Parasite", "genre": "Thriller", "year": "2019", "rating": "8.5", "image": "https://image.tmdb.org/t/p/w500/7IiTTgloJzvGI1TAYymCfbfl3vT.jpg"},
];

const _genres = ["All", "Action", "Sci-Fi", "Drama", "Thriller"];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MovieHub',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: _bg,
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      ),
      home: const RootScreen(),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int _tab = 0;
  final List<Map<String, String>> _favorites = [];

  void _toggleFav(Map<String, String> movie) => setState(() {
    _favorites.any((f) => f["title"] == movie["title"])
        ? _favorites.removeWhere((f) => f["title"] == movie["title"])
        : _favorites.add(movie);
  });

  bool _isFav(Map<String, String> movie) =>
      _favorites.any((f) => f["title"] == movie["title"]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: [
        HomeScreen(onFavToggle: _toggleFav, isFav: _isFav),
        FavoritesScreen(favorites: _favorites, onFavToggle: _toggleFav),
      ][_tab],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: _surface,
          border: Border(top: BorderSide(color: Color(0xFF2A2A35))),
        ),
        child: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: _accent,
          unselectedItemColor: Colors.white38,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: "Favorites"),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final void Function(Map<String, String>) onFavToggle;
  final bool Function(Map<String, String>) isFav;
  const HomeScreen({super.key, required this.onFavToggle, required this.isFav});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String _query = "";
  String _selectedGenre = "All";
  final _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;
  late final AnimationController _titleAnim;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;

  @override
  void initState() {
    super.initState();
    _titleAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    final curved = CurvedAnimation(parent: _titleAnim, curve: Curves.easeOut);
    _titleFade = curved;
    _titleSlide = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(curved);
    _titleAnim.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleAnim.dispose();
    super.dispose();
  }

  List<Map<String, String>> get _filtered => _movies
      .cast<Map<String, String>>()
      .where((m) =>
          (_selectedGenre == "All" || m["genre"] == _selectedGenre) &&
          m["title"]!.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildHeroBanner()),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildGenreChips()),
          SliverToBoxAdapter(
            child: _HorizontalMovieList(
              title: "Trending Now",
              movies: _filtered,
              isFav: widget.isFav,
              onFavToggle: widget.onFavToggle,
            ),
          ),
          SliverToBoxAdapter(
            child: _HorizontalMovieList(
              title: "Top Rated",
              movies: _movies.cast<Map<String, String>>().toList()
                ..sort((a, b) => b["rating"]!.compareTo(a["rating"]!)),
              isFav: widget.isFav,
              onFavToggle: widget.onFavToggle,
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _titleFade,
                child: SlideTransition(
                  position: _titleSlide,
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: "Movie",
                        style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -1, color: Colors.white),
                      ),
                      TextSpan(
                        text: "Hub",
                        style: GoogleFonts.inter(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -1, color: _accent),
                      ),
                    ]),
                  ),
                ),
              ),
              FadeTransition(
                opacity: _titleFade,
                child: Text("What are you watching tonight?",
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white38)),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accent.withValues(alpha: 0.15),
              border: Border.all(color: _accent.withValues(alpha: 0.4)),
            ),
            child: const Icon(Icons.person_rounded, color: _accent, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner() {
    final movies = _movies.cast<Map<String, String>>();
    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: movies.length,
            itemBuilder: (_, i) {
              final movie = movies[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: GestureDetector(
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => DetailScreen(movie: movie))),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: movie["image"]!,
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.high,
                          placeholder: (_, _) => Container(color: _card),
                          errorWidget: (_, _, e) => Container(color: _card),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withValues(alpha: 0.85),
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.3),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              stops: const [0.0, 0.5, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12, left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(6)),
                            child: Text("FEATURED",
                                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
                          ),
                        ),
                        Positioned(
                          bottom: 16, left: 16, right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(movie["title"]!,
                                  style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 4),
                              Row(children: [
                                const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text("${movie["rating"]}  •  ${movie["year"]}  •  ${movie["genre"]}",
                                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white70)),
                              ]),
                              const SizedBox(height: 10),
                              Row(children: [
                                _bannerBtn(Icons.play_arrow_rounded, "Watch Now", filled: true),
                                const SizedBox(width: 8),
                                _bannerBtn(Icons.add_rounded, "Watchlist", filled: false),
                              ]),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            movies.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == i ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == i ? _accent : Colors.white24,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _bannerBtn(IconData icon, String label, {required bool filled}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: filled ? Colors.white : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: filled ? null : Border.all(color: Colors.white30),
      ),
      child: Row(children: [
        Icon(icon, color: filled ? Colors.black : Colors.white, size: 18),
        const SizedBox(width: 5),
        Text(label,
            style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600,
                color: filled ? Colors.black : Colors.white)),
      ]),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A35)),
        ),
        child: TextField(
          onChanged: (v) => setState(() => _query = v),
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search_rounded, color: Colors.white38, size: 20),
            hintText: "Search movies...",
            hintStyle: GoogleFonts.inter(color: Colors.white38, fontSize: 14),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildGenreChips() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        scrollDirection: Axis.horizontal,
        itemCount: _genres.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final selected = _genres[i] == _selectedGenre;
          return GestureDetector(
            onTap: () => setState(() => _selectedGenre = _genres[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? _accent : _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: selected ? _accent : const Color(0xFF2A2A35)),
              ),
              child: Text(_genres[i],
                  style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                      color: selected ? Colors.white : Colors.white54)),
            ),
          );
        },
      ),
    );
  }
}

class _HorizontalMovieList extends StatelessWidget {
  final String title;
  final List<Map<String, String>> movies;
  final bool Function(Map<String, String>) isFav;
  final void Function(Map<String, String>) onFavToggle;

  const _HorizontalMovieList({
    required this.title,
    required this.movies,
    required this.isFav,
    required this.onFavToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text(title,
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => SizedBox(
              width: 120,
              child: _MovieCard(
                movie: movies[i],
                isFav: isFav(movies[i]),
                onFavToggle: () => onFavToggle(movies[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MovieCard extends StatelessWidget {
  final Map<String, String> movie;
  final bool isFav;
  final VoidCallback onFavToggle;
  const _MovieCard({required this.movie, required this.isFav, required this.onFavToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => DetailScreen(movie: movie))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Hero(
              tag: movie["title"]!,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: movie["image"]!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: _card),
                      errorWidget: (_, _, e) => Container(color: _card,
                          child: const Icon(Icons.broken_image_rounded, color: Colors.white24)),
                    ),
                    Positioned(
                      top: 0, left: 0, right: 0,
                      child: Container(
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black.withValues(alpha: 0.5), Colors.transparent],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8, right: 8,
                      child: GestureDetector(
                        onTap: onFavToggle,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            key: ValueKey(isFav),
                            color: isFav ? _accent : Colors.white70,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                          const SizedBox(width: 3),
                          Text(movie["rating"]!,
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(movie["title"]!, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text("${movie["genre"]}  •  ${movie["year"]}",
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white38)),
        ],
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  final List<Map<String, String>> favorites;
  final void Function(Map<String, String>) onFavToggle;
  const FavoritesScreen({super.key, required this.favorites, required this.onFavToggle});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: favorites.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.favorite_border_rounded, size: 64, color: Colors.white12),
                  const SizedBox(height: 16),
                  Text("No favorites yet",
                      style: GoogleFonts.inter(fontSize: 16, color: Colors.white38)),
                  const SizedBox(height: 6),
                  Text("Tap ♥ on any movie to save it here",
                      style: GoogleFonts.inter(fontSize: 13, color: Colors.white24)),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text("Favorites",
                      style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                ),
                _HorizontalMovieList(
                  title: "",
                  movies: favorites,
                  isFav: (_) => true,
                  onFavToggle: onFavToggle,
                ),
              ],
            ),
    );
  }
}

class DetailScreen extends StatelessWidget {
  final Map<String, String> movie;
  const DetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 380,
            pinned: true,
            backgroundColor: _bg,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: movie["title"]!,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: movie["image"]!,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Container(color: _card),
                      errorWidget: (_, _, e) => Container(color: _card),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_bg, Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          stops: const [0.0, 0.6],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(movie["title"]!,
                            style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                        ),
                        child: Row(children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(movie["rating"]!,
                              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.amber)),
                        ]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    _InfoChip(movie["genre"]!),
                    const SizedBox(width: 8),
                    _InfoChip(movie["year"]!),
                    const SizedBox(width: 8),
                    const _InfoChip("HD"),
                  ]),
                  const SizedBox(height: 20),
                  Text("About", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text(
                    "An immersive cinematic experience that pushes the boundaries of storytelling. "
                    "Featuring stunning visuals, a gripping narrative, and unforgettable performances.",
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.white60, height: 1.6),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFE50914), Color(0xFFB20710)]),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: _accent.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0, 6))],
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.play_arrow_rounded, size: 22),
                      const SizedBox(width: 8),
                      Text("Watch Now", style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF2A2A35)),
                    ),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.play_circle_outline_rounded, size: 20, color: Colors.white70),
                      const SizedBox(width: 8),
                      Text("Watch Trailer",
                          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white70)),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A2A35)),
      ),
      child: Text(label,
          style: GoogleFonts.inter(fontSize: 12, color: Colors.white60, fontWeight: FontWeight.w500)),
    );
  }
}
