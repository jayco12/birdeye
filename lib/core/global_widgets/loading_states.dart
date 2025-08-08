import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'animated_widgets.dart';

class LoadingStateWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final bool showProgress;

  const LoadingStateWidget({
    super.key,
    this.message = 'Loading...',
    this.icon,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showProgress)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          if (icon != null && !showProgress)
            Icon(
              icon,
              size: 48,
              color: AppColors.primary,
            ).animate(onPlay: (controller) => controller.repeat())
                .rotate(duration: 2000.ms),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;

  const ErrorStateWidget({
    super.key,
    this.title = 'Error',
    required this.message,
    this.onRetry,
    this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.headingSmall.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            AnimatedGradientButton(
              text: retryText ?? 'Try Again',
              icon: Icons.refresh,
              onPressed: onRetry!,
            ),
          ],
        ],
      ),
    ).animate().fadeIn().shake();
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const EmptyStateWidget({
    super.key,
    this.title = 'No Data',
    required this.message,
    this.icon = Icons.inbox,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 48,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.headingSmall,
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          if (onAction != null) ...[
            const SizedBox(height: 16),
            AnimatedGradientButton(
              text: actionText ?? 'Take Action',
              onPressed: onAction!,
            ),
          ],
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.8, 0.8));
  }
}

class SearchLoadingWidget extends StatelessWidget {
  final String query;

  const SearchLoadingWidget({
    super.key,
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const Icon(
                Icons.search,
                color: AppColors.primary,
                size: 20,
              ).animate(onPlay: (controller) => controller.repeat())
                  .scale(duration: 1000.ms, curve: Curves.easeInOut)
                  .then()
                  .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Searching for "$query"...',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a moment',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }
}

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1500.ms,
          color: Colors.white.withOpacity(0.6),
        );
  }
}

class VerseSkeletonLoader extends StatelessWidget {
  const VerseSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonLoader(width: 32, height: 32),
              const SizedBox(width: 12),
              const Expanded(
                child: SkeletonLoader(width: double.infinity, height: 16),
              ),
              SkeletonLoader(
                width: 60,
                height: 24,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SkeletonLoader(width: double.infinity, height: 16),
          const SizedBox(height: 8),
          const SkeletonLoader(width: double.infinity, height: 16),
          const SizedBox(height: 8),
          const SkeletonLoader(width: 200, height: 16),
          const SizedBox(height: 12),
          Row(
            children: [
              SkeletonLoader(
                width: 60,
                height: 28,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 8),
              SkeletonLoader(
                width: 80,
                height: 28,
                borderRadius: BorderRadius.circular(8),
              ),
              const SizedBox(width: 8),
              SkeletonLoader(
                width: 50,
                height: 28,
                borderRadius: BorderRadius.circular(8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}