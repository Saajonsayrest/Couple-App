import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants.dart';

enum ReaderVisualMode {
  matcha, // Cozy Matcha & Botanical Green
  bw, // B/W Peace of Mind (E-Ink Paperwhite)
  lowBlueLight, // Warm Candlelight / Low Blue Light
}

class BookReaderKeys {
  // 1-based; saved on every page turn so the reader reopens exactly there.
  static const String currentPage = 'reader_tgbt_page';
  static const String visualMode = 'reader_tgbt_mode';
  static const String warmthLevel = 'reader_tgbt_warmth';
  static const String dimmerLevel = 'reader_tgbt_dimmer';
  static const String zoomLevel = 'reader_tgbt_zoom';
  static const int totalPages = 224;
  static const double minZoom = 1.0;
  static const double maxZoom = 2.0;
  static const int defaultStartPage = 1; // First open starts at the cover
  static const int storyStartPage = 11; // "27 March 2023", chapter one

  // Pages are 2164x2800. Measured with OCR over all pages, the words always
  // sit within x 0.123-0.874, y 0.094-0.909; this box adds a little air.
  static const double pageAspectRatio = 2164 / 2800;
  static const Rect pageTextBounds = Rect.fromLTRB(0.09, 0.07, 0.91, 0.93);

  static String pageAssetPath(int pageNumber) {
    final clamped = pageNumber.clamp(1, totalPages);
    final padded = clamped.toString().padLeft(3, '0');
    return 'assets/books/too_good_to_be_true/page_$padded.webp';
  }
}

class _ModeOption {
  final ReaderVisualMode mode;
  final IconData icon;
  final String label;
  final String title;
  final String subtitle;

  const _ModeOption(
    this.mode,
    this.icon,
    this.label,
    this.title,
    this.subtitle,
  );
}

const _modeOptions = [
  _ModeOption(
    ReaderVisualMode.matcha,
    Icons.eco_rounded,
    'Matcha',
    'Cozy Matcha',
    'Botanical cream',
  ),
  _ModeOption(
    ReaderVisualMode.bw,
    Icons.contrast_rounded,
    'B/W',
    'B/W Peace',
    'Crisp E-Ink paper',
  ),
  _ModeOption(
    ReaderVisualMode.lowBlueLight,
    Icons.nightlight_round,
    'Warm',
    'Low Blue Light',
    'Warm bedtime',
  ),
];

class BookReaderScreen extends StatefulWidget {
  final bool isEmbeddedTab;

  /// Lets the tab shell hide its bottom navigation while reading fullscreen.
  final ValueChanged<bool>? onFullscreenChanged;

  const BookReaderScreen({
    super.key,
    this.isEmbeddedTab = false,
    this.onFullscreenChanged,
  });

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  // Heights of the floating bars, used to keep the page clear of them.
  static const double _topBarHeight = 44;
  static const double _bottomBarHeight = 148;
  static const double _barGap = 10;

  late Box _settingsBox;
  late ValueListenable<Box> _storageListenable;
  late PageController _pageController;
  final Map<int, TransformationController> _zoomControllers = {};
  // Size of the area a page is laid out in; rest-zoom positions depend on it.
  Size _pageViewport = Size.zero;

  int _currentPage = BookReaderKeys.defaultStartPage; // 1..224
  ReaderVisualMode _mode = ReaderVisualMode.matcha;
  double _warmth = 0.65; // 0.0..1.0 for Low Blue Light mode
  double _dimmer = 0.15; // 0.0..0.60 extra screen dimming
  double _zoom = 1.0; // text size from the slider, applies in fullscreen too

  bool _showControls = true;
  bool _isPageZoomed = false;
  double? _scrubPreviewPage;

