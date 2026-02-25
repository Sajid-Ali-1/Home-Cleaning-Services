import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/service_details_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';

class ServiceImagesGallery extends StatelessWidget {
  const ServiceImagesGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ServiceDetailsController>();
    final service = controller.currentService.value ?? controller.service;

    if (service.images == null || service.images!.isEmpty) {
      return const SizedBox.shrink();
    }

    if (service.images!.length == 1) {
      return _SingleImage(imageUrl: service.images!.first);
    }

    return Obx(() => _ImageGallery(
          images: service.images!,
          currentIndex: controller.currentImageIndex.value,
          onImageTap: (index) => controller.goToImage(index),
          onNext: () => controller.nextImage(),
          onPrevious: () => controller.previousImage(),
        ));
  }
}

class _SingleImage extends StatelessWidget {
  const _SingleImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300.h,
      decoration: BoxDecoration(
        color: AppTheme.of(context).textFieldColor,
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder(context);
        },
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: AppTheme.of(context).textFieldColor,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 60.sp,
          color: AppTheme.of(context).secondaryText,
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    return Container(
      color: AppTheme.of(context).textFieldColor,
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.of(context).accent1,
        ),
      ),
    );
  }
}

class _ImageGallery extends StatelessWidget {
  const _ImageGallery({
    required this.images,
    required this.currentIndex,
    required this.onImageTap,
    required this.onNext,
    required this.onPrevious,
  });

  final List<String> images;
  final int currentIndex;
  final ValueChanged<int> onImageTap;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main image
        GestureDetector(
          onTap: () => _showFullScreenGallery(context),
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: 300.h,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).textFieldColor,
                ),
                child: Image.network(
                  images[currentIndex],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildPlaceholder(context),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return _buildLoadingPlaceholder(context);
                  },
                ),
              ),
              // Navigation arrows
              if (images.length > 1) ...[
                Positioned(
                  left: 16.w,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: onPrevious,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16.w,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: onNext,
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                // Image counter
                Positioned(
                  bottom: 16.h,
                  right: 16.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${currentIndex + 1} / ${images.length}',
                      style: AppTheme.of(context).bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        // Thumbnail strip
        if (images.length > 1)
          Container(
            height: 80.h,
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final isSelected = index == currentIndex;
                return GestureDetector(
                  onTap: () => onImageTap(index),
                  child: Container(
                    width: 64.w,
                    margin: EdgeInsets.only(right: 8.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.of(context).accent1
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppTheme.of(context).textFieldColor,
                          child: Icon(
                            Icons.broken_image,
                            size: 20.sp,
                            color: AppTheme.of(context).secondaryText,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  void _showFullScreenGallery(BuildContext context) {
    Get.to(() => _FullScreenGallery(
          images: images,
          initialIndex: currentIndex,
        ));
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: AppTheme.of(context).textFieldColor,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 60.sp,
          color: AppTheme.of(context).secondaryText,
        ),
      ),
    );
  }

  Widget _buildLoadingPlaceholder(BuildContext context) {
    return Container(
      color: AppTheme.of(context).textFieldColor,
      child: Center(
        child: CircularProgressIndicator(
          color: AppTheme.of(context).accent1,
        ),
      ),
    );
  }
}

class _FullScreenGallery extends StatefulWidget {
  const _FullScreenGallery({
    required this.images,
    required this.initialIndex,
  });

  final List<String> images;
  final int initialIndex;

  @override
  State<_FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<_FullScreenGallery> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              child: Image.network(
                widget.images[index],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white,
                    size: 60.sp,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

