import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/theme/app_theme.dart';
import 'injection_container.dart';
import 'presentation/bloc/history/history_bloc.dart';
import 'presentation/bloc/sentiment/sentiment_bloc.dart';
import 'presentation/bloc/theme/theme_cubit.dart';
import 'presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initDependencies();
  runApp(const SentimentApp());
}

class SentimentApp extends StatelessWidget {
  const SentimentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()),
        BlocProvider<SentimentBloc>(create: (_) => sl<SentimentBloc>()),
        BlocProvider<HistoryBloc>(create: (_) => sl<HistoryBloc>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'Sentiment Analyzer',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeMode,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
