import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:stock_options_analyzer/data/services/yahoo_finance_service.dart';
import 'package:stock_options_analyzer/domain/services/technical_analysis_service.dart';
import 'package:stock_options_analyzer/domain/services/support_resistance_service.dart';
import 'package:stock_options_analyzer/domain/services/options_analysis_service.dart';
import 'package:stock_options_analyzer/presentation/blocs/stock_bloc.dart';
import 'package:stock_options_analyzer/presentation/screens/home_screen.dart';
import 'package:stock_options_analyzer/utils/performance_optimizer.dart';

void main() {
  // Initialize dependency injection
  setupDependencies();
  
  // Run the app
  runApp(const StockOptionsAnalyzerApp());
}

void setupDependencies() {
  final getIt = GetIt.instance;
  
  // Register services
  getIt.registerSingleton<YahooFinanceService>(YahooFinanceService());
  getIt.registerSingleton<TechnicalAnalysisService>(TechnicalAnalysisService());
  getIt.registerSingleton<SupportResistanceService>(SupportResistanceService());
  getIt.registerSingleton<OptionsAnalysisService>(OptionsAnalysisService());
  
  // Register blocs
  getIt.registerFactory<StockBloc>(() => StockBloc());
}

class StockOptionsAnalyzerApp extends StatelessWidget {
  const StockOptionsAnalyzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Options Analyzer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        cardTheme: CardTheme(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
