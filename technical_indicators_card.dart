import 'package:flutter/material.dart';
import 'package:stock_options_analyzer/data/models/technical_analysis.dart';

class TechnicalIndicatorsCard extends StatelessWidget {
  final TechnicalAnalysis technicalAnalysis;

  const TechnicalIndicatorsCard({
    super.key,
    required this.technicalAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Technical Analysis',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildTechnicalOutlook(context),
            const Divider(),
            _buildIndicatorsTable(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTechnicalOutlook(BuildContext context) {
    Color outlookColor = _getTechnicalOutlookColor(technicalAnalysis.technicalOutlook);
    
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: outlookColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: outlookColor),
      ),
      child: Row(
        children: [
          Icon(
            _getTechnicalOutlookIcon(technicalAnalysis.technicalOutlook),
            color: outlookColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Technical Outlook',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(
                  technicalAnalysis.technicalOutlook,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: outlookColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorsTable(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          children: [
            _buildTableHeader('Indicator'),
            _buildTableHeader('Value'),
            _buildTableHeader('Signal'),
          ],
        ),
        _buildIndicatorRow(
          'SMA 50',
          '\$${technicalAnalysis.sma50.toStringAsFixed(2)}',
          technicalAnalysis.currentPrice > technicalAnalysis.sma50 ? 'Bullish' : 'Bearish',
          technicalAnalysis.currentPrice > technicalAnalysis.sma50 ? Colors.green : Colors.red,
        ),
        _buildIndicatorRow(
          'SMA 200',
          '\$${technicalAnalysis.sma200.toStringAsFixed(2)}',
          technicalAnalysis.currentPrice > technicalAnalysis.sma200 ? 'Bullish' : 'Bearish',
          technicalAnalysis.currentPrice > technicalAnalysis.sma200 ? Colors.green : Colors.red,
        ),
        _buildIndicatorRow(
          'RSI (14)',
          technicalAnalysis.rsi.toStringAsFixed(2),
          _getRsiSignal(technicalAnalysis.rsi),
          _getRsiColor(technicalAnalysis.rsi),
        ),
        _buildIndicatorRow(
          'MACD',
          technicalAnalysis.macd.toStringAsFixed(2),
          technicalAnalysis.macd > technicalAnalysis.macdSignal ? 'Bullish' : 'Bearish',
          technicalAnalysis.macd > technicalAnalysis.macdSignal ? Colors.green : Colors.red,
        ),
        _buildIndicatorRow(
          'MACD Signal',
          technicalAnalysis.macdSignal.toStringAsFixed(2),
          '',
          Colors.black,
        ),
        _buildIndicatorRow(
          'MACD Histogram',
          technicalAnalysis.macdHistogram.toStringAsFixed(2),
          technicalAnalysis.macdHistogram > 0 ? 'Bullish' : 'Bearish',
          technicalAnalysis.macdHistogram > 0 ? Colors.green : Colors.red,
        ),
      ],
    );
  }

  TableRow _buildIndicatorRow(String name, String value, String signal, Color signalColor) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Text(value),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          child: Text(
            signal,
            style: TextStyle(
              color: signalColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getTechnicalOutlookColor(String outlook) {
    if (outlook.contains('Bullish')) {
      return Colors.green;
    } else if (outlook.contains('Bearish')) {
      return Colors.red;
    } else {
      return Colors.orange;
    }
  }

  IconData _getTechnicalOutlookIcon(String outlook) {
    if (outlook.contains('Bullish')) {
      return Icons.trending_up;
    } else if (outlook.contains('Bearish')) {
      return Icons.trending_down;
    } else {
      return Icons.trending_flat;
    }
  }

  String _getRsiSignal(double rsi) {
    if (rsi > 70) {
      return 'Overbought';
    } else if (rsi < 30) {
      return 'Oversold';
    } else {
      return 'Neutral';
    }
  }

  Color _getRsiColor(double rsi) {
    if (rsi > 70) {
      return Colors.red;
    } else if (rsi < 30) {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }
}
