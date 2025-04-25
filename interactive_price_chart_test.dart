import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stock_options_analyzer/presentation/widgets/interactive_price_chart.dart';

void main() {
  group('InteractivePriceChart Widget Tests', () {
    final List<double> testPrices = [150.0, 152.5, 151.0, 153.0, 155.5, 154.0, 156.0, 158.5];
    final List<String> testDates = [
      '2025-04-18', '2025-04-19', '2025-04-20', '2025-04-21', 
      '2025-04-22', '2025-04-23', '2025-04-24', '2025-04-25'
    ];
    final List<double> testSma50 = [149.0, 150.0, 151.0, 152.0, 153.0, 154.0, 155.0, 156.0];
    final List<double> testSma200 = [145.0, 146.0, 147.0, 148.0, 149.0, 150.0, 151.0, 152.0];
    
    testWidgets('InteractivePriceChart displays chart with correct data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              child: InteractivePriceChart(
                prices: testPrices,
                dates: testDates,
                symbol: 'AAPL',
                sma50: testSma50,
                sma200: testSma200,
              ),
            ),
          ),
        ),
      );
      
      // Verify chart title is displayed
      expect(find.text('AAPL Price Chart'), findsOneWidget);
      
      // Verify time range buttons are displayed
      expect(find.text('1W'), findsOneWidget);
      expect(find.text('1M'), findsOneWidget);
      expect(find.text('3M'), findsOneWidget);
      expect(find.text('6M'), findsOneWidget);
      expect(find.text('1Y'), findsOneWidget);
      
      // Verify legend items are displayed
      expect(find.text('Price'), findsOneWidget);
      expect(find.text('SMA 50'), findsOneWidget);
      expect(find.text('SMA 200'), findsOneWidget);
    });
    
    testWidgets('InteractivePriceChart time range buttons change the displayed data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              child: InteractivePriceChart(
                prices: testPrices,
                dates: testDates,
                symbol: 'AAPL',
                sma50: testSma50,
                sma200: testSma200,
              ),
            ),
          ),
        ),
      );
      
      // Initially 1Y is selected
      final initialYearButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, '1Y'));
      expect(initialYearButton.style?.backgroundColor?.resolve({MaterialState.selected}), isNotNull);
      
      // Tap on 1W button
      await tester.tap(find.text('1W'));
      await tester.pumpAndSettle();
      
      // Verify 1W is now selected
      final weekButton = tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, '1W'));
      expect(weekButton.style?.backgroundColor?.resolve({MaterialState.selected}), isNotNull);
    });
    
    testWidgets('InteractivePriceChart legend checkboxes toggle indicator visibility', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              child: InteractivePriceChart(
                prices: testPrices,
                dates: testDates,
                symbol: 'AAPL',
                sma50: testSma50,
                sma200: testSma200,
              ),
            ),
          ),
        ),
      );
      
      // Find SMA 50 checkbox
      final sma50CheckboxFinder = find.byType(Checkbox).at(0);
      
      // Initially checkbox should be checked
      Checkbox sma50Checkbox = tester.widget<Checkbox>(sma50CheckboxFinder);
      expect(sma50Checkbox.value, isTrue);
      
      // Tap on SMA 50 checkbox to uncheck it
      await tester.tap(sma50CheckboxFinder);
      await tester.pumpAndSettle();
      
      // Verify checkbox is now unchecked
      sma50Checkbox = tester.widget<Checkbox>(sma50CheckboxFinder);
      expect(sma50Checkbox.value, isFalse);
    });
    
    testWidgets('InteractivePriceChart handles empty data gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 500,
              child: InteractivePriceChart(
                prices: [],
                dates: [],
                symbol: 'AAPL',
              ),
            ),
          ),
        ),
      );
      
      // Verify empty state message is displayed
      expect(find.text('No price data available'), findsOneWidget);
    });
  });
}
