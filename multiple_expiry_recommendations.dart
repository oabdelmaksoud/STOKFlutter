import 'package:flutter/material.dart';
import 'package:stock_options_analyzer/data/models/options.dart';

class MultipleExpiryRecommendationsWidget extends StatelessWidget {
  final MultipleExpiryRecommendations recommendations;

  const MultipleExpiryRecommendationsWidget({
    super.key,
    required this.recommendations,
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
            Text(
              'Multiple Expiry Recommendations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildExpectedMoveSection(context),
            const Divider(),
            _buildExpiryComparisonSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildExpectedMoveSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expected Price Moves',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildExpectedMoveRow(
          context,
          'One Week (${recommendations.oneWeekExpiry})',
          recommendations.oneWeekExpectedMove,
          recommendations.currentPrice,
        ),
        _buildExpectedMoveRow(
          context,
          'Two Weeks (${recommendations.twoWeekExpiry})',
          recommendations.twoWeekExpectedMove,
          recommendations.currentPrice,
        ),
        _buildExpectedMoveRow(
          context,
          'Monthly (${recommendations.monthlyExpiry})',
          recommendations.monthlyExpectedMove,
          recommendations.currentPrice,
        ),
      ],
    );
  }

  Widget _buildExpectedMoveRow(
    BuildContext context,
    String label,
    double expectedMove,
    double currentPrice,
  ) {
    final percentMove = (expectedMove / currentPrice * 100).toStringAsFixed(2);
    final lowRange = (currentPrice - expectedMove).toStringAsFixed(2);
    final highRange = (currentPrice + expectedMove).toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '±\$${expectedMove.toStringAsFixed(2)} (±$percentMove%)',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              'Range: \$$lowRange - \$$highRange',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryComparisonSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Expiry Comparison',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(recommendations.expiryComparison),
        const SizedBox(height: 16),
        _buildExpiryComparisonTable(context),
      ],
    );
  }

  Widget _buildExpiryComparisonTable(BuildContext context) {
    return Table(
      border: TableBorder.all(
        color: Colors.grey.shade300,
        width: 1,
      ),
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
          ),
          children: [
            _buildTableHeader('Factor'),
            _buildTableHeader('1-Week'),
            _buildTableHeader('2-Week'),
            _buildTableHeader('Monthly'),
          ],
        ),
        _buildComparisonRow(
          'Premium Cost',
          'Low',
          'Medium',
          'High',
        ),
        _buildComparisonRow(
          'Time Decay (Theta)',
          'High',
          'Medium',
          'Low',
        ),
        _buildComparisonRow(
          'Probability of Success',
          _getProbabilityOfSuccess(recommendations.oneWeekExpectedMove, recommendations.currentPrice),
          _getProbabilityOfSuccess(recommendations.twoWeekExpectedMove, recommendations.currentPrice),
          _getProbabilityOfSuccess(recommendations.monthlyExpectedMove, recommendations.currentPrice),
        ),
        _buildComparisonRow(
          'Volatility Exposure',
          'Low',
          'Medium',
          'High',
        ),
      ],
    );
  }

  TableRow _buildComparisonRow(
    String factor,
    String oneWeek,
    String twoWeek,
    String monthly,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(factor, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(oneWeek, textAlign: TextAlign.center),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(twoWeek, textAlign: TextAlign.center),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(monthly, textAlign: TextAlign.center),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _getProbabilityOfSuccess(double expectedMove, double currentPrice) {
    final percentMove = expectedMove / currentPrice;
    
    if (percentMove < 0.03) {
      return 'High';
    } else if (percentMove < 0.05) {
      return 'Medium';
    } else {
      return 'Low';
    }
  }
}
