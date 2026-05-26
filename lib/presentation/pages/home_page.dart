import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_constants.dart';
import '../bloc/sentiment/sentiment_bloc.dart';
import '../bloc/theme/theme_cubit.dart';
import '../widgets/app_error_widget.dart';
import '../widgets/loading_widget.dart';
import '../widgets/sentiment_result_card.dart';
import 'history_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;
  bool _isRealTimeMode = false;

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onTextChanged(String text) {
    if (!_isRealTimeMode) return;
    _debounceTimer?.cancel();
    if (text.trim().isEmpty) {
      context.read<SentimentBloc>().add(const SentimentReset());
      return;
    }
    _debounceTimer = Timer(
      const Duration(milliseconds: AppConstants.debounceMilliseconds),
      () => _analyze(text),
    );
  }

  void _analyze(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    context.read<SentimentBloc>().add(SentimentAnalyzeRequested(text: trimmed));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = context.watch<ThemeCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sentiment Analyzer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            tooltip: 'Toggle theme',
            onPressed: () => context.read<ThemeCubit>().toggle(),
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'History',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const HistoryPage()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme),
              const SizedBox(height: 24),
              _buildInputSection(theme),
              const SizedBox(height: 8),
              _buildModeToggle(theme),
              const SizedBox(height: 24),
              _buildResult(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter your text and get an AI-powered sentiment analysis.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1);
  }

  Widget _buildInputSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _textController,
          focusNode: _focusNode,
          maxLines: 6,
          minLines: 4,
          maxLength: AppConstants.maxInputLength,
          onChanged: _onTextChanged,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: 'Type or paste your text here...',
            fillColor: theme.colorScheme.surfaceContainerHighest,
            counterStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ),
        ),
        const SizedBox(height: 12),
        BlocBuilder<SentimentBloc, SentimentState>(
          builder: (context, state) {
            final isLoading = state is SentimentLoading;
            return ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () => _analyze(_textController.text),
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.auto_awesome_rounded),
              label: Text(isLoading ? 'Analyzing...' : 'Analyze Sentiment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            );
          },
        ),
      ],
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildModeToggle(ThemeData theme) {
    return Row(
      children: [
        Switch.adaptive(
          value: _isRealTimeMode,
          onChanged: (value) {
            setState(() => _isRealTimeMode = value);
            if (!value) {
              _debounceTimer?.cancel();
            }
          },
        ),
        const SizedBox(width: 8),
        Text(
          'Real-time analysis',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(width: 4),
        Tooltip(
          message: 'Automatically analyzes as you type (debounced)',
          child: Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.4),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    return BlocBuilder<SentimentBloc, SentimentState>(
      builder: (context, state) {
        if (state is SentimentLoading) {
          return const LoadingWidget();
        }
        if (state is SentimentFailure) {
          return AppErrorWidget(
            message: state.message,
            onRetry: () => _analyze(_textController.text),
          );
        }
        if (state is SentimentSuccess) {
          return SentimentResultCard(analysis: state.analysis);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
