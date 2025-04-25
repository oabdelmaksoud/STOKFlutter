import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class SupportResistanceChart extends StatelessWidget {
  final List<double> prices;
  final List<String> dates;
  final List<double> supportLevels;
  final List<double> resistanceLevels;
  final double currentPrice;
  final String symbol;

  const SupportResistanceChart({
    super.key,
    required this.prices,
    required this.dates,
    required this.supportLevels,
    required this.resistanceLevels,
    required this.currentPrice,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    if (prices.isEmpty || dates.isEmpty) {
      return const Center(child: Text('No price data available'));
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$symbol Support & Resistance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    horizontalInterval: 1,
                    verticalInterval: 1,
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: _calculateDateInterval(),
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() < 0 || value.toInt() >= dates.length) {
                            return const Text('');
                          }
                          // Show only a few dates to avoid overcrowding
                          if (value.toInt() % _calculateDateInterval().toInt() != 0) {
                            return const Text('');
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _formatDate(dates[value.toInt()]),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _calculatePriceInterval(),
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '\$${value.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d)),
                  ),
                  minX: 0,
                  maxX: prices.length - 1.0,
                  minY: _getMinY(),
                  maxY: _getMaxY(),
                  lineBarsData: [
                    // Main price line
                    LineChartBarData(
                      spots: _createSpots(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index >= 0 && index < dates.length && index < prices.length) {
                            return LineTooltipItem(
                              '${_formatDate(dates[index])}\n\$${prices[index].toStringAsFixed(2)}',
                              const TextStyle(color: Colors.white),
                            );
                          } else {
                            return LineTooltipItem(
                              '',
                              const TextStyle(color: Colors.white),
                            );
                          }
                        }).toList();
                      },
                    ),
                    handleBuiltInTouches: true,
                  ),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      // Current price line
                      HorizontalLine(
                        y: currentPrice,
                        color: Colors.black,
                        strokeWidth: 2,
                        dashArray: [5, 5],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(right: 8, bottom: 8),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          labelResolver: (line) => 'Current: \$${currentPrice.toStringAsFixed(2)}',
                        ),
                      ),
                      // Support levels
                      ...supportLevels.map((level) => HorizontalLine(
                        y: level,
                        color: Colors.green,
                        strokeWidth: 1.5,
                        dashArray: [3, 3],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(right: 8, bottom: 8),
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          labelResolver: (line) => 'S: \$${level.toStringAsFixed(2)}',
                        ),
                      )),
                      // Resistance levels
                      ...resistanceLevels.map((level) => HorizontalLine(
                        y: level,
                        color: Colors.red,
                        strokeWidth: 1.5,
                        dashArray: [3, 3],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          padding: const EdgeInsets.only(right: 8, bottom: 8),
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                          labelResolver: (line) => 'R: \$${level.toStringAsFixed(2)}',
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('Support', Colors.green),
                  const SizedBox(width: 16),
                  _buildLegendItem('Resistance', Colors.red),
                  const SizedBox(width: 16),
                  _buildLegendItem('Current Price', Colors.black),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<FlSpot> _createSpots() {
    return List.generate(prices.length, (index) {
      return FlSpot(index.toDouble(), prices[index]);
    });
  }

  double _getMinY() {
    double min = prices.reduce((curr, next) => curr < next ? curr : next);
    
    // Include support levels in min calculation
    if (supportLevels.isNotEmpty) {
      final supportMin = supportLevels.reduce((curr, next) => curr < next ? curr : next);
      min = min < supportMin ? min : supportMin;
    }
    
    // Add some padding
    return min * 0.95;
  }

  double _getMaxY() {
    double max = prices.reduce((curr, next) => curr > next ? curr : next);
    
    // Include resistance levels in max calculation
    if (resistanceLevels.isNotEmpty) {
      final resistanceMax = resistanceLevels.reduce((curr, next) => curr > next ? curr : next);
      max = max > resistanceMax ? max : resistanceMax;
    }
    
    // Add some padding
    return max * 1.05;
  }

  double _calculatePriceInterval() {
    final min = _getMinY();
    final max = _getMaxY();
    final range = max - min;
    
    // Choose an appropriate interval based on the range
    if (range > 500) return 100;
    if (range > 200) return 50;
    if (range > 100) return 20;
    if (range > 50) return 10;
    if (range > 20) return 5;
    if (range > 10) return 2;
    if (range > 5) return 1;
    if (range > 2) return 0.5;
    if (range > 1) return 0.2;
    return 0.1;
  }

  double _calculateDateInterval() {
    final length = dates.length;
    if (length > 365) return 60;
    if (length > 180) return 30;
    if (length > 90) return 15;
    if (length > 60) return 10;
    if (length > 30) return 5;
    if (length > 14) return 2;
    return 1;
  }

  String _formatDate(String isoDate) {
    // Convert ISO date to MM/DD format
    final parts = isoDate.split('-');
    if (parts.length >= 3) {
      return '${parts[1]}/${parts[2]}';
    }
    return isoDate;
  }
}
