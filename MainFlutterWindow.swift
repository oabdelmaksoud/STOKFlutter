// macOS-specific configuration for Stock Options Analyzer
import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    
    // Configure window properties
    self.title = "Stock Options Analyzer"
    self.minSize = NSSize(width: 800, height: 600)
    
    // Enable macOS-specific features
    self.isMovableByWindowBackground = true
    self.titlebarAppearsTransparent = false
    self.titleVisibility = .visible
    self.styleMask.insert(.fullSizeContentView)
    
    RegisterGeneratedPlugins(registry: flutterViewController)
    
    super.awakeFromNib()
  }
}
