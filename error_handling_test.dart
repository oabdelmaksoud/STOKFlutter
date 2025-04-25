import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_options_analyzer/presentation/widgets/error_handling.dart';

void main() {
  group('Error Handling Widgets Tests', () {
    testWidgets('ErrorDisplay shows error message and retry button', (WidgetTester tester) async {
      bool retryPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(
              message: 'Test error message',
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );
      
      // Verify error icon is displayed
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      
      // Verify error message is displayed
      expect(find.text('Test error message'), findsOneWidget);
      
      // Verify retry button is displayed
      expect(find.text('Retry'), findsOneWidget);
      
      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pump();
      
      // Verify retry callback was called
      expect(retryPressed, isTrue);
    });
    
    testWidgets('LoadingDisplay shows loading indicator and message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const LoadingDisplay(
              message: 'Loading data...',
            ),
          ),
        ),
      );
      
      // Verify loading indicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Verify loading message is displayed
      expect(find.text('Loading data...'), findsOneWidget);
    });
    
    testWidgets('LoadingDisplay shows progress percentage when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const LoadingDisplay(
              message: 'Loading data...',
              progress: 0.75,
            ),
          ),
        ),
      );
      
      // Verify progress indicator is displayed
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // Verify progress percentage is displayed
      expect(find.text('75%'), findsOneWidget);
      
      // Verify loading message is displayed
      expect(find.text('Loading data...'), findsOneWidget);
    });
    
    testWidgets('YahooFinanceErrorDisplay shows specific guidance for different errors', (WidgetTester tester) async {
      bool retryPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: YahooFinanceErrorDisplay(
              symbol: 'AAPL',
              errorMessage: 'No data found',
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );
      
      // Verify error icon is displayed
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      
      // Verify specific error message is displayed
      expect(find.text('No data found for AAPL'), findsOneWidget);
      
      // Verify helpful guidance is displayed
      expect(find.text('This symbol may not be available on Yahoo Finance or may have been delisted.'), findsOneWidget);
      
      // Tap retry button
      await tester.tap(find.text('Retry'));
      await tester.pump();
      
      // Verify retry callback was called
      expect(retryPressed, isTrue);
    });
  });
}
