import 'package:flutter/material.dart';
import 'package:stock_options_analyzer/data/models/stock.dart';

/// Widget for displaying error states with retry functionality
class ErrorDisplay extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorDisplay({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying loading states with progress information
class LoadingDisplay extends StatelessWidget {
  final String message;
  final double? progress;

  const LoadingDisplay({
    super.key,
    required this.message,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (progress != null) ...[
              CircularProgressIndicator(value: progress),
              const SizedBox(height: 16),
              Text(
                '${(progress! * 100).toInt()}%',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ] else ...[
              const CircularProgressIndicator(),
            ],
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying empty states with action buttons
class EmptyDisplay extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;

  const EmptyDisplay({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.search_off,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.grey,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying data loading errors with specific error handling for Yahoo Finance
class YahooFinanceErrorDisplay extends StatelessWidget {
  final String symbol;
  final String errorMessage;
  final VoidCallback onRetry;

  const YahooFinanceErrorDisplay({
    super.key,
    required this.symbol,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    String displayMessage = errorMessage;
    String helpText = '';
    
    // Provide specific guidance based on error type
    if (errorMessage.contains('No data found')) {
      displayMessage = 'No data found for $symbol';
      helpText = 'This symbol may not be available on Yahoo Finance or may have been delisted.';
    } else if (errorMessage.contains('timeout')) {
      displayMessage = 'Connection timeout';
      helpText = 'The request to Yahoo Finance timed out. Please check your internet connection and try again.';
    } else if (errorMessage.contains('403')) {
      displayMessage = 'Access denied';
      helpText = 'Yahoo Finance API access is currently restricted. This may be due to rate limiting or API changes.';
    }

    return Card(
      margin: const EdgeInsets.all(16.0),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  'Data Loading Error',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              displayMessage,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (helpText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                helpText,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension methods for handling common error scenarios
extension ErrorHandlingExtensions on Exception {
  String getUserFriendlyMessage() {
    final errorMessage = toString();
    
    if (errorMessage.contains('SocketException') || 
        errorMessage.contains('Connection refused')) {
      return 'Network connection error. Please check your internet connection and try again.';
    } else if (errorMessage.contains('timeout')) {
      return 'The request timed out. Please try again later.';
    } else if (errorMessage.contains('404')) {
      return 'The requested resource was not found.';
    } else if (errorMessage.contains('403')) {
      return 'Access to the requested resource is forbidden.';
    } else if (errorMessage.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (errorMessage.contains('No data found')) {
      return 'No data found for the requested symbol.';
    } else {
      return 'An error occurred: $errorMessage';
    }
  }
}
