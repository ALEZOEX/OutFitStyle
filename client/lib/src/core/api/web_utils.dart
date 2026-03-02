/// Web-specific utilities for browser operations
library;

import 'package:web/web.dart' as web show window;

/// Reloads the current page (web only)
void reloadPage() {
  web.window.location.reload();
}
