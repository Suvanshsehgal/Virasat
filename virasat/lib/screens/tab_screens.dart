import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../models/heritage_place.dart';
import '../services/heritage_api_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_decorations.dart';
import '../theme/app_animations.dart';
import '../widgets/ashoka_chakra.dart';
import '../widgets/heritage_list_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const List<double> _radiusOptions = [
    10, 25, 50, 75, 100, 125, 150, 175, 200,
  ];

  final HeritageApiService _apiService = HeritageApiService();

  double _selectedRadius = 10;
  List<HeritagePlace> _places = [];
  bool _loading = false;
  String? _error;
  bool _hasSearched = false;
  double? _currentLat;
  double? _currentLng;
  bool _showListPanel = false;
  late MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _apiService.dispose();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    setState(() {
      _loading = true;
      _error = null;
      _places = [];
      _showListPanel = false;
    });

    try {
      final status = await ph.Permission.location.request();
      if (!mounted) return;

      if (status.isDenied || status.isPermanentlyDenied) {
        setState(() {
          _error =
              'Location permission is required to find nearby heritage places.';
          _loading = false;
          _hasSearched = true;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return;

      _currentLat = pos.latitude;
      _currentLng = pos.longitude;

      _mapController.move(LatLng(pos.latitude, pos.longitude), 13);

      final result = await _apiService.fetchNearbyHeritage(
        latitude: pos.latitude,
        longitude: pos.longitude,
        radius: _selectedRadius,
      );
      if (!mounted) return;

      setState(() {
        _places = result.places;
        _loading = false;
        _hasSearched = true;
        if (result.places.isNotEmpty) _showListPanel = true;
      });
    } on LocationServiceDisabledException {
      if (!mounted) return;
      setState(() {
        _error =
            'GPS is disabled. Please enable location services to find nearby heritage places.';
        _loading = false;
        _hasSearched = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = _formatError(e);
        _loading = false;
        _hasSearched = true;
      });
    }
  }

  String _formatError(dynamic e) {
    final msg = e.toString();
    if (msg.contains('SocketException') || msg.contains('Connection refused')) {
      return 'Unable to connect to the server. Please check your connection.';
    }
    if (msg.contains('timeout')) {
      return 'Search timed out after multiple attempts. Overpass server may be slow — please try again in a moment.';
    }
    if (msg.contains('400') || msg.contains('Bad Request')) {
      return 'Invalid request. Please try a different radius.';
    }
    if (msg.contains('502')) {
      return 'Our AI service is temporarily unavailable. Please try again in a moment.';
    }
    if (msg.contains('500') || msg.contains('Internal Server')) {
      return 'Server error. Please try again later.';
    }
    return msg;
  }

  IconData _placeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'temple':
      case 'temples':
        return Icons.temple_hindu_outlined;
      case 'fort':
      case 'forts':
        return Icons.location_city_outlined;
      case 'palace':
      case 'palaces':
        return Icons.account_balance_outlined;
      case 'mosque':
      case 'mosques':
        return Icons.mosque_outlined;
      case 'stepwell':
      case 'stepwells':
        return Icons.water_drop_outlined;
      case 'museum':
      case 'museums':
        return Icons.museum_outlined;
      case 'unesco':
        return Icons.public_outlined;
      case 'garden':
      case 'gardens':
        return Icons.nature_outlined;
      case 'memorial':
      case 'monument':
      case 'monuments':
        return Icons.account_balance_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  void _showPlaceInfo(HeritagePlace place) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gold, AppColors.goldLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _placeIcon(place.type),
                    color: AppColors.darkBase,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: AppTypography.monumentName.copyWith(fontSize: 20),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _detailChip(place.type, AppColors.terracotta),
                          const SizedBox(width: 8),
                          _detailChip(
                            '${place.distanceKm.toStringAsFixed(1)} km',
                            AppColors.goldDark,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (place.description.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.deepSurface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: AppTypography.metadata.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      place.description,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: AppColors.terracotta,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${place.latitude.toStringAsFixed(4)}, ${place.longitude.toStringAsFixed(4)}',
                    style: TextStyle(
                      fontFamily: AppTypography.inter,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.inter,
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _mapView(),
          _topOverlay(),
          if (_loading) _loadingOverlay(),
          if (_error != null) _statusBanner(_error!, isError: true),
          if (_hasSearched && _places.isEmpty && _error == null)
            _statusBanner(_buildNoPlacesMessage()),
          _bottomPanelHandle(),
          if (_showListPanel && _places.isNotEmpty) _listPanel(),
        ],
      ),
    );
  }

  Widget _mapView() {
    final center = _currentLat != null && _currentLng != null
        ? LatLng(_currentLat!, _currentLng!)
        : const LatLng(20.5937, 78.9629); // India default

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 5.0,
        minZoom: 4.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.virasat.app',
        ),
        if (_currentLat != null && _currentLng != null)
          MarkerLayer(
            markers: [
              _userMarker(),
              ..._places.map((p) => _heritageMarker(p)),
            ],
          ),
      ],
    );
  }

  Marker _userMarker() {
    return Marker(
      width: 48,
      height: 48,
      point: LatLng(_currentLat!, _currentLng!),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.jade,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.jade.withValues(alpha: 0.4),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.my_location, color: Colors.white, size: 24),
      ),
    );
  }

  Marker _heritageMarker(HeritagePlace place) {
    return Marker(
      width: 48,
      height: 48,
      point: LatLng(place.latitude, place.longitude),
      child: GestureDetector(
        onTap: () => _showPlaceInfo(place),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.terracotta,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.terracotta.withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  Widget _topOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.pageBg,
              AppColors.pageBg.withValues(alpha: 0.95),
              AppColors.pageBg.withValues(alpha: 0.0),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nearby Heritage Places',
                  style: AppTypography.screenTitle.copyWith(fontSize: 22),
                ),
                const SizedBox(height: 2),
                Text(
                  'आस-पास के विरासत स्थल',
                  style: AppTypography.devanagariSubtitle(size: 22),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 3,
                  decoration: AppDecorations.tricolorDivider,
                ),
                const SizedBox(height: 12),
                _radiusSelector(),
                const SizedBox(height: 10),
                _searchButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _radiusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Radius',
          style: AppTypography.metadata.copyWith(fontSize: 11),
        ),
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _radiusOptions.map((km) {
              final active = _selectedRadius == km;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedRadius = km),
                  child: AnimatedContainer(
                    duration: AppAnimations.duration300,
                    curve: AppAnimations.entryCurve,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: active
                        ? AppDecorations.filterPillActive
                        : AppDecorations.filterPillInactive,
                    child: Text(
                      '$km km',
                      style: TextStyle(
                        fontFamily: AppTypography.inter,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: active
                            ? AppColors.darkBase
                            : AppColors.terracotta,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _searchButton() {
    final isLoading = _loading;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : _search,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.darkBase,
          disabledBackgroundColor: AppColors.gold.withValues(alpha: 0.5),
          disabledForegroundColor: AppColors.darkBase.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.darkBase,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Searching...',
                    style: AppTypography.buttonGold.copyWith(fontSize: 15),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Discover Heritage Places',
                    style: AppTypography.buttonGold.copyWith(fontSize: 15),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _loadingOverlay() {
    return Positioned.fill(
      child: Container(
        color: AppColors.pageBg.withValues(alpha: 0.88),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 48),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
            decoration: BoxDecoration(
              color: AppColors.cardSurface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warmShadow.withValues(alpha: 0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AshokaChakra(size: 48, animate: true),
                const SizedBox(height: 20),
                Text(
                  'Searching...',
                  style: AppTypography.sectionHeader.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  'खोज रहा है',
                  style: AppTypography.devanagariSubtitle(size: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  'Discovering heritage sites near you...',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const SizedBox(
                    width: 140,
                    height: 4,
                    child: LinearProgressIndicator(
                      color: AppColors.gold,
                      backgroundColor: AppColors.border,
                      minHeight: 4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusBanner(String message, {bool isError = false}) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 210,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isError ? AppColors.terracotta : AppColors.goldDark,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: (isError ? AppColors.terracotta : AppColors.goldDark)
                    .withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(
                      isError ? Icons.error_outline : Icons.info_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontFamily: AppTypography.inter,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
              if (isError) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _search,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Text(
                        'Retry',
                        style: TextStyle(
                          fontFamily: AppTypography.inter,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _buildNoPlacesMessage() {
    final radiusStr = _selectedRadius.toStringAsFixed(0);
    return 'No heritage places found within $radiusStr km near your location. Try increasing the radius or check if your area has heritage sites listed on Wikipedia.';
  }

  Widget _bottomPanelHandle() {
    if (!_showListPanel || _places.isEmpty) return const SizedBox.shrink();
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: () => setState(() => _showListPanel = !_showListPanel),
        child: Container(
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: AppColors.warmShadow,
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Center(
            child: AnimatedContainer(
              duration: AppAnimations.duration300,
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _listPanel() {
    final maxHeight = MediaQuery.of(context).size.height * 0.4;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 500) {
            setState(() => _showListPanel = false);
          }
        },
        child: Container(
          height: maxHeight,
          decoration: BoxDecoration(
            color: AppColors.cardSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: AppColors.warmShadow,
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${_places.length}',
                            style: const TextStyle(
                              fontFamily: AppTypography.inter,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: AppColors.goldDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'place${_places.length == 1 ? '' : 's'} found',
                          style: TextStyle(
                            fontFamily: AppTypography.inter,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _showListPanel = false),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.deepSurface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textMuted,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, color: AppColors.border),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: _places.length,
                  itemBuilder: (context, index) {
                    final place = _places[index];
                    return HeritageListCard(
                      place: place,
                      onViewOnMap: () {
                        _showPlaceInfo(place);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
