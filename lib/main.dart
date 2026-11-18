import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'downloads_page.dart';
import 'downloads_service.dart';
import 'home_page.dart';
import 'history_page.dart';
import 'music_page.dart';
import 'jiosaavn_service.dart';
import 'search_page.dart';
import 'settings_page.dart';
import 'store.dart';
import 'navigation_key.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await app.init().timeout(const Duration(seconds: 8)); } catch (_) {}
  try { await DownloadService.instance.loadSettings().timeout(const Duration(seconds: 5)); } catch (_) {}
  runApp(const MovieFoxApp());
}

ThemeData _lightTheme() {
  const bg = Colors.white;
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF3157C8), brightness: Brightness.light).copyWith(surface: bg);
  return ThemeData(
    useMaterial3: true, brightness: Brightness.light, colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    appBarTheme: const AppBarTheme(backgroundColor: bg, foregroundColor: Colors.black, surfaceTintColor: Colors.transparent, scrolledUnderElevation: 0, elevation: 0),
    cardTheme: const CardThemeData(color: Colors.white, surfaceTintColor: Colors.transparent),
    dialogTheme: const DialogThemeData(backgroundColor: Colors.white, surfaceTintColor: Colors.transparent),
    inputDecorationTheme: const InputDecorationTheme(filled: true, fillColor: Color(0xFFF3F4F6), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(4)), borderSide: BorderSide.none)),
  );
}

ThemeData _darkTheme() {
  const bg = Color(0xFF0D111B);
  const surface = Color(0xFF171D2A);
  final scheme = ColorScheme.fromSeed(seedColor: const Color(0xFF38BDF8), brightness: Brightness.dark)
      .copyWith(surface: bg, surfaceContainer: surface, surfaceContainerHighest: const Color(0xFF222B3B));
  return ThemeData(
    useMaterial3: true, brightness: Brightness.dark, colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    appBarTheme: const AppBarTheme(backgroundColor: bg, foregroundColor: Colors.white, surfaceTintColor: Colors.transparent, scrolledUnderElevation: 0, elevation: 0),
    cardTheme: const CardThemeData(color: surface, surfaceTintColor: Colors.transparent),
    dialogTheme: const DialogThemeData(backgroundColor: surface, surfaceTintColor: Colors.transparent),
    bottomSheetTheme: const BottomSheetThemeData(backgroundColor: surface, surfaceTintColor: Colors.transparent),
    inputDecorationTheme: const InputDecorationTheme(filled: true, fillColor: Color(0xFF222B3B), border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(4)), borderSide: BorderSide.none)),
    dividerColor: const Color(0xFF30394A),
  );
}

class MovieFoxApp extends StatelessWidget {
  const MovieFoxApp({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) => MaterialApp(
      title: 'MovieFox',
      navigatorKey: movieFoxNavigatorKey,
      debugShowCheckedModeBanner: false,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: app.theme,
      home: const MovieFoxShell(),
      builder: (context, child) => Stack(
        children: [
          Positioned.fill(child: child ?? const SizedBox.shrink()),
          ValueListenableBuilder<bool>(
            valueListenable: JioSaavnPlayer.instance.miniPlayerVisible,
            builder: (context, visible, _) => visible
                ? const Positioned(left: 0, right: 0, bottom: 0, child: Material(elevation: 18, child: MusicMiniPlayer()))
                : const SizedBox.shrink(),
          ),
        ],
      ),
    ),
  );
}

class MovieFoxShell extends StatefulWidget {
  const MovieFoxShell({super.key});
  @override
  State<MovieFoxShell> createState() => _MovieFoxShellState();
}

class _MovieFoxShellState extends State<MovieFoxShell> {
  int _page = 0;
  final List<int> _pageHistory = [];
  final _searchKey = GlobalKey<SearchPageState>();
  late final List<Widget> _pages = [
    const HomePage(), SearchPage(key: _searchKey), const DownloadsPage(),
    const HistoryPage(), const SettingsPage(), const MusicPage(),
  ];

  @override
  void initState() {
    super.initState();
    DownloadService.instance.onOpenDownloads = () => _goToPage(2);
  }

  void _goToPage(int next) {
    if (_page == next) return;
    if (next == 1) { _searchKey.currentState?.setSaavnMode(_page == 5); _searchKey.currentState?.resetSearch(); }
    setState(() {
      _pageHistory.add(_page);
      _page = next;
    });
  }

  Future<bool> _handleBack() async {
    if ((_page == 0 || _page == 5) && JioSaavnPlayer.instance.miniPlayerVisible.value) {
      try {
        await const MethodChannel('app.moviefox/task').invokeMethod<bool>('moveToBackground');
        return false;
      } catch (_) {}
    }
    if (_page == 5) return true;
    if (_page == 1) _searchKey.currentState?.resetSearch();
    if (_pageHistory.isNotEmpty) {
      setState(() => _page = _pageHistory.removeLast());
      return false;
    }
    if (_page != 0) {
      setState(() => _page = 0);
      return false;
    }
    return true;
  }

