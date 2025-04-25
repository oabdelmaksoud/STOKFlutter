import 'package:flutter/material.dart';
import 'package:stock_options_analyzer/data/models/stock.dart';
import 'package:stock_options_analyzer/data/models/technical_analysis.dart';
import 'package:stock_options_analyzer/data/models/support_resistance.dart';
import 'package:stock_options_analyzer/data/models/options.dart';

class ExecutiveSummaryWidget extends StatelessWidget {
  final Stock stock;
  final TechnicalAnalysis technicalAnalysis;
  final SupportResistance supportResistance;
  final OptionsAnalysis optionsAnalysis;
  final MultipleExpiryRecommendations multipleExpiryRecommendations;

  const ExecutiveSummaryWidget({
    super.key,
    required this.stock,
    required this.technicalAnalysis,
    required this.supportResistance,
    required this.optionsAnalysis,
    required this.multipleExpiryRecommendations,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(),
            _buildSummaryText(context),
            const Divider(),
            _buildKeyMetrics(context),
            const Divider(),
            _buildRecommendations(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: _getTechnicalOutlookColor(technicalAnalysis.technicalOutlook),
          child: Text(
            stock.symbol[0],
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Executive Summary',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${stock.name} (${stock.symbol})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${stock.currentPrice.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'as of ${_formatDate(stock.retrievalTime)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        _generateSummaryText(),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }

  Widget _buildKeyMetrics(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Metrics',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  context,
                  'Technical Outlook',
                  technicalAnalysis.technicalOutlook,
                  _getTechnicalOutlookColor(technicalAnalysis.technicalOutlook),
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  context,
                  'Day Trader Signal',
                  supportResistance.dayTraderRecommendation.signal,
                  _getSignalColor(supportResistance.dayTraderRecommendation.signal),
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  context,
                  'RSI (14)',
                  technicalAnalysis.rsi.toStringAsFixed(2),
                  _getRsiColor(technicalAnalysis.rsi),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  context,
                  'Volatility',
                  '${(stock.volatility * 100).toStringAsFixed(2)}%',
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  context,
                  'SMA 50',
                  '\$${technicalAnalysis.sma50.toStringAsFixed(2)}',
                  technicalAnalysis.currentPrice > technicalAnalysis.sma50
                      ? Colors.green
                      : Colors.red,
                ),
              ),
              Expanded(
                child: _buildMetricItem(
                  context,
                  'SMA 200',
                  '\$${technicalAnalysis.sma200.toStringAsFixed(2)}',
                  technicalAnalysis.currentPrice > technicalAnalysis.sma200
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: valueColor,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendations(BuildContext context) {
    // Get the top recommendation from each expiry
    final List<OptionRecommendation> topRecommendations = [];
    
    if (multipleExpiryRecommendations.oneWeekExpiryRecommendations.isNotEmpty) {
      topRecommendations.add(multipleExpiryRecommendations.oneWeekExpiryRecommendations.first);
    }
    
    if (multipleExpiryRecommendations.twoWeekExpiryRecommendations.isNotEmpty) {
      topRecommendations.add(multipleExpiryRecommendations.twoWeekExpiryRecommendations.first);
    }
    
    if (multipleExpiryRecommendations.monthlyExpiryRecommendations.isNotEmpty) {
      topRecommendations.add(multipleExpiryRecommendations.monthlyExpiryRecommendations.first);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Recommendations',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (topRecommendations.isEmpty)
          const Text('No recommendations available')
        else
          Column(
            children: topRecommendations.map((recommendation) {
              return _buildRecommendationItem(context, recommendation);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildRecommendationItem(BuildContext context, OptionRecommendation recommendation) {
    String details;
    
    if (recommendation.type == 'STRANGLE' || recommendation.type == 'STRADDLE') {
      details = '${recommendation.type}: Call @ \$${recommendation.callStrike?.toStringAsFixed(2)}, '
          'Put @ \$${recommendation.putStrike?.toStringAsFixed(2)}';
    } else {
      details = '${recommendation.type} @ \$${recommendation.strike.toStringAsFixed(2)}';
    }
    
    return ListTile(
      title: Text(
        '${_getStrategyName(recommendation.type)} (${recommendation.expiry})',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(details),
      trailing: Chip(
        label: Text(
          recommendation.confidence,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: _getConfidenceColor(recommendation.confidence),
      ),
    );
  }

  String _generateSummaryText() {
    final outlook = technicalAnalysis.technicalOutlook;
    final signal = supportResistance.dayTraderRecommendation.signal;
    final rsi = technicalAnalysis.rsi;
    final macdSignal = technicalAnalysis.macd > technicalAnalysis.macdSignal ? 'bullish' : 'bearish';
    final smaStatus = technicalAnalysis.currentPrice > technicalAnalysis.sma50 ? 'above' : 'below';
    final sma200Status = technicalAnalysis.currentPrice > technicalAnalysis.sma200 ? 'above' : 'below';
    
    String rsiDescription;
    if (rsi > 70) {
      rsiDescription = 'overbought';
    } else if (rsi < 30) {
      rsiDescription = 'oversold';
    } else {
      rsiDescription = 'neutral';
    }
    
    return '${stock.name} (${stock.symbol}) is currently showing a ${outlook.toLowerCase()} technical outlook '
        'with a ${signal.toLowerCase()} day trading signal. The stock is trading at \$${stock.currentPrice.toStringAsFixed(2)}, '
        'which is $smaStatus the 50-day moving average and $sma200Status the 200-day moving average. '
        'The RSI is at ${rsi.toStringAsFixed(2)}, indicating $rsiDescription conditions, and the MACD is showing a $macdSignal signal. '
        'Based on these indicators, options strategies have been recommended with varying expiry dates to capitalize on the expected price movement.';
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

  Color _getSignalColor(String signal) {
    switch (signal) {
      case 'BUY':
        return Colors.green;
      case 'SELL':
        return Colors.red;
      default:
        return Colors.orange;
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

  Color _getConfidenceColor(String confidence) {
    switch (confidence.toLowerCase()) {
      case 'high':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  String _getStrategyName(String type) {
    switch (type) {
      case 'CALL':
        return 'Long Call';
      case 'PUT':
        return 'Long Put';
      case 'STRANGLE':
        return 'Strangle';
      case 'STRADDLE':
        return 'Straddle';
      default:
        return type;
    }
  }

  String _formatDate(String isoDate) {
    // Convert ISO date to MM/DD/YYYY format
    final parts = isoDate.split('T')[0].split('-');
    if (parts.length >= 3) {
      return '${parts[1]}/${parts[2]}/${parts[0]}';
    }
    return isoDate;
  }
}
