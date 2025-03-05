<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# Oishi

Oishi is a Flutter package that provides a configurable UI framework for building applications with multiple screens and buttons. It simplifies the process of creating a multi-screen application with a consistent look and feel.

## Features

- Configurable screens with customizable icons and titles
- Dynamic button configuration based on conditions
- Integration with WebView for displaying web content
- Support for local storage using shared preferences
- JavaScript bridge for communication between Flutter and WebView

## Installation

Add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  oishi: ^1.0.0
```

Then, run `flutter pub get` to install the package.

## Usage

### Import the necessary packages

```dart
import 'package:oishi/configuration.dart';
import 'package:oishi/oishi.dart';
```

### Define your main application

```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Oishi(
      screens: [
        ScreenConfig(
          endpoint: Endpoint.home,
          icon: 'assets/images/Home.png',
          hoveredIcon: 'assets/images/HomeH.png',
          tabTitle: "الرئيسية",
          pageTitle: "",
        ),
        ScreenConfig(
          endpoint: Endpoint.categories,
          icon: 'assets/images/Categorize.png',
          hoveredIcon: 'assets/images/CategorizeH.png',
          tabTitle: "الاصناف",
          pageTitle: "",
        ),
        ScreenConfig(
          endpoint: Endpoint.brands,
          icon: 'assets/images/Bag.png',
          hoveredIcon: 'assets/images/BagH.png',
          tabTitle: "براندات",
          pageTitle: "",
        ),
        ScreenConfig(
          endpoint: Endpoint.cart,
          icon: 'assets/images/Cart.png',
          hoveredIcon: 'assets/images/CartH.png',
          tabTitle: "العربة",
          pageTitle: "",
        ),
        ScreenConfig(
          endpoint: Endpoint.more,
          icon: 'assets/images/Customer.png',
          hoveredIcon: 'assets/images/CustomerH.png',
          tabTitle: "الحساب",
          pageTitle: "",
        ),
      ],
      buttons: [
        ButtonConfig(
          endpoint: Endpoint.cart,
          icon: Icons.shopping_cart,
          pageTitle: 'cart',
          condition: (pageTitle) =>
              pageTitle == 'products' || pageTitle == 'search',
        ),
        ButtonConfig(
          endpoint: Endpoint.search,
          icon: Icons.search,
          pageTitle: 'search',
          condition: (pageTitle) =>
              pageTitle != 'products' && pageTitle != 'search',
        ),
      ],
    );
  }
}
```

### Configuration

#### ScreenConfig

`ScreenConfig` is used to define the configuration for each screen in the application.

- `endpoint`: The endpoint URL for the screen.
- `icon`: The path to the icon image.
- `hoveredIcon`: The path to the hovered icon image.
- `tabTitle`: The title displayed on the tab.
- `pageTitle`: The title displayed on the page.

#### ButtonConfig

`ButtonConfig` is used to define the configuration for each button in the application.

- `endpoint`: The endpoint URL for the button.
- `icon`: The icon for the button.
- `pageTitle`: The title of the page the button navigates to.
- `condition`: A function that determines whether the button should be displayed based on the current page title.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
