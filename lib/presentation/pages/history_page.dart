import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/sentiment_analysis.dart';
import '../bloc/history/history_bloc.dart';
import '../widgets/app_error_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/history_item_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/sentiment_result_card.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(const HistoryLoadRequested());
  }

  Future<void> _onExport(BuildContext context, String csv) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/sentiment_history.csv');
      await file.writeAsString(csv);
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Sentiment Analysis History',
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to export history')),
        );
      }
    }
  }

  Future<bool?> _confirmClear(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'Are you sure you want to delete all history? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showDetail(BuildContext context, SentimentAnalysis analysis) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                SentimentResultCard(analysis: analysis),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Original text:',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(analysis.inputText),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HistoryBloc, HistoryState>(
      listener: (context, state) {
        if (state is HistoryExportSuccess) {
          _onExport(context, state.csvContent);
        }
        if (state is HistoryFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'History',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            BlocBuilder<HistoryBloc, HistoryState>(
              builder: (context, state) {
                if (state is! HistoryLoaded) return const SizedBox.shrink();
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.download_rounded),
                      tooltip: 'Export as CSV',
                      onPressed: () => context
                          .read<HistoryBloc>()
                          .add(const HistoryExportRequested()),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded),
                      tooltip: 'Clear history',
                      onPressed: () async {
                        final confirmed = await _confirmClear(context);
                        if (confirmed == true && context.mounted) {
                          context
                              .read<HistoryBloc>()
                              .add(const HistoryClearRequested());
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<HistoryBloc, HistoryState>(
          builder: (context, state) {
            if (state is HistoryLoading || state is HistoryInitial) {
              return const LoadingWidget(message: 'Loading history...');
            }
            if (state is HistoryFailure) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () => context
                    .read<HistoryBloc>()
                    .add(const HistoryLoadRequested()),
              );
            }
            if (state is HistoryEmpty) {
              return const EmptyStateWidget(
                title: 'No analyses yet',
                subtitle:
                    'Your sentiment analyses will appear here after you run them.',
                icon: Icons.history_rounded,
              );
            }
            if (state is HistoryLoaded) {
              return RefreshIndicator(
                onRefresh: () async => context
                    .read<HistoryBloc>()
                    .add(const HistoryLoadRequested()),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.analyses.length,
                  itemBuilder: (context, index) {
                    final analysis = state.analyses[index];
                    return HistoryItemWidget(
                      analysis: analysis,
                      onDelete: () => context.read<HistoryBloc>().add(
                            HistoryDeleteItemRequested(id: analysis.id),
                          ),
                      onTap: () => _showDetail(context, analysis),
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
