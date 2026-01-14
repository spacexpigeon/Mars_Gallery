import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/photo.dart';
import '../../core/cache.dart'; 
import '../theme/app_theme.dart';

class PhotoCard extends ConsumerStatefulWidget {
  final Photo photo;
  final int index;
  final VoidCallback? onTap;

  const PhotoCard({
    super.key,
    required this.photo,
    required this.index,
    this.onTap,
  });

  @override
  ConsumerState<PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends ConsumerState<PhotoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    Future.delayed(Duration(milliseconds: widget.index * 50), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final imageUrl = widget.photo.url.replaceFirst('http://', 'https://');

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.highlightColor.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrl, 
                  fit: BoxFit.cover,
                  

                  cacheManager: MarsCache.build(), 
                  
                  memCacheWidth: 800,
                  memCacheHeight: 600,
                  fadeInDuration: const Duration(milliseconds: 200),
                  fadeOutDuration: const Duration(milliseconds: 100),
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: AppTheme.surfaceColor,
                    highlightColor: AppTheme.secondaryColor,
                    child: Container(
                      color: AppTheme.surfaceColor,
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    print('❌ BŁĄD: $url -> $error');
                    return Container(
                      color: AppTheme.surfaceColor,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.red, 
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.photo.roverName ?? 'Rover',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.photo.cameraName ?? 'Camera',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
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
}