import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    self.contentViewController = flutterViewController
    // Room for the navigation beside the page; smaller windows show it as a drawer.
    let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 1440, height: 900)
    let size = NSSize(width: min(1280, screen.width), height: min(860, screen.height))
    self.setFrame(NSRect(origin: NSPoint(x: screen.midX - size.width / 2, y: screen.midY - size.height / 2), size: size), display: true)
    self.minSize = NSSize(width: 480, height: 480)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
