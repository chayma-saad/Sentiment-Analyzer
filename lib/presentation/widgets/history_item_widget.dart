import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/sentiment_analysis.dart';

class HistoryItemWidget extends StatelessWidget {
  const HistoryItemWidget({
    super.key,
    required this.analysis,
    required this.onDelete,
    required this.onTap,
  });

  final SentimentAnalysis analysis;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sentimentColor = _sentimentColor(analysis.sentiment);
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(analysis.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    color: sentimentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _sentimentIcon(analysis.sentiment),
                            color: sentimentColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            analysis.sentiment.label,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: sentimentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: sentimentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${analysis.confidencePercent}%',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: sentimentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        analysis.inputText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat.yMMMd().add_jm().format(analysis.analyzedAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
