import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_options_analyzer/presentation/widgets/stock_navigator.dart';

void main() {
  group('StockNavigator Widget Tests', () {
    testWidgets('StockNavigator displays current symbol', (WidgetTester tester) async {
      // Define test data
      const currentSymbol = 'AAPL';
      final symbols = ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'META', 'TSLA', 'NVDA', 'PLTR'];
      String? changedSymbol;
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockNavigator(
              currentSymbol: currentSymbol,
              symbols: symbols,
              onSymbolChanged: (symbol) {
                changedSymbol = symbol;
              },
            ),
          ),
        ),
      );
      
      // Verify the current symbol is displayed
      expect(find.text(currentSymbol), findsOneWidget);
      
      // Verify navigation buttons are present
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });
    
    testWidgets('StockNavigator next button navigates to next stock', (WidgetTester tester) async {
      // Define test data
      const currentSymbol = 'AAPL';
      final symbols = ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'META', 'TSLA', 'NVDA', 'PLTR'];
      String? changedSymbol;
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockNavigator(
              currentSymbol: currentSymbol,
              symbols: symbols,
              onSymbolChanged: (symbol) {
                changedSymbol = symbol;
              },
            ),
          ),
        ),
      );
      
      // Tap the next button
      await tester.tap(find.byIcon(Icons.arrow_forward));
      await tester.pump();
      
      // Verify the symbol was changed to the next one
      expect(changedSymbol, equals('MSFT'));
    });
    
    testWidgets('StockNavigator previous button is disabled for first stock', (WidgetTester tester) async {
      // Define test data
      const currentSymbol = 'AAPL'; // First symbol
      final symbols = ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'META', 'TSLA', 'NVDA', 'PLTR'];
      String? changedSymbol;
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockNavigator(
              currentSymbol: currentSymbol,
              symbols: symbols,
              onSymbolChanged: (symbol) {
                changedSymbol = symbol;
              },
            ),
          ),
        ),
      );
      
      // Find the back button
      final backButton = find.byIcon(Icons.arrow_back);
      
      // Verify it's disabled (not tappable)
      final backButtonWidget = tester.widget<IconButton>(backButton);
      expect(backButtonWidget.onPressed, isNull);
      
      // Try to tap it anyway
      await tester.tap(backButton, warnIfMissed: false);
      await tester.pump();
      
      // Verify the symbol was not changed
      expect(changedSymbol, isNull);
    });
    
    testWidgets('StockNavigator next button is disabled for last stock', (WidgetTester tester) async {
      // Define test data
      const currentSymbol = 'PLTR'; // Last symbol
      final symbols = ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'META', 'TSLA', 'NVDA', 'PLTR'];
      String? changedSymbol;
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockNavigator(
              currentSymbol: currentSymbol,
              symbols: symbols,
              onSymbolChanged: (symbol) {
                changedSymbol = symbol;
              },
            ),
          ),
        ),
      );
      
      // Find the next button
      final nextButton = find.byIcon(Icons.arrow_forward);
      
      // Verify it's disabled (not tappable)
      final nextButtonWidget = tester.widget<IconButton>(nextButton);
      expect(nextButtonWidget.onPressed, isNull);
      
      // Try to tap it anyway
      await tester.tap(nextButton, warnIfMissed: false);
      await tester.pump();
      
      // Verify the symbol was not changed
      expect(changedSymbol, isNull);
    });
    
    testWidgets('StockNavigator dropdown changes selected stock', (WidgetTester tester) async {
      // Define test data
      const currentSymbol = 'AAPL';
      final symbols = ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'META', 'TSLA', 'NVDA', 'PLTR'];
      String? changedSymbol;
      
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StockNavigator(
              currentSymbol: currentSymbol,
              symbols: symbols,
              onSymbolChanged: (symbol) {
                changedSymbol = symbol;
              },
            ),
          ),
        ),
      );
      
      // Tap the dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      
      // Tap on a different stock
      await tester.tap(find.text('NVDA').last);
      await tester.pumpAndSettle();
      
      // Verify the symbol was changed
      expect(changedSymbol, equals('NVDA'));
    });
  });
}
