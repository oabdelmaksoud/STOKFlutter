# Flutter Stock Options Analyzer

A Flutter-based application for analyzing stock options, providing technical analysis, support/resistance levels, and options recommendations.

## Features

- **Stock Data Retrieval**: Fetches real-time stock data from Yahoo Finance
- **Technical Analysis**: Calculates key technical indicators (SMA, RSI, MACD)
- **Support & Resistance**: Identifies support and resistance levels with day trader recommendations
- **Options Analysis**: Provides options trading recommendations with Greeks analysis
- **Multiple Expiry Recommendations**: Analyzes options for different expiry dates (1-week, 2-week, monthly)
- **Interactive Charts**: Native chart visualization with time range selection and indicator toggling
- **Stock Navigation**: Easily navigate between different stocks using dropdown or next/previous buttons
- **Executive Summary**: Quick overview of analysis results and key metrics
- **Error Handling**: Comprehensive error handling with user-friendly messages

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository:
```
git clone https://github.com/yourusername/stock_options_analyzer.git
```

2. Navigate to the project directory:
```
cd stock_options_analyzer
```

3. Install dependencies:
```
flutter pub get
```

4. Run the application:
```
flutter run
```

## Usage

1. Launch the application
2. Select a stock from the dropdown menu or use the navigation buttons
3. View the technical analysis, support/resistance levels, and options recommendations
4. Use the time range selector to adjust the chart view
5. Toggle indicators on/off using the checkboxes
6. Navigate between different tabs to see detailed analysis

## Project Structure

```
lib/
├── data/
│   ├── models/
│   │   ├── stock.dart
│   │   ├── technical_analysis.dart
│   │   ├── support_resistance.dart
│   │   └── options.dart
│   └── services/
│       └── yahoo_finance_service.dart
├── domain/
│   └── services/
│       ├── technical_analysis_service.dart
│       ├── support_resistance_service.dart
│       └── options_analysis_service.dart
├── presentation/
│   ├── blocs/
│   │   └── stock_bloc.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   └── stock_detail_screen.dart
│   └── widgets/
│       ├── price_chart.dart
│       ├── interactive_price_chart.dart
│       ├── support_resistance_chart.dart
│       ├── technical_indicators_card.dart
│       ├── options_recommendation_card.dart
│       ├── multiple_expiry_recommendations.dart
│       ├── executive_summary.dart
│       ├── stock_navigator.dart
│       └── error_handling.dart
├── utils/
│   └── performance_optimizer.dart
└── main.dart
```

## Testing

Run the tests using:
```
flutter test
```

The test suite includes:
- Widget tests for stock navigation
- Widget tests for error handling
- Widget tests for interactive charts

## Performance Optimization

The application includes performance optimization utilities:
- RepaintBoundary for efficient rendering
- Visibility-aware widgets for list optimization
- Memory-efficient image loading
- Debug tools for performance monitoring

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Yahoo Finance API for stock data
- Flutter and Dart teams for the amazing framework
- fl_chart for chart visualization
