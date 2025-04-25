import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

/// Performance optimization utilities for the Stock Options Analyzer app
class PerformanceOptimizer {
  /// Enable performance overlay for debugging rendering performance
  static void enablePerformanceOverlay(BuildContext context) {
    if (kDebugMode) {
      // This will only work in debug mode
      final OverlayState? overlay = Overlay.of(context);
      if (overlay != null) {
        final OverlayEntry entry = OverlayEntry(
          builder: (BuildContext context) {
            return const PerformanceOverlay.allEnabled();
          },
        );
        overlay.insert(entry);
      }
    }
  }
  
  /// Check if the app is running in debug mode
  static bool isDebugMode() {
    return kDebugMode;
  }
  
  /// Enable rendering debugging
  static void enableDebugRendering() {
    if (kDebugMode) {
      debugPaintSizeEnabled = true;
      debugPaintBaselinesEnabled = true;
      debugPaintLayerBordersEnabled = true;
    }
  }
  
  /// Disable rendering debugging
  static void disableDebugRendering() {
    debugPaintSizeEnabled = false;
    debugPaintBaselinesEnabled = false;
    debugPaintLayerBordersEnabled = false;
  }
  
  /// Log memory usage
  static void logMemoryUsage() {
    if (kDebugMode) {
      final MemoryAllocations? memoryAllocations = MemoryAllocations.instance;
      if (memoryAllocations != null) {
        print('Current memory allocations: ${memoryAllocations.toString()}');
      }
    }
  }
}

/// Mixin for optimizing list views with large datasets
mixin OptimizedListViewMixin<T extends StatefulWidget> on State<T> {
  /// Keep track of visible items to avoid rebuilding off-screen items
  final Map<int, bool> _visibleItems = {};
  
  /// Register an item as visible
  void registerVisibleItem(int index) {
    _visibleItems[index] = true;
  }
  
  /// Unregister an item when it's no longer visible
  void unregisterVisibleItem(int index) {
    _visibleItems.remove(index);
  }
  
  /// Check if an item is currently visible
  bool isItemVisible(int index) {
    return _visibleItems.containsKey(index);
  }
  
  @override
  void dispose() {
    _visibleItems.clear();
    super.dispose();
  }
}

/// Widget that only rebuilds when visible in the viewport
class VisibilityAwareWidget extends StatefulWidget {
  final int index;
  final Widget child;
  final Function(int) onVisible;
  final Function(int) onInvisible;
  
  const VisibilityAwareWidget({
    super.key,
    required this.index,
    required this.child,
    required this.onVisible,
    required this.onInvisible,
  });
  
  @override
  State<VisibilityAwareWidget> createState() => _VisibilityAwareWidgetState();
}

class _VisibilityAwareWidgetState extends State<VisibilityAwareWidget> {
  @override
  void initState() {
    super.initState();
    widget.onVisible(widget.index);
  }
  
  @override
  void dispose() {
    widget.onInvisible(widget.index);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// Extension methods for performance optimization
extension PerformanceOptimizationExtensions on Widget {
  /// Wrap widget with RepaintBoundary to optimize rendering
  Widget withRepaintBoundary() {
    return RepaintBoundary(child: this);
  }
  
  /// Wrap widget with VisibilityAwareWidget for list optimization
  Widget withVisibilityAwareness({
    required int index,
    required Function(int) onVisible,
    required Function(int) onInvisible,
  }) {
    return VisibilityAwareWidget(
      index: index,
      onVisible: onVisible,
      onInvisible: onInvisible,
      child: this,
    );
  }
}

/// Memory-efficient image loading widget
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  
  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width = double.infinity,
    this.height = 200,
    this.fit = BoxFit.cover,
  });
  
  @override
  Widget build(BuildContext context) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) {
          return child;
        }
        return AnimatedOpacity(
          opacity: frame == null ? 0 : 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          child: child,
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Center(
            child: Icon(Icons.error_outline, color: Colors.red),
          ),
        );
      },
      cacheWidth: (width * MediaQuery.of(context).devicePixelRatio).toInt(),
      cacheHeight: (height * MediaQuery.of(context).devicePixelRatio).toInt(),
    ).withRepaintBoundary();
  }
}
