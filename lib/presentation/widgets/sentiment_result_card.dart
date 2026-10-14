import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/sentiment_analysis.dart';

class SentimentResultCard extends StatelessWidget {
  const SentimentResultCard({super.key, required this.analysis});
  final SentimentAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final sentimentColor = _sentimentColor(analysis.sentiment);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_sentimentIcon(analysis.sentiment),
                    color: sentimentColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  analysis.sentiment.label,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: sentimentColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _ConfidenceBadge(
                    percent: analysis.confidencePercent, color: sentimentColor),
              ],
            ),
            const SizedBox(height: 16),
            _ConfidenceBar(
                value: analysis.confidenceScore, color: sentimentColor),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: sentimentColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: sentimentColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline,
                          color: sentimentColor, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Motivation',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: sentimentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    analysis.motivation,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }

  Color _sentimentColor(SentimentType sentiment) {
    switch (sentiment) {
      case SentimentType.positive:
        return AppTheme.positiveColor;
      case SentimentType.negative:
        return AppTheme.negativeColor;
      case SentimentType.neutral:
        return AppTheme.neutralColor;
    }
  }

  IconData _sentimentIcon(SentimentType sentiment) {
    switch (sentiment) {
      case SentimentType.positive:
        return Icons.sentiment_very_satisfied_rounded;
      case SentimentType.negative:
        return Icons.sentiment_very_dissatisfied_rounded;
      case SentimentType.neutral:
        return Icons.sentiment_neutral_rounded;
    }
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.percent, required this.color});
  final int percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$percent%',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _ConfidenceBar extends StatelessWidget {
  const _ConfidenceBar({required this.value, required this.color});
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Confidence',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${(value * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            builder: (_, animValue, __) => LinearProgressIndicator(
              value: animValue,
              backgroundColor: color.withOpacity(0.15),
              color: color,
              minHeight: 8,
            ),
          ),
        ),
      ],
    );
  }
}
