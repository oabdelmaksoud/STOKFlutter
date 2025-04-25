import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:stock_options_analyzer/data/models/stock.dart';

class InteractivePriceChart extends StatefulWidget {
  final List<double> prices;
  final List<String> dates;
  final String symbol;
  final List<double>? sma50;
  final List<double>? sma200;

  const InteractivePriceChart({
    super.key,
    required this.prices,
    required this.dates,
    required this.symbol,
    this.sma50,
    this.sma200,
  });

  @override
  State<InteractivePriceChart> createState() => _InteractivePriceChartState();
}

class _InteractivePriceChartState extends State<InteractivePriceChart> {
  // Chart interaction state
  double? _touchedValue;
  int? _touchedIndex;
  bool _showSMA50 = true;
  bool _showSMA200 = true;
  String _timeRange = '1Y'; // Default to 1 year
  
  // Calculated values
  late List<double> _displayPrices;
  late List<String> _displayDates;
  late List<double>? _displaySMA50;
  late List<double>? _displaySMA200;

  @override
  void initState() {
    super.initState();
    _updateDisplayData();
  }

  void _updateDisplayData() {
    // Apply time range filter
    int daysToShow;
    switch (_timeRange) {
      case '1W':
        daysToShow = 7;
        break;
      case '1M':
        daysToShow = 30;
        break;
      case '3M':
        daysToShow = 90;
        break;
      case '6M':
        daysToShow = 180;
        break;
      case '1Y':
      default:
        daysToShow = 365;
        break;
    }
    
    // Ensure we don't try to show more days than we have data for
    daysToShow = daysToShow.clamp(0, widget.prices.length);
    
    // Get the most recent data based on the selected time range
    _displayPrices = widget.prices.length > daysToShow 
        ? widget.prices.sublist(widget.prices.length - daysToShow) 
        : widget.prices;
    
    _displayDates = widget.dates.length > daysToShow 
        ? widget.dates.sublist(widget.dates.length - daysToShow) 
        : widget.dates;
    
    // Filter SMA data if available
    if (widget.sma50 != null) {
      _displaySMA50 = widget.sma50!.length > daysToShow 
          ? widget.sma50!.sublist(widget.sma50!.length - daysToShow) 
          : widget.sma50;
    } else {
      _displaySMA50 = null;
    }
    
    if (widget.sma200 != null) {
      _displaySMA200 = widget.sma200!.length > daysToShow 
          ? widget.sma200!.sublist(widget.sma200!.length - daysToShow) 
          : widget.sma200;
    } else {
      _displaySMA200 = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.prices.isEmpty || widget.dates.isEmpty) {
      return const Center(child: Text('No price data available'));
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            _buildTimeRangeSelector(),
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
                          if (value.toInt() < 0 || value.toInt() >= _displayDates.length) {
                            return const Text('');
                          }
                          // Show only a few dates to avoid overcrowding
                          if (value.toInt() % _calculateDateInterval().toInt() != 0) {
                            return const Text('');
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              _formatDate(_displayDates[value.toInt()]),
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
                  maxX: _displayPrices.length - 1.0,
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
                    // SMA 50 line
                    if (_showSMA50 && _displaySMA50 != null)
                      LineChartBarData(
                        spots: _createSMASpots(_displaySMA50!),
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 1.5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                      ),
                    // SMA 200 line
                    if (_showSMA200 && _displaySMA200 != null)
                      LineChartBarData(
                        spots: _createSMASpots(_displaySMA200!),
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 1.5,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                      ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                      getTooltipItems: (List<LineBarSpot> touchedSpots) {
                        return touchedSpots.map((spot) {
                          final index = spot.x.toInt();
                          if (index >= 0 && index < _displayDates.length && index < _displayPrices.length) {
                            setState(() {
                              _touchedValue = _displayPrices[index];
                              _touchedIndex = index;
                            });
                            return LineTooltipItem(
                              '${_formatDate(_displayDates[index])}\n\$${_displayPrices[index].toStringAsFixed(2)}',
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
                    touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                      if (event is FlTapUpEvent || event is FlPanEndEvent) {
                        setState(() {
                          _touchedValue = null;
                          _touchedIndex = null;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            if (_touchedValue != null && _touchedIndex != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Selected: ${_formatDate(_displayDates[_touchedIndex!])} - \$${_touchedValue!.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${widget.symbol} Price Chart',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: () {
                // Zoom in functionality could be implemented here
              },
              tooltip: 'Zoom In',
            ),
            IconButton(
              icon: const Icon(Icons.zoom_out),
              onPressed: () {
                // Zoom out functionality could be implemented here
              },
              tooltip: 'Zoom Out',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeRangeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimeRangeButton('1W'),
        _buildTimeRangeButton('1M'),
        _buildTimeRangeButton('3M'),
        _buildTimeRangeButton('6M'),
        _buildTimeRangeButton('1Y'),
      ],
    );
  }

  Widget _buildTimeRangeButton(String range) {
    final isSelected = _timeRange == range;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _timeRange = range;
            _updateDisplayData();
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : null,
          foregroundColor: isSelected ? Colors.white : null,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(40, 36),
        ),
        child: Text(range),
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(
            'Price',
            Colors.blue,
            true,
            null,
          ),
          if (widget.sma50 != null)
            _buildLegendItem(
              'SMA 50',
              Colors.green,
              _showSMA50,
              (value) {
                setState(() {
                  _showSMA50 = value;
                });
              },
            ),
          if (widget.sma200 != null)
            _buildLegendItem(
              'SMA 200',
              Colors.red,
              _showSMA200,
              (value) {
                setState(() {
                  _showSMA200 = value;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    String label,
    Color color,
    bool isVisible,
    Function(bool)? onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          if (onChanged != null)
            Checkbox(
              value: isVisible,
              onChanged: (value) {
                if (value != null) {
                  onChanged(value);
                }
              },
              visualDensity: VisualDensity.compact,
            )
          else
            const SizedBox(width: 8),
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
      ),
    );
  }

  List<FlSpot> _createSpots() {
    return List.generate(_displayPrices.length, (index) {
      return FlSpot(index.toDouble(), _displayPrices[index]);
    });
  }

  List<FlSpot> _createSMASpots(List<double> smaValues) {
    // Align SMA values with the price data
    final offset = _displayPrices.length - smaValues.length;
    return List.generate(smaValues.length, (index) {
      return FlSpot((index + offset).toDouble(), smaValues[index]);
    });
  }

  double _getMinY() {
    double min = _displayPrices.reduce((curr, next) => curr < next ? curr : next);
    if (_showSMA50 && _displaySMA50 != null) {
      final sma50Min = _displaySMA50!.reduce((curr, next) => curr < next ? curr : next);
      min = min < sma50Min ? min : sma50Min;
    }
    if (_showSMA200 && _displaySMA200 != null) {
      final sma200Min = _displaySMA200!.reduce((curr, next) => curr < next ? curr : next);
      min = min < sma200Min ? min : sma200Min;
    }
    // Add some padding
    return min * 0.95;
  }

  double _getMaxY() {
    double max = _displayPrices.reduce((curr, next) => curr > next ? curr : next);
    if (_showSMA50 && _displaySMA50 != null) {
      final sma50Max = _displaySMA50!.reduce((curr, next) => curr > next ? curr : next);
      max = max > sma50Max ? max : sma50Max;
    }
    if (_showSMA200 && _displaySMA200 != null) {
      final sma200Max = _displaySMA200!.reduce((curr, next) => curr > next ? curr : next);
      max = max > sma200Max ? max : sma200Max;
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
    final length = _displayDates.length;
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
(Content truncated due to size limit. Use line ranges to read in chunks)