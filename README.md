# Drip Core 💧

**Direct Render Isolated Propagation** — A high-performance, granular reactive state management solution for Flutter.

[![pub package](https://img.shields.io/pub/v/drip.svg)](https://pub.dev/packages/drip_core)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Overview

Drip is designed to solve the "re-render everything" problem in complex Flutter applications. By implementing **Isolated Propagation**, Drip ensures that state changes only trigger renders in the specific sub-widgets that consume that data, bypassing the traditional widget tree rebuilding process where possible.

> [!NOTE]
> This package is currently in early development. API stability is not guaranteed until version 1.0.0.

## Features (Coming Soon)

- 🚀 **Isolated Rendering**: Update deep widget branches without ancestor rebuilds.
- 📉 **Low Overhead**: Minimal boilerplate and memory footprint.
- 🧩 **Sub-widget Scoping**: Easily define state that lives and dies with specific UI segments.
- ⚡ **Zero-Config Reactivity**: Focus on your logic, let Drip handle the propagation.

## Getting Started

Add `drip` to your `pubspec.yaml`:

```yaml
dependencies:
  drip_core: ^0.0.1
```

## Initial Implementation

Currently, Drip is in the architectural phase. The initial release provides the foundation for what will become a robust reactivity engine.

```dart
import 'package:drip_core/drip_core.dart';

void main() {
  // Stay tuned for the first propagation engine release!
}
```

## Additional Information

- **Repository**: [Sam21-39/drip_core](https://github.com/Sam21-39/drip)
- **Issues**: Please file feature requests and bugs at the [issue tracker](https://github.com/Sam21-39/drip/issues).
- **Contribution**: Contributions are welcome! See the repository for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
