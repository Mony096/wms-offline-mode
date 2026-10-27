import 'package:responsive_sizer/responsive_sizer.dart';

/// Centralized font size configuration using ResponsiveSizer (.sp).
/// You can adjust any font size in this single file to update the entire app.
class AppFontSize {
  /// Increase or decrease this offset to quickly tune all font sizes across the app.
  /// Example:
  ///   AppFontSize.offset = 1.0; // makes everything 1 point bigger
  ///   AppFontSize.offset = 2.0; // makes everything 2 points bigger
  static double offset = 0.0;

  // --- Base Scale (T-Shirt Sizes) ---
  /// Extra small: Micro badges, small tags like BATCH / SERIAL (~11pt)
  static double get xs => (12.5 + offset).sp;

  /// Small: Status badges, chips, row index circles (~12.5pt)
  static double get sm => (13.5 + offset).sp;

  /// Medium: Descriptions, hints, secondary text, table item desc (~13.5pt)
  static double get md => (14 + offset).sp;

  /// Base: Field labels, table column headers, list subtitles (~14.5pt)
  static double get base => (14 + offset).sp;

  /// Large: Field inputs, selector values, table item codes, cell values (~14pt)
  static double get lg => (15.0 + offset).sp;

  /// Extra Large: Highlighted quantities, search inputs (~14.5pt)
  static double get xl => (15.0 + offset).sp;

  /// 2X Large: Card headers, section titles, card title banners (~16.5pt)
  static double get xxl => (15.5 + offset).sp;

  /// Dialog Title: Modal headers and alert dialog titles (~18pt)
  static double get dialogTitle => (17.5 + offset).sp;

  /// AppBar Title: Top navigation bar title (~20pt)
  static double get appBarTitle => (17.5 + offset).sp;

  // --- Semantic Aliases (For clear, self-documenting UI code) ---
  static double get label => base;
  static double get input => (14.5 + offset).sp;
  static double get value => (14.5 + offset).sp;
  static double get hint => md;
  static double get button => (14.8 + offset).sp;
  static double get buttonSmall => (13.8 + offset).sp;
  static double get cardTitle => xxl;
  static double get sectionTitle => xxl;
  static double get badge => sm;
  static double get badgeSmall => xs;
  static double get tableHeader => base;
  static double get tableItemTitle => (14.5 + offset).sp;
  static double get tableItemDesc => (13.0 + offset).sp;
  static double get tableCell => (14.0 + offset).sp;
  static double get detailItemLabel => (13.5 + offset).sp;
  static double get detailItemValue => (13.5 + offset).sp;
}
