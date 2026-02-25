import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:home_cleaning_app/controllers/bookings_controller.dart';
import 'package:home_cleaning_app/utils/app_theme.dart';
import 'package:home_cleaning_app/views/widgets/bookings/booking_card.dart';
import 'package:home_cleaning_app/views/widgets/bookings/booking_card_skeleton.dart';
import 'package:home_cleaning_app/views/screens/chat/chat_screen.dart';

class MyBookingsScreen extends StatelessWidget {
  MyBookingsScreen({super.key});

  final controller = Get.find<BookingsController>();

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Bookings', style: theme.displaySmall),
              SizedBox(height: 4.h),
              Text(
                controller.isProviderView
                    ? 'Manage customer requests and upcoming jobs.'
                    : 'Track your service requests in one place.',
                style: theme.bodySmall.copyWith(color: theme.secondaryText),
              ),
              SizedBox(height: 16.h),
              Obx(
                () => Row(
                  children: BookingListFilter.values
                      .map(
                        (filter) => Expanded(
                          child: _FilterChip(
                            label: _filterLabel(filter),
                            isSelected: controller.activeFilter.value == filter,
                            onTap: () => controller.changeFilter(filter),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: Obx(() {
                  // Show loading only if actively loading and no bookings yet
                  if (controller.isLoading.value &&
                      controller.bookings.isEmpty) {
                    return _LoadingState();
                  }
                  final bookings = controller.filteredBookings;
                  if (bookings.isEmpty) {
                    return _EmptyState(
                      isProviderView: controller.isProviderView,
                      filter: controller.activeFilter.value,
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      // Trigger refresh by re-listening
                      controller.initializeBookings();
                    },
                    color: theme.accent1,
                    child: ListView.builder(
                      itemCount: bookings.length,
                      padding: EdgeInsets.only(bottom: 24.h, top: 4.h),
                      itemBuilder: (_, index) {
                        final booking = bookings[index];
                        return BookingCard(
                          booking: booking,
                          isProviderView: controller.isProviderView,
                          onAccept: () => controller.acceptBooking(booking),
                          onReject: () => controller.rejectBooking(booking),
                          onCancel: () => controller.cancelBooking(booking),
                          onChat: () {
                            if (booking.bookingId == null) return;
                            Get.to(
                              () => ChatScreen(
                                booking: booking,
                                isProviderView: controller.isProviderView,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _filterLabel(BookingListFilter filter) {
    switch (filter) {
      case BookingListFilter.requests:
        return 'Requests';
      case BookingListFilter.upcoming:
        return 'Upcoming';
      case BookingListFilter.past:
        return 'Past';
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? theme.accent1 : theme.secondaryBackground,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.bodyMedium.copyWith(
              color: isSelected ? Colors.white : theme.primaryText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      padding: EdgeInsets.only(bottom: 24.h, top: 4.h),
      itemBuilder: (_, index) => const BookingCardSkeleton(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isProviderView, required this.filter});

  final bool isProviderView;
  final BookingListFilter filter;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final content = _getEmptyStateContent();

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(content.icon, size: 80.sp, color: theme.secondaryText),
          SizedBox(height: 16.h),
          Text(
            content.title,
            style: theme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          SizedBox(
            width: 280.w,
            child: Text(
              content.message,
              textAlign: TextAlign.center,
              style: theme.bodySmall.copyWith(color: theme.secondaryText),
            ),
          ),
        ],
      ),
    );
  }

  _EmptyStateContent _getEmptyStateContent() {
    if (isProviderView) {
      switch (filter) {
        case BookingListFilter.requests:
          return _EmptyStateContent(
            icon: Icons.notifications_none,
            title: 'No pending requests',
            message:
                'You\'re all caught up! New customer booking requests will appear here when they come in.',
          );
        case BookingListFilter.upcoming:
          return _EmptyStateContent(
            icon: Icons.calendar_today,
            title: 'No upcoming bookings',
            message:
                'You don\'t have any accepted bookings scheduled yet. Accepted requests will show up here.',
          );
        case BookingListFilter.past:
          return _EmptyStateContent(
            icon: Icons.history,
            title: 'No past bookings',
            message:
                'Your completed, rejected, and canceled bookings will appear here.',
          );
      }
    } else {
      switch (filter) {
        case BookingListFilter.requests:
          return _EmptyStateContent(
            icon: Icons.pending_actions,
            title: 'No pending requests',
            message:
                'You haven\'t made any service requests yet. Browse services and book your appointment!',
          );
        case BookingListFilter.upcoming:
          return _EmptyStateContent(
            icon: Icons.calendar_today,
            title: 'No upcoming bookings',
            message:
                'You don\'t have any confirmed bookings yet. Once a provider accepts your request, it will appear here.',
          );
        case BookingListFilter.past:
          return _EmptyStateContent(
            icon: Icons.history,
            title: 'No past bookings',
            message:
                'Your completed, canceled, and declined bookings will appear here.',
          );
      }
    }
  }
}

class _EmptyStateContent {
  const _EmptyStateContent({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;
}
