import 'package:flutter/material.dart';
import 'package:stock_options_analyzer/data/models/options.dart';

class OptionsRecommendationCard extends StatelessWidget {
  final OptionRecommendation recommendation;

  const OptionsRecommendationCard({
    super.key,
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Divider(),
            _buildDetails(context),
            if (recommendation.type == 'STRANGLE' || recommendation.type == 'STRADDLE')
              _buildStrategyDetails(context),
            const SizedBox(height: 16),
            _buildRiskRewardIndicator(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getStrategyName(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Expiry: ${recommendation.expiry}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        _buildConfidenceChip(),
      ],
    );
  }

  Widget _buildDetails(BuildContext context) {
    if (recommendation.type == 'STRANGLE' || recommendation.type == 'STRADDLE') {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        _buildInfoRow('Option Type', recommendation.type),
        _buildInfoRow('Strike Price', '\$${recommendation.strike.toStringAsFixed(2)}'),
        _buildInfoRow('Premium', '\$${recommendation.premium.toStringAsFixed(2)}'),
        if (recommendation.delta != null)
          _buildInfoRow('Delta', recommendation.delta!.toStringAsFixed(2)),
        if (recommendation.gamma != null)
          _buildInfoRow('Gamma', recommendation.gamma!.toStringAsFixed(4)),
        if (recommendation.theta != null)
          _buildInfoRow('Theta', recommendation.theta!.toStringAsFixed(4)),
        if (recommendation.vega != null)
          _buildInfoRow('Vega', recommendation.vega!.toStringAsFixed(4)),
        _buildInfoRow('Risk/Reward', recommendation.riskReward.toStringAsFixed(2)),
      ],
    );
  }

  Widget _buildStrategyDetails(BuildContext context) {
    return Column(
      children: [
        _buildInfoRow('Strategy', recommendation.type),
        if (recommendation.callStrike != null)
          _buildInfoRow('Call Strike', '\$${recommendation.callStrike!.toStringAsFixed(2)}'),
        if (recommendation.putStrike != null)
          _buildInfoRow('Put Strike', '\$${recommendation.putStrike!.toStringAsFixed(2)}'),
        if (recommendation.callPremium != null)
          _buildInfoRow('Call Premium', '\$${recommendation.callPremium!.toStringAsFixed(2)}'),
        if (recommendation.putPremium != null)
          _buildInfoRow('Put Premium', '\$${recommendation.putPremium!.toStringAsFixed(2)}'),
        if (recommendation.totalPremium != null)
          _buildInfoRow('Total Premium', '\$${recommendation.totalPremium!.toStringAsFixed(2)}'),
        _buildInfoRow('Risk/Reward', recommendation.riskReward.toStringAsFixed(2)),
      ],
    );
  }

  Widget _buildRiskRewardIndicator(BuildContext context) {
    final double ratio = recommendation.riskReward.clamp(0.0, 5.0);
    final Color color = _getRiskRewardColor(ratio);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Risk/Reward Ratio',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: ratio / 5.0,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 10,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Poor', style: TextStyle(fontSize: 12)),
            Text(
              ratio.toStringAsFixed(2),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const Text('Excellent', style: TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceChip() {
    Color color;
    switch (recommendation.confidence.toLowerCase()) {
      case 'high':
        color = Colors.green;
        break;
      case 'medium':
        color = Colors.orange;
        break;
      default:
        color = Colors.red;
    }

    return Chip(
      label: Text(
        recommendation.confidence,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color,
    );
  }

  String _getStrategyName() {
    switch (recommendation.type) {
      case 'CALL':
        return 'Long Call';
      case 'PUT':
        return 'Long Put';
      case 'STRANGLE':
        return 'Strangle';
      case 'STRADDLE':
        return 'Straddle';
      default:
        return recommendation.type;
    }
  }

  Color _getRiskRewardColor(double ratio) {
    if (ratio < 1.0) return Colors.red;
    if (ratio < 2.0) return Colors.orange;
    if (ratio < 3.0) return Colors.yellow[700]!;
    return Colors.green;
  }
}
