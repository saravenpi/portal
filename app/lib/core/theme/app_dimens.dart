import 'package:flutter/widgets.dart';

abstract final class AppRadii {
  static const BorderRadius none = BorderRadius.zero;
  static const Radius radius = Radius.zero;
  static const RoundedRectangleBorder border = RoundedRectangleBorder(
    borderRadius: none,
  );
}

abstract final class AppSpacing {
  static const double module = 8;
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;
  static const double jumbo = 96;

  static const double hairline = 1;
  static const double minTapTarget = 44;
  static const double controlHeight = 40;
  static const double controlHeightLarge = 48;
}

abstract final class AppLayout {
  static const double maxContentWidth = 1120;
  static const double maxTextMeasure = 640;
  static const double gutter = AppSpacing.md;
  static const double gutterWide = AppSpacing.xxl;
  static const double sidebarWidth = 224;
  static const double breakpointSidebar = 700;
  static const double breakpointWide = 1200;
}
