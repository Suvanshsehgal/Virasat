import 'package:flutter/material.dart';
import '../models/heritage_place.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_decorations.dart';

class HeritageListCard extends StatelessWidget {
  final HeritagePlace place;
  final VoidCallback onViewOnMap;

  const HeritageListCard({
    super.key,
    required this.place,
    required this.onViewOnMap,
  });

  IconData _typeIcon(String type) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppDecorations.cardActive,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gold, AppColors.goldLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _typeIcon(place.type),
                  color: AppColors.darkBase,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      style: AppTypography.monumentName.copyWith(fontSize: 17),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _badge(place.type),
                        const SizedBox(width: 8),
                        _distanceBadge(place.distanceKm),
                      ],
                    ),
                    if (place.description.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        place.description,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 34,
                      child: TextButton.icon(
                        onPressed: onViewOnMap,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.goldDark,
                          backgroundColor: AppColors.gold.withValues(alpha: 0.1),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.map_outlined, size: 16),
                        label: const Text(
                          'View on Map',
                          style: TextStyle(
                            fontFamily: AppTypography.inter,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String label) {
    final color = AppColors.terracotta;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTypography.inter,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _distanceBadge(double km) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.goldLight.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.near_me_outlined,
            size: 11,
            color: AppColors.goldDark,
          ),
          const SizedBox(width: 4),
          Text(
            '${km.toStringAsFixed(1)} km',
            style: TextStyle(
              fontFamily: AppTypography.inter,
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: AppColors.goldDark,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