  Widget _providerIcon(String kind) {
    const movieBox = 'https://h5-static.aoneroom.com/ssrStatic/mbOfficial/public/_nuxt/image-1.apJjVir2.svg';
    const storyTv = 'https://play-lh.googleusercontent.com/A5ISR8CT9j9gTFpqTSJBXwvxWKk1WmJlJ8-WRl7dYUzI0U3srRPCF0t6_sX6Jvfl1Su1_-p0R5k9wd4fur79VQ';
    const freeReels = 'https://cdn.aptoide.com/imgs/f/1/c/f1c5e0e44aeeb449090037d9088cb0d2_icon.png';
    const jioTvPlus = 'https://play-lh.googleusercontent.com/YzCDPantLFE3sw1tmkOcxSKORt_uACVBpfSprVjyx0FR4arX3O3EUbrSJ0t_7MukyOQMylBxu1W8kD2doyDh=w240-h480';
    const jioSaavn = 'https://play-lh.googleusercontent.com/tJwz_QkxqQN1yFfb8ItXc2hpfzzSfxA-sdqaPGv51ldOFDXCMSmG0coD0uCzKo5y28rJLzyiIY7tmCHiuOOtdKM';
    if (kind == 'moviebox') return SvgPicture.network(movieBox, width: 27, height: 27, fit: BoxFit.contain, placeholderBuilder: (_) => const Icon(Icons.movie_creation_outlined, size: 24));
    final url = kind == 'storytv' ? storyTv : kind == 'freereels' ? freeReels : kind == 'jiotvplus' ? jioTvPlus : jioSaavn;
    return Image.network(url, width: 27, height: 27, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Icon(kind == 'storytv' ? Icons.smart_display_outlined : kind == 'freereels' ? Icons.video_library_outlined : kind == 'jiotvplus' ? Icons.live_tv_outlined : Icons.music_note_rounded, size: 24));
  }

  void _chooseProvider(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black26,
      elevation: 0,
      showDragHandle: false,
      isScrollControlled: false,
      builder: (sheetContext) => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.20),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              border: Border.all(color: Colors.white.withOpacity(.32), width: 1),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  16, 12, 16,
                  18 + (JioSaavnPlayer.instance.miniPlayerVisible.value ? 82 : 0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.65), borderRadius: BorderRadius.circular(8),
                    ))),
                    const Padding(
                      padding: EdgeInsets.fromLTRB(2, 14, 2, 14),
                      child: Text('Choose provider', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.black87)),
                    ),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                      children: [
                        for (final provider in app.enabled)
                          _ProviderChoice(
                            name: provider.name,
                            icon: _providerIcon(provider.kind),
                            selected: _page != 5 && app.active == provider.id,
                            onTap: () {
                              app.setActive(provider.id);
                              Navigator.pop(sheetContext);
                              if (_page != 0) setState(() { _pageHistory.add(_page); _page = 0; });
                            },
                          ),
                        _ProviderChoice(
                          name: 'JioSaavn',
                          icon: _providerIcon('jiosaavn'),
                          selected: _page == 5,
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _goToPage(5);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: app,
    builder: (context, _) => WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        appBar: (_page == 0 || _page == 5) ? AppBar(
          titleSpacing: 16,
          title: InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => _chooseProvider(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
              child: Text(_page == 5 ? 'JioSaavn' : app.scopeName, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: -.4)),
            ),
          ),
          actions: [
            IconButton(tooltip: 'Search', onPressed: () => _goToPage(1), icon: const Icon(Icons.search)),
            IconButton(tooltip: 'Downloads', onPressed: () => _goToPage(2), icon: const Icon(Icons.download_outlined)),
            IconButton(tooltip: 'Watch history', onPressed: () => _goToPage(3), icon: const Icon(Icons.history_rounded)),
            IconButton(tooltip: 'Settings', onPressed: () => _goToPage(4), icon: const Icon(Icons.settings_outlined)),
            const SizedBox(width: 4),
          ],
        ) : null,
        body: IndexedStack(index: _page, children: _pages),

      ),
    ),
  );
}

class _ProviderChoice extends StatelessWidget {
  const _ProviderChoice({required this.name, required this.icon, required this.selected, required this.onTap});
  final String name;
  final Widget icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Material(
        color: (selected ? const Color(0xFFEAF0FF) : Colors.white).withOpacity(.20),
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(.42), width: 1),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 42, height: 42, child: Center(child: icon)),
                const SizedBox(height: 10),
                Text(name, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w700, color: selected ? const Color(0xFF2449B8) : Colors.black87)),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
