import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tunisian_trip_planner/core/theme/app_theme.dart';
import 'package:tunisian_trip_planner/features/auth/auth_cubit/auth_cubit.dart';
import 'package:tunisian_trip_planner/features/reviews/cubit/reviews_cubit.dart';
import 'package:tunisian_trip_planner/features/reviews/cubit/reviews_states.dart';
import 'package:tunisian_trip_planner/features/reviews/models/review_target_type.dart';
import 'package:tunisian_trip_planner/shared/network/local/cache_helper.dart';

class ReviewsSection extends StatelessWidget {
  final String targetId;
  final ReviewTargetType targetType;

  const ReviewsSection({
    super.key,
    required this.targetId,
    required this.targetType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              ReviewsCubit()
                ..fetchReviews(targetId: targetId, targetType: targetType),
      child: _ReviewsSectionView(targetId: targetId, targetType: targetType),
    );
  }
}

class _ReviewsSectionView extends StatelessWidget {
  final String targetId;
  final ReviewTargetType targetType;

  const _ReviewsSectionView({required this.targetId, required this.targetType});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return BlocConsumer<ReviewsCubit, ReviewsStates>(
      listener: (context, state) {
        if (state is ReviewSubmissionSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is ReviewSubmissionErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.errorColor,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ReviewsLoadingState || state is ReviewsInitialState) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ReviewsErrorState) {
          return Padding(
            padding: const EdgeInsets.all(32.0),
            child: Center(
              child: Text(
                'Failed to load reviews.',
                style: TextStyle(color: AppColors.errorColor),
              ),
            ),
          );
        }

        List reviews = [];
        bool hasMore = false;

        if (state is ReviewsLoadedState) {
          reviews = state.reviews;
          hasMore = !state.isLastPage;
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Reviews',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddReviewBottomSheet(context),
                    icon: Icon(Icons.edit_rounded, size: 16, color: cs.primary),
                    label: Text(
                      'Write a Review',
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        color: cs.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (reviews.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color:
                        isDark
                            ? AppColors.surfaceVariantD
                            : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.rate_review_outlined,
                        size: 48,
                        color: cs.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No reviews yet',
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Be the first to share your experience!',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: cs.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reviews.length + (hasMore ? 1 : 0),
                  separatorBuilder:
                      (_, __) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Divider(
                          color: cs.outline.withValues(alpha: 0.1),
                        ),
                      ),
                  itemBuilder: (context, index) {
                    if (index == reviews.length) {
                      return Center(
                        child: TextButton(
                          onPressed: () {
                            ReviewsCubit.get(context).fetchReviews(
                              targetId: targetId,
                              targetType: targetType,
                              loadMore: true,
                            );
                          },
                          child: const Text('Load More Reviews'),
                        ),
                      );
                    }

                    final review = reviews[index];
                    return _ReviewTile(review: review);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAddReviewBottomSheet(BuildContext ctx) {
    final cubit = ReviewsCubit.get(ctx);

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetCtx) {
        return BlocProvider.value(
          value: cubit,
          child: _AddReviewForm(targetId: targetId, targetType: targetType),
        );
      },
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final dynamic review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final rating = review.rating ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: cs.primary.withValues(alpha: 0.2),
              child: Text(
                (review.userId ?? 'U')[0].toUpperCase(),
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.bold,
                  color: cs.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.userId ?? 'Anonymous',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: Colors.amber,
                        size: 14,
                      );
                    }),
                  ),
                ],
              ),
            ),
            if (review.createdAt != null)
              Text(
                '${review.createdAt!.day}/${review.createdAt!.month}/${review.createdAt!.year}',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
        if (review.comment != null && review.comment!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            review.comment!,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: cs.onSurface.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _AddReviewForm extends StatefulWidget {
  final String targetId;
  final ReviewTargetType targetType;

  const _AddReviewForm({required this.targetId, required this.targetType});

  @override
  State<_AddReviewForm> createState() => _AddReviewFormState();
}

class _AddReviewFormState extends State<_AddReviewForm> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submit() {
    final comment = _commentController.text.trim();

    if (comment.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please write a review.')));
      return;
    }

    final authCubit = AuthCubit.get(context);
    final userId =
        authCubit.currentUserId ??
        CacheHelper.getData('userId') ??
        'MOCK-USER-123';
    final userName = _currentUserName(authCubit);

    ReviewsCubit.get(context).submitReview(
      targetId: widget.targetId,
      targetType: widget.targetType,
      userId: userId,
      userName: userName,
      comment: comment,
    );

    Navigator.pop(context);
  }

  String _currentUserName(AuthCubit authCubit) {
    final cachedName =
        CacheHelper.getData('userName') ?? CacheHelper.getData('username');
    if (cachedName is String && cachedName.trim().isNotEmpty) {
      return cachedName.trim();
    }

    final email = authCubit.currentEmail;
    if (email != null && email.trim().isNotEmpty) {
      return email.split('@').first;
    }

    return 'TuniWays User';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantD : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outline.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'How was your experience?',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Share details of your own experience at this place...',
                hintStyle: GoogleFonts.dmSans(
                  color: cs.onSurface.withValues(alpha: 0.4),
                ),
                filled: true,
                fillColor: isDark ? Colors.black26 : cs.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Submit Review',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