  @override
  void initState() {
    super.initState();
    _settingsBox = Hive.box(AppConstants.settingsBox);
    _loadSavedState();
    _pageController = PageController(initialPage: _currentPage - 1);
    _storageListenable = _settingsBox.listenable(
      keys: const [
        BookReaderKeys.currentPage,
        BookReaderKeys.visualMode,
        BookReaderKeys.warmthLevel,
        BookReaderKeys.dimmerLevel,
        BookReaderKeys.zoomLevel,
      ],
    )..addListener(_syncFromStorage);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheNearbyPages(_currentPage);
    });
  }

  void _loadSavedState() {
    final savedPage = _settingsBox.get(
      BookReaderKeys.currentPage,
      defaultValue: BookReaderKeys.defaultStartPage,
    );
    if (savedPage is int) {
      _currentPage = savedPage.clamp(1, BookReaderKeys.totalPages);
    }

    final savedMode = _settingsBox.get(
      BookReaderKeys.visualMode,
      defaultValue: ReaderVisualMode.matcha.name,
    );
    if (savedMode is String) {
      _mode = ReaderVisualMode.values.firstWhere(
        (m) => m.name == savedMode,
        orElse: () => ReaderVisualMode.matcha,
      );
    }

    final savedWarmth = _settingsBox.get(
      BookReaderKeys.warmthLevel,
      defaultValue: 0.65,
    );
    if (savedWarmth is num) {
      _warmth = savedWarmth.toDouble().clamp(0.0, 1.0);
    }

    final savedDimmer = _settingsBox.get(
      BookReaderKeys.dimmerLevel,
      defaultValue: 0.15,
    );
    if (savedDimmer is num) {
      _dimmer = savedDimmer.toDouble().clamp(0.0, 0.60);
    }

    final savedZoom = _settingsBox.get(BookReaderKeys.zoomLevel);
    if (savedZoom is num) {
      _zoom = savedZoom.toDouble().clamp(
        BookReaderKeys.minZoom,
        BookReaderKeys.maxZoom,
      );
    }
  }

  // The Read tab stays alive in the IndexedStack while the home card pushes a
  // second reader on top, so mirror whatever the other instance saved.
  void _syncFromStorage() {
    if (!mounted) return;
    final shownPage = _currentPage;
    final shownZoom = _zoom;
    setState(_loadSavedState);
    if (_zoom != shownZoom) _resetAllZoom();
    if (_currentPage != shownPage && _pageController.hasClients) {
      _resetZoomForPage(shownPage - 1);
      _pageController.jumpToPage(_currentPage - 1);
    }
  }

  @override
  void dispose() {
    _storageListenable.removeListener(_syncFromStorage);
    if (!_showControls) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _pageController.dispose();
    for (final controller in _zoomControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Hiding the controls is fullscreen: system bars go too, and the tab shell
  /// is told so it can hide its navigation bar.
  void _setControlsVisible(bool visible) {
    if (visible == _showControls) return;
    setState(() => _showControls = visible);
    SystemChrome.setEnabledSystemUIMode(
      visible ? SystemUiMode.edgeToEdge : SystemUiMode.immersiveSticky,
    );
    widget.onFullscreenChanged?.call(!visible);
    // The page area changes size, so re-anchor the zoom once it is laid out.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _resetAllZoom();
    });
  }

  // Where a page rests at the chosen text size: scaled by _zoom with the
  // top-left of the text block pinned to the top-left of the page area, so a
  // zoomed page opens at its first line.
  Matrix4 _restMatrix() {
    final viewport = _pageViewport;
    if (_zoom <= 1.0 || viewport.isEmpty) return Matrix4.identity();
    final box = _textBoxSize(viewport);
    final left = (viewport.width - box.width) / 2 * _zoom;
    final top = (viewport.height - box.height) / 2 * _zoom;
    // Keep within what InteractiveViewer allows for a scaled child.
    final dx = (-left).clamp(viewport.width * (1 - _zoom), 0.0);
    final dy = (-top).clamp(viewport.height * (1 - _zoom), 0.0);
    return Matrix4.translationValues(dx, dy, 0)
      ..multiply(Matrix4.diagonal3Values(_zoom, _zoom, 1));
  }

  TransformationController _controllerForPage(int index) {
    return _zoomControllers.putIfAbsent(
      index,
      () => TransformationController(_restMatrix()),
    );
  }

  void _resetZoomForPage(int index) {
    _zoomControllers[index]?.value = _restMatrix();
    final zoomed = _zoom > 1.01;
    if (_isPageZoomed != zoomed) {
      setState(() => _isPageZoomed = zoomed);
    }
  }

  void _resetAllZoom() {
    final rest = _restMatrix();
    for (final controller in _zoomControllers.values) {
      controller.value = rest.clone();
    }
    final zoomed = _zoom > 1.01;
    if (_isPageZoomed != zoomed) {
      setState(() => _isPageZoomed = zoomed);
    }
  }

  void _setZoom(double zoom, {bool save = true}) {
    final clamped = (zoom * 10).round() / 10;
    setState(
      () =>
          _zoom = clamped.clamp(BookReaderKeys.minZoom, BookReaderKeys.maxZoom),
    );
    _resetAllZoom();
    if (save) _settingsBox.put(BookReaderKeys.zoomLevel, _zoom);
  }

  // Pages ship at 2164x2800 (~24 MB each once decoded). Decoding at 1.5x the
  // screen's physical width keeps zoomed text sharp while letting the
  // neighbouring pages fit in the image cache alongside the visible one.
  ImageProvider _pageImage(int pageNumber) {
    final physicalWidth =
        MediaQuery.sizeOf(context).width *
        MediaQuery.devicePixelRatioOf(context);
    return ResizeImage(
      AssetImage(BookReaderKeys.pageAssetPath(pageNumber)),
      width: (physicalWidth * 1.5).round(),
    );
  }

  void _precacheNearbyPages(int centerPage) {
    if (!mounted) return;
    for (int offset = -1; offset <= 2; offset++) {
      final target = centerPage + offset;
      if (target >= 1 && target <= BookReaderKeys.totalPages) {
        precacheImage(_pageImage(target), context);
      }
    }
  }

  void _onPageChanged(int index) {
    final newPage = index + 1;
    _resetZoomForPage(_currentPage - 1);
    setState(() {
      _currentPage = newPage;
      _scrubPreviewPage = null;
    });
    _settingsBox.put(BookReaderKeys.currentPage, newPage);
    _precacheNearbyPages(newPage);
  }

  void _jumpToPage(int pageNumber, {bool animate = false}) {
    final clamped = pageNumber.clamp(1, BookReaderKeys.totalPages);
    _resetZoomForPage(_currentPage - 1);
    if (!_pageController.hasClients) return;
    if (animate) {
      _pageController.animateToPage(
        clamped - 1,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    } else {
      _pageController.jumpToPage(clamped - 1);
    }
  }

  void _setVisualMode(ReaderVisualMode mode) {
    HapticFeedback.selectionClick();
    setState(() => _mode = mode);
    _settingsBox.put(BookReaderKeys.visualMode, mode.name);
  }

  // Taps on the outer edges turn pages (works zoomed and in fullscreen, where
  // swiping is busy panning); taps in the middle toggle the controls.
  void _handleTap(TapUpDetails details) {
    final width = MediaQuery.sizeOf(context).width;
    final x = details.globalPosition.dx;
    if (x < width * 0.22) {
      _jumpToPage(_currentPage - 1, animate: true);
    } else if (x > width * 0.78) {
      _jumpToPage(_currentPage + 1, animate: true);
    } else {
      _setControlsVisible(!_showControls);
    }
  }

  // Size of the trimmed text block for a page laid out in [area].
  Size _textBoxSize(Size area) {
    const text = BookReaderKeys.pageTextBounds;
    const aspect = BookReaderKeys.pageAspectRatio;
    final imageWidth = math.min(
      area.width / text.width,
      area.height * aspect / text.height,
    );
    return Size(imageWidth * text.width, imageWidth / aspect * text.height);
  }

  // ColorFilter matrices for each reading mode
  // dart format off
  ColorFilter _buildPageColorFilter() {
    switch (_mode) {
      case ReaderVisualMode.matcha:
        // Soft warm cream paper tint (reduces harsh digital white glare slightly)
        return const ColorFilter.matrix(<double>[
          0.985, 0.000, 0.000, 0, 0,
          0.000, 0.978, 0.000, 0, 0,
          0.000, 0.000, 0.945, 0, 0,
          0.000, 0.000, 0.000, 1, 0,
        ]);

      case ReaderVisualMode.bw:
        // Crisp E-Ink Paperwhite monochrome with boosted text contrast
        const double c = 1.12;
        const double b = -10.0;
        return const ColorFilter.matrix(<double>[
          0.299 * c, 0.587 * c, 0.114 * c, 0, b,
          0.299 * c, 0.587 * c, 0.114 * c, 0, b,
          0.299 * c, 0.587 * c, 0.114 * c, 0, b,
          0,         0,         0,         1, 0,
        ]);

      case ReaderVisualMode.lowBlueLight:
        // Warm amber candlelight filter scaled by _warmth (0.0..1.0)
        final double w = _warmth;
        final double rScale = 1.0 - (0.03 * w);
        final double gScale = 1.0 - (0.14 * w);
        final double bScale = 1.0 - (0.48 * w);
        return ColorFilter.matrix(<double>[
          rScale, 0.04 * w, 0.00,   0, 0,
          0.02 * w, gScale, 0.00,   0, 0,
          0.00,   0.00,     bScale, 0, 0,
          0,      0,        0,      1, 0,
        ]);
    }
  }

  // Turns a white page into ink on glass: every pixel takes the ink colour,
  // and its opacity follows how dark it was (white paper -> fully clear), so
  // the words sit straight on the cozy backdrop. The 1.2 gain keeps
  // anti-aliased letter edges crisp.
  ColorFilter _buildInkFilter() {
    final ink = _inkColor;
    const k = -1.2 / 3;
    return ColorFilter.matrix(<double>[
      0, 0, 0, 0, ink.r * 255,
      0, 0, 0, 0, ink.g * 255,
      0, 0, 0, 0, ink.b * 255,
      k, k, k, 0, 255 * 1.2,
    ]);
  }
  // dart format on

  Color get _inkColor {
    switch (_mode) {
      case ReaderVisualMode.matcha:
        return const Color(0xFF1F2B21);
      case ReaderVisualMode.bw:
        return const Color(0xFF151515);
      case ReaderVisualMode.lowBlueLight:
        // Cream text on the night backdrop, warmer as the slider goes up.
        return Color.lerp(
          const Color(0xFFEDE6D8),
          const Color(0xFFF3C27E),
          _warmth,
        )!;
    }
  }

  Color get _scaffoldBgColor {
    switch (_mode) {
      case ReaderVisualMode.matcha:
        return const Color(0xFFE5EFE0);
      case ReaderVisualMode.bw:
        return const Color(0xFFECECE9);
      case ReaderVisualMode.lowBlueLight:
        return const Color(0xFF161D17);
    }
  }

  Color get _chromeSurfaceColor {
    switch (_mode) {
      case ReaderVisualMode.matcha:
        return const Color(0xFFF9FCF7).withValues(alpha: 0.95);
      case ReaderVisualMode.bw:
        return const Color(0xFFF7F7F5).withValues(alpha: 0.96);
      case ReaderVisualMode.lowBlueLight:
        return const Color(0xFF232D24).withValues(alpha: 0.96);
    }
  }

  Color get _chromeTextColor {
    switch (_mode) {
      case ReaderVisualMode.matcha:
        return const Color(0xFF2C3E2E);
      case ReaderVisualMode.bw:
        return const Color(0xFF222222);
      case ReaderVisualMode.lowBlueLight:
        return const Color(0xFFE8DEC8);
    }
  }

  Color get _accentColor {
    switch (_mode) {
      case ReaderVisualMode.matcha:
        return const Color(0xFF5D8A66);
      case ReaderVisualMode.bw:
        return const Color(0xFF3A3A3A);
      case ReaderVisualMode.lowBlueLight:
        return const Color(0xFFD99B52);
    }
  }

  Color get _sheetColor => _mode == ReaderVisualMode.lowBlueLight
      ? const Color(0xFF212B22)
      : const Color(0xFFF7FAF5);

  BoxDecoration _chromeDecoration(BorderRadius radius) {
    return BoxDecoration(
      color: _chromeSurfaceColor,
      borderRadius: radius,
      border: Border.all(
        color: _accentColor.withValues(alpha: 0.22),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _mode == ReaderVisualMode.lowBlueLight;
    final viewPadding = MediaQuery.paddingOf(context);

    return PopScope(
      // Back leaves fullscreen first, then behaves normally.
      canPop: _showControls,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _setControlsVisible(true);
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: _scaffoldBgColor,
          body: Stack(
            children: [
              Positioned.fill(child: _buildBackdrop()),
              Positioned.fill(child: _buildPageView(viewPadding)),

              // Extra dimmer, only in Low Blue Light mode
              if (isDark && _dimmer > 0.01)
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      color: const Color(0xFF140C02).withValues(alpha: _dimmer),
                    ),
                  ),
                ),

              // Quiet page badge while fullscreen
              Positioned(
                right: 18,
                bottom: viewPadding.bottom + 10,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: _showControls ? 0.0 : 0.72,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _chromeSurfaceColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_currentPage / ${BookReaderKeys.totalPages}',
                        style: GoogleFonts.quicksand(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _chromeTextColor.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: viewPadding.top + 8,
                left: 14,
                right: 14,
                child: _buildAnimatedChrome(
                  hiddenOffset: const Offset(0, -1.6),
                  child: _buildTopBar(context),
                ),
              ),
              Positioned(
                bottom: viewPadding.bottom + 10,
                left: 14,
                right: 14,
                child: _buildAnimatedChrome(
                  hiddenOffset: const Offset(0, 1.4),
                  child: _buildBottomBar(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackdrop() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      decoration: BoxDecoration(
        gradient: _mode == ReaderVisualMode.matcha
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFEDF4E9),
                  Color(0xFFDCE9D5),
                  Color(0xFFE8F0E3),
                ],
              )
            : _mode == ReaderVisualMode.bw
            ? const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF0F0ED), Color(0xFFE5E5E1)],
              )
            : const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A231B), Color(0xFF111712)],
              ),
      ),
      child: RepaintBoundary(
        child: CustomPaint(
          // Words now sit directly on this, so motifs stay soft enough to
          // read through.
          painter: switch (_mode) {
            ReaderVisualMode.matcha => const _CozyBackdropPainter(
              leafColor: Color(0x1F6B9B74),
              motifColors: [
                Color(0x40E8919B),
                Color(0x336B9B74),
                Color(0x4DF2C46D),
              ],
            ),
            ReaderVisualMode.bw => const _CozyBackdropPainter(
              leafColor: Color(0x14000000),
              motifColors: [Color(0x1A000000), Color(0x12000000)],
            ),
            ReaderVisualMode.lowBlueLight => const _CozyBackdropPainter(
              motifColors: [Color(0x4DF2C46D), Color(0x2EE8DEC8)],
              night: true,
            ),
          },
        ),
      ),
    );
  }

  // One page at a time, in both normal view and fullscreen. Fullscreen only
  // gives the page the room the bars used to take.
  Widget _buildPageView(EdgeInsets viewPadding) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapUp: _handleTap,
      child: PageView.builder(
        controller: _pageController,
        // Zoomed pages pan instead; edge taps and the arrows turn pages.
        physics: _isPageZoomed
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        itemCount: BookReaderKeys.totalPages,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              left: 10,
              right: 10,
              top:
                  viewPadding.top +
                  (_showControls ? 8 + _topBarHeight + _barGap : 12),
              bottom:
                  viewPadding.bottom +
                  (_showControls ? 10 + _bottomBarHeight + _barGap : 12),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                _pageViewport = constraints.biggest;
                final zoomController = _controllerForPage(index);
                return InteractiveViewer(
                  transformationController: zoomController,
                  minScale: 1.0,
                  maxScale: 3.5,
                  panEnabled: _isPageZoomed,
                  onInteractionEnd: (_) {
                    final scale = zoomController.value.getMaxScaleOnAxis();
                    final zoomed = scale > 1.03;
                    if (zoomed != _isPageZoomed) {
                      setState(() => _isPageZoomed = zoomed);
                    }
                  },
                  child: _buildPage(index + 1),
                );
              },
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _pageDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(
            alpha: _mode == ReaderVisualMode.lowBlueLight ? 0.45 : 0.12,
          ),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _buildPageImage(int pageNum, {BoxFit fit = BoxFit.contain}) {
    return Image(
      image: _pageImage(pageNum),
      fit: fit,
      gaplessPlayback: true,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFFDFBF7),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: Text(
            'Page $pageNum could not be loaded.',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPage(int pageNum) {
    // The cover is full-bleed art: show it whole, like a book on the table.
    if (pageNum == 1) {
      return Center(
        child: Container(
          decoration: _pageDecoration(),
          clipBehavior: Clip.antiAlias,
          child: ColorFiltered(
            colorFilter: _buildPageColorFilter(),
            child: _buildPageImage(pageNum),
          ),
        ),
      );
    }

    // Every other page is white paper with wide blank margins. Trim them so
    // the words are as big as the screen allows, and print them as ink
    // straight onto the cozy backdrop.
    return LayoutBuilder(
      builder: (context, constraints) {
        const text = BookReaderKeys.pageTextBounds;
        const aspect = BookReaderKeys.pageAspectRatio;
        final imageWidth = math.min(
          constraints.maxWidth / text.width,
          constraints.maxHeight * aspect / text.height,
        );
        final imageHeight = imageWidth / aspect;

        return Center(
          child: SizedBox(
            width: imageWidth * text.width,
            height: imageHeight * text.height,
            child: ClipRect(
              child: OverflowBox(
                minWidth: imageWidth,
                maxWidth: imageWidth,
                minHeight: imageHeight,
                maxHeight: imageHeight,
                child: ColorFiltered(
                  colorFilter: _buildInkFilter(),
                  child: _buildPageImage(pageNum, fit: BoxFit.fill),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedChrome({
    required Offset hiddenOffset,
    required Widget child,
  }) {
    return IgnorePointer(
      ignoring: !_showControls,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        offset: _showControls ? Offset.zero : hiddenOffset,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _showControls ? 1.0 : 0.0,
          // The bars have fixed heights, so cap how far system font scaling
          // can grow their labels.
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final canGoBack = !widget.isEmbeddedTab && Navigator.of(context).canPop();

    return LayoutBuilder(
      builder: (context, constraints) {
        // Room left for the mode switcher after the round buttons.
        final switcherRoom = constraints.maxWidth - (canGoBack ? 52 : 0) - 104;
        final showModeLabels = switcherRoom >= 220;

        return SizedBox(
          height: _topBarHeight,
          child: Row(
            children: [
              if (canGoBack) ...[
                _buildRoundButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  tooltip: 'Back',
                  iconSize: 17,
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  // Last-resort guard: shrink rather than overflow.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: _buildModeSwitcher(showModeLabels),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _buildRoundButton(
                icon: Icons.tune_rounded,
                tooltip: 'Eye comfort',
                onTap: () => _showEyeComfortSheet(context),
              ),
              const SizedBox(width: 8),
              _buildRoundButton(
                icon: Icons.fullscreen_rounded,
                tooltip: 'Fullscreen',
                iconSize: 24,
                onTap: () => _setControlsVisible(false),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoundButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    double iconSize = 20,
  }) {
    return Tooltip(
      message: tooltip,
      child: DecoratedBox(
        decoration: _chromeDecoration(BorderRadius.circular(_topBarHeight / 2)),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox.square(
              dimension: _topBarHeight,
              child: Icon(icon, size: iconSize, color: _chromeTextColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSwitcher(bool showLabels) {
    return Container(
      height: _topBarHeight,
      padding: const EdgeInsets.all(4),
      decoration: _chromeDecoration(BorderRadius.circular(_topBarHeight / 2)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in _modeOptions)
            _buildModeChip(option, showLabel: showLabels),
        ],
      ),
    );
  }

  Widget _buildModeChip(_ModeOption option, {required bool showLabel}) {
    final selected = _mode == option.mode;
    final color = selected
        ? Colors.white
        : _chromeTextColor.withValues(alpha: 0.75);

    return Tooltip(
      message: option.title,
      child: Semantics(
        button: true,
        selected: selected,
        label: option.title,
        excludeSemantics: true,
        child: GestureDetector(
          onTap: () => _setVisualMode(option.mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(horizontal: showLabel ? 12 : 11),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? _accentColor : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(option.icon, size: 16, color: color),
                if (showLabel) ...[
                  const SizedBox(width: 5),
                  Text(
                    option.label,
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final displayPage = (_scrubPreviewPage ?? _currentPage.toDouble()).round();
    final progressPct = ((displayPage / BookReaderKeys.totalPages) * 100)
        .round();
    final canGoBack = _currentPage > 1;
    final canGoForward = _currentPage < BookReaderKeys.totalPages;

    return Container(
      height: _bottomBarHeight,
      padding: const EdgeInsets.fromLTRB(6, 4, 6, 6),
      decoration: _chromeDecoration(BorderRadius.circular(26)),
      child: Column(
        children: [
          // Scrubber gets the full width on every screen size
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: _accentColor,
                inactiveTrackColor: _accentColor.withValues(alpha: 0.20),
                thumbColor: _accentColor,
                overlayColor: _accentColor.withValues(alpha: 0.15),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                min: 1,
                max: BookReaderKeys.totalPages.toDouble(),
                value: (_scrubPreviewPage ?? _currentPage.toDouble()).clamp(
                  1.0,
                  BookReaderKeys.totalPages.toDouble(),
                ),
                onChanged: (val) {
                  setState(() => _scrubPreviewPage = val);
                },
                onChangeEnd: (val) {
                  _jumpToPage(val.round(), animate: false);
                  // Releasing on the current page fires no onPageChanged,
                  // so clear the preview here too.
                  setState(() => _scrubPreviewPage = null);
                },
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Previous page',
                  color: _chromeTextColor,
                  disabledColor: _chromeTextColor.withValues(alpha: 0.3),
                  onPressed: canGoBack
                      ? () => _jumpToPage(_currentPage - 1, animate: true)
                      : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _buildPagePill(context, displayPage, progressPct),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Next page',
                  color: _chromeTextColor,
                  disabledColor: _chromeTextColor.withValues(alpha: 0.3),
                  onPressed: canGoForward
                      ? () => _jumpToPage(_currentPage + 1, animate: true)
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
          SizedBox(height: 44, child: _buildZoomRow(context)),
        ],
      ),
    );
  }

  // Text size: A- / slider / A+. Lives only in the bottom bar so fullscreen
  // stays clean, but the chosen size carries into fullscreen.
  Widget _buildZoomRow(BuildContext context) {
    const step = 0.1;
    return Row(
      children: [
        IconButton(
          tooltip: 'Smaller text',
          color: _chromeTextColor,
          disabledColor: _chromeTextColor.withValues(alpha: 0.3),
          onPressed: _zoom > BookReaderKeys.minZoom
              ? () => _setZoom(_zoom - step)
              : null,
          icon: const Icon(Icons.text_decrease_rounded),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              activeTrackColor: _accentColor.withValues(alpha: 0.75),
              inactiveTrackColor: _accentColor.withValues(alpha: 0.18),
              thumbColor: _accentColor,
              overlayColor: _accentColor.withValues(alpha: 0.15),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            ),
            child: Slider(
              min: BookReaderKeys.minZoom,
              max: BookReaderKeys.maxZoom,
              divisions: 10,
              value: _zoom,
              semanticFormatterCallback: (value) =>
                  'Text size ${(value * 100).round()}%',
              onChanged: (value) => _setZoom(value, save: false),
              onChangeEnd: (value) => _setZoom(value),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Bigger text',
          color: _chromeTextColor,
          disabledColor: _chromeTextColor.withValues(alpha: 0.3),
          onPressed: _zoom < BookReaderKeys.maxZoom
              ? () => _setZoom(_zoom + step)
              : null,
          icon: const Icon(Icons.text_increase_rounded),
        ),
        SizedBox(
          width: 44,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${(_zoom * 100).round()}%',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _chromeTextColor.withValues(alpha: 0.75),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Tappable page pill that opens the jump-to-page sheet
  Widget _buildPagePill(BuildContext context, int displayPage, int pct) {
    return Material(
      color: _accentColor.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _showJumpSheet(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Page $displayPage of ${BookReaderKeys.totalPages}',
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _chromeTextColor,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '$pct%',
                style: GoogleFonts.quicksand(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _chromeTextColor.withValues(alpha: 0.65),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.unfold_more_rounded,
                size: 16,
                color: _chromeTextColor.withValues(alpha: 0.65),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Shared bottom-sheet shell: scrolls instead of overflowing on short
  // screens or when the keyboard is up.
  Future<void> _showReaderSheet(
    BuildContext context, {
    required Widget Function(BuildContext, StateSetter) builder,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: _sheetColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 24),
                child: StatefulBuilder(
                  builder: (context, setModalState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: _chromeTextColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        builder(context, setModalState),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.quicksand(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _chromeTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _chromeTextColor.withValues(alpha: 0.68),
          ),
        ),
      ],
    );
  }

  void _showEyeComfortSheet(BuildContext context) {
    _showReaderSheet(
      context,
      builder: (context, setModalState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSheetTitle(
              'Reading Peace & Eye Comfort',
              'Cozy botanical paper, crisp black-and-white E-Ink, or warm '
                  'low blue light for bedtime.',
            ),
            const SizedBox(height: 16),

            // Mode cards, equal height whatever the label length
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final option in _modeOptions) ...[
                    if (option != _modeOptions.first) const SizedBox(width: 10),
                    Expanded(
                      child: _buildSheetModeOption(option, setModalState),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),
            _buildSliderLabel(
              'Amber Warmth (Low Blue Light)',
              '${(_warmth * 100).round()}%',
            ),
            Slider(
              min: 0.0,
              max: 1.0,
              activeColor: _accentColor,
              value: _warmth,
              onChanged: (val) {
                if (_mode != ReaderVisualMode.lowBlueLight) {
                  // Store first: the mode change triggers a reload.
                  _settingsBox.put(BookReaderKeys.warmthLevel, val);
                  _setVisualMode(ReaderVisualMode.lowBlueLight);
                }
                setState(() => _warmth = val);
                setModalState(() {});
              },
              // Save once on release, not on every drag frame.
              onChangeEnd: (val) =>
                  _settingsBox.put(BookReaderKeys.warmthLevel, val),
            ),

            _buildSliderLabel(
              'Bedtime Extra Dimmer',
              '${(_dimmer * 100).round()}%',
            ),
            Slider(
              min: 0.0,
              max: 0.60,
              activeColor: _accentColor,
              value: _dimmer,
              onChanged: (val) {
                if (_mode != ReaderVisualMode.lowBlueLight) {
                  _settingsBox.put(BookReaderKeys.dimmerLevel, val);
                  _setVisualMode(ReaderVisualMode.lowBlueLight);
                }
                setState(() => _dimmer = val);
                setModalState(() {});
              },
              onChangeEnd: (val) =>
                  _settingsBox.put(BookReaderKeys.dimmerLevel, val),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSliderLabel(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _chromeTextColor,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: _accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildSheetModeOption(_ModeOption option, StateSetter setModalState) {
    final isSelected = _mode == option.mode;
    return GestureDetector(
      onTap: () {
        _setVisualMode(option.mode);
        setModalState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? _accentColor.withValues(alpha: 0.18)
              : _chromeTextColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _accentColor : Colors.transparent,
            width: 1.6,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(option.icon, color: _accentColor, size: 22),
            const SizedBox(height: 6),
            Text(
              option.title,
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _chromeTextColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              option.subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.quicksand(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: _chromeTextColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showJumpSheet(BuildContext context) {
    final textController = TextEditingController(text: '$_currentPage');

    void goTo(BuildContext sheetContext, int? page) {
      if (page == null) return;
      Navigator.of(sheetContext).pop();
      _jumpToPage(page);
    }

    _showReaderSheet(
      context,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSheetTitle(
              'Jump to Page',
              'Type a page between 1 and ${BookReaderKeys.totalPages}.',
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.go,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onSubmitted: (text) => goTo(context, int.tryParse(text)),
                    style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.w700,
                      color: _chromeTextColor,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Page number',
                      hintStyle: GoogleFonts.quicksand(
                        color: _chromeTextColor.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: _chromeTextColor.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () =>
                      goTo(context, int.tryParse(textController.text)),
                  child: Text(
                    'Go',
                    style: GoogleFonts.quicksand(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildJumpChip(context, 'Page 1 (Cover)', 1, goTo),
                _buildJumpChip(
                  context,
                  'Page ${BookReaderKeys.storyStartPage} (Story begins)',
                  BookReaderKeys.storyStartPage,
                  goTo,
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildJumpChip(
    BuildContext context,
    String label,
    int page,
    void Function(BuildContext, int?) goTo,
  ) {
    // Hand-styled rather than ActionChip, whose theme colours ignore the
    // reader's dark Low Blue Light palette.
    return Material(
      color: _accentColor.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => goTo(context, page),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Text(
            label,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w700,
              color: _chromeTextColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft backdrop behind the page: leaf sprigs in two corners plus scattered
/// hearts, sparkles and dots (stars and a moon at night). Positions come from
/// a fixed seed so the pattern never jumps between frames or page turns.
class _CozyBackdropPainter extends CustomPainter {
  final Color? leafColor;
  final List<Color> motifColors;
  final bool night;

  const _CozyBackdropPainter({
    this.leafColor,
    required this.motifColors,
    this.night = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    if (leafColor != null) {
      paint.color = leafColor!;
      _drawLeafCluster(
        canvas,
        paint,
        origin: Offset(size.width * 0.08, size.height * 0.12),
        baseAngle: 0.4,
        scale: 1.0,
      );
      _drawLeafCluster(
        canvas,
        paint,
        origin: Offset(size.width * 0.92, size.height * 0.86),
        baseAngle: math.pi + 0.35,
        scale: 1.15,
      );
    }

    if (night) {
      paint.color = motifColors.first;
      final moon = Offset(size.width * 0.84, size.height * 0.1);
      canvas.drawPath(
        Path.combine(
          PathOperation.difference,
          Path()..addOval(Rect.fromCircle(center: moon, radius: 22)),
          Path()..addOval(
            Rect.fromCircle(center: moon + const Offset(10, -7), radius: 19),
          ),
        ),
        paint,
      );
    }

    final random = math.Random(7);
    for (int i = 0; i < 48; i++) {
      final center = Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      );
      final motifSize = 5 + random.nextDouble() * 8;
      paint.color = motifColors[i % motifColors.length];
      // Nights are stars and dots; days mix in little hearts.
      switch (night ? i % 2 + 1 : i % 3) {
        case 0:
          canvas.drawPath(_heart(center, motifSize), paint);
        case 1:
          canvas.drawPath(_sparkle(center, motifSize), paint);
        default:
          canvas.drawCircle(center, motifSize * 0.3, paint);
      }
    }
  }

  Path _heart(Offset c, double s) {
    return Path()
      ..moveTo(c.dx, c.dy + s * 0.8)
      ..cubicTo(
        c.dx - s * 1.4,
        c.dy - s * 0.1,
        c.dx - s * 0.6,
        c.dy - s,
        c.dx,
        c.dy - s * 0.35,
      )
      ..cubicTo(
        c.dx + s * 0.6,
        c.dy - s,
        c.dx + s * 1.4,
        c.dy - s * 0.1,
        c.dx,
        c.dy + s * 0.8,
      )
      ..close();
  }

  Path _sparkle(Offset c, double r) {
    return Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
  }

  void _drawLeafCluster(
    Canvas canvas,
    Paint paint, {
    required Offset origin,
    required double baseAngle,
    required double scale,
  }) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(baseAngle);
    canvas.scale(scale);

    for (int i = -1; i <= 1; i++) {
      canvas.save();
      canvas.rotate(i * 0.42);
      final path = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(28, -42, 0, -96)
        ..quadraticBezierTo(-28, -42, 0, 0)
        ..close();
      canvas.drawPath(path, paint);
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CozyBackdropPainter oldDelegate) {
    return oldDelegate.leafColor != leafColor ||
        oldDelegate.night != night ||
        !listEquals(oldDelegate.motifColors, motifColors);
  }
}
