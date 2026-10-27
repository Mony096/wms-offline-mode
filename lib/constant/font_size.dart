import 'package:responsive_sizer/responsive_sizer.dart';

/// Phone-specific font configuration using ResponsiveSizer (.sp).
class PhoneFontSize {
  /// Fine-tune all phone font sizes by adding/subtracting points.
  static double offset = 0.0;

  // --- Base Scale (T-Shirt Sizes) ---
  static double get xs => (12.5 + AppFontSize.offset + offset).sp;
  static double get sm => (13.5 + AppFontSize.offset + offset).sp;
  static double get md => (14.0 + AppFontSize.offset + offset).sp;
  static double get base => (14.0 + AppFontSize.offset + offset).sp;
  static double get lg => (15.0 + AppFontSize.offset + offset).sp;
  static double get xl => (15.0 + AppFontSize.offset + offset).sp;
  static double get xxl => (15.5 + AppFontSize.offset + offset).sp;
  static double get dialogTitle => (17.5 + AppFontSize.offset + offset).sp;
  static double get appBarTitle => (17.5 + AppFontSize.offset + offset).sp;

  // --- Semantic Aliases ---
  static double get label => base;
  static double get input => (14.5 + AppFontSize.offset + offset).sp;
  static double get value => (14.5 + AppFontSize.offset + offset).sp;
  static double get hint => md;
  static double get button => (14.8 + AppFontSize.offset + offset).sp;
  static double get buttonSmall => (13.8 + AppFontSize.offset + offset).sp;
  static double get cardTitle => xxl;
  static double get sectionTitle => xxl;
  static double get badge => sm;
  static double get badgeSmall => xs;
  static double get tableHeader => base;
  static double get tableItemTitle => (14.5 + AppFontSize.offset + offset).sp;
  static double get tableItemDesc => (13.0 + AppFontSize.offset + offset).sp;
  static double get tableCell => (14.0 + AppFontSize.offset + offset).sp;
  static double get detailItemLabel => (13.5 + AppFontSize.offset + offset).sp;
  static double get detailItemValue => (13.5 + AppFontSize.offset + offset).sp;
}

/// Tablet-specific font configuration using crisp points (dp) to prevent oversized text.
class TabletFontSize {
  /// Fine-tune all tablet font sizes by adding/subtracting points.
  static double offset = 0.0;

  // --- Base Scale (T-Shirt Sizes) for Tablet ---
  /// Extra small: Micro badges, small tags like BATCH / SERIAL (~11pt)
  static double get xs => 11.0 + AppFontSize.offset + offset;

  /// Small: Status badges, chips, row index circles (~12pt)
  static double get sm => 12.0 + AppFontSize.offset + offset;

  /// Medium: Descriptions, hints, secondary text, table item desc (~13pt)
  static double get md => 13.0 + AppFontSize.offset + offset;

  /// Base: Field labels, table column headers, list subtitles (~13.5pt)
  static double get base => 13.5 + AppFontSize.offset + offset;

  /// Large: Field inputs, selector values, table item codes, cell values (~14pt)
  static double get lg => 14.0 + AppFontSize.offset + offset;

  /// Extra Large: Highlighted quantities, search inputs (~15pt)
  static double get xl => 15.0 + AppFontSize.offset + offset;

  /// 2X Large: Card headers, section titles, card title banners (~16pt)
  static double get xxl => 16.0 + AppFontSize.offset + offset;

  /// Dialog Title: Modal headers and alert dialog titles (~17pt)
  static double get dialogTitle => 17.0 + AppFontSize.offset + offset;

  /// AppBar Title: Top navigation bar title (~18pt)
  static double get appBarTitle => 18.0 + AppFontSize.offset + offset;

  // --- Semantic Aliases for Tablet ---
  static double get label => 13.5 + AppFontSize.offset + offset;
  static double get input => 14.0 + AppFontSize.offset + offset;
  static double get value => 14.0 + AppFontSize.offset + offset;
  static double get hint => 13.0 + AppFontSize.offset + offset;
  static double get button => 14.5 + AppFontSize.offset + offset;
  static double get buttonSmall => 13.0 + AppFontSize.offset + offset;
  static double get cardTitle => 16.0 + AppFontSize.offset + offset;
  static double get sectionTitle => 16.0 + AppFontSize.offset + offset;
  static double get badge => 12.0 + AppFontSize.offset + offset;
  static double get badgeSmall => 11.0 + AppFontSize.offset + offset;
  static double get tableHeader => 13.5 + AppFontSize.offset + offset;
  static double get tableItemTitle => 14.0 + AppFontSize.offset + offset;
  static double get tableItemDesc => 12.5 + AppFontSize.offset + offset;
  static double get tableCell => 13.5 + AppFontSize.offset + offset;
  static double get detailItemLabel => 13.0 + AppFontSize.offset + offset;
  static double get detailItemValue => 13.0 + AppFontSize.offset + offset;
}

/// Centralized responsive font size configuration.
/// Automatically detects whether the device is a Phone or Tablet and applies
/// the optimal typography scale for each form factor.
class AppFontSize {
  /// Tablet detection (auto-checks ScreenType and width >= 600).
  static bool get isTablet {
    if (forceTablet != null) return forceTablet!;
    try {
      return Device.screenType == ScreenType.tablet ||
          Device.screenType == ScreenType.desktop ||
          Device.width >= 600;
    } catch (_) {
      return false;
    }
  }

  /// Manually force tablet mode for testing (null = auto-detect).
  static bool? forceTablet;

  /// Global offset applied to all devices (Phone + Tablet).
  static double offset = 0.0;

  /// Shortcut to adjust tablet offset independently.
  static double get tabletOffset => TabletFontSize.offset;
  static set tabletOffset(double val) => TabletFontSize.offset = val;

  /// Shortcut to adjust phone offset independently.
  static double get phoneOffset => PhoneFontSize.offset;
  static set phoneOffset(double val) => PhoneFontSize.offset = val;

  // --- Base Scale (T-Shirt Sizes) - Auto Dispatched ---
  static double get xs => isTablet ? TabletFontSize.xs : PhoneFontSize.xs;
  static double get sm => isTablet ? TabletFontSize.sm : PhoneFontSize.sm;
  static double get md => isTablet ? TabletFontSize.md : PhoneFontSize.md;
  static double get base => isTablet ? TabletFontSize.base : PhoneFontSize.base;
  static double get lg => isTablet ? TabletFontSize.lg : PhoneFontSize.lg;
  static double get xl => isTablet ? TabletFontSize.xl : PhoneFontSize.xl;
  static double get xxl => isTablet ? TabletFontSize.xxl : PhoneFontSize.xxl;
  static double get dialogTitle =>
      isTablet ? TabletFontSize.dialogTitle : PhoneFontSize.dialogTitle;
  static double get appBarTitle =>
      isTablet ? TabletFontSize.appBarTitle : PhoneFontSize.appBarTitle;

  // --- Semantic Aliases - Auto Dispatched ---
  static double get label => isTablet ? TabletFontSize.label : PhoneFontSize.label;
  static double get input => isTablet ? TabletFontSize.input : PhoneFontSize.input;
  static double get value => isTablet ? TabletFontSize.value : PhoneFontSize.value;
  static double get hint => isTablet ? TabletFontSize.hint : PhoneFontSize.hint;
  static double get button => isTablet ? TabletFontSize.button : PhoneFontSize.button;
  static double get buttonSmall =>
      isTablet ? TabletFontSize.buttonSmall : PhoneFontSize.buttonSmall;
  static double get cardTitle =>
      isTablet ? TabletFontSize.cardTitle : PhoneFontSize.cardTitle;
  static double get sectionTitle =>
      isTablet ? TabletFontSize.sectionTitle : PhoneFontSize.sectionTitle;
  static double get badge => isTablet ? TabletFontSize.badge : PhoneFontSize.badge;
  static double get badgeSmall =>
      isTablet ? TabletFontSize.badgeSmall : PhoneFontSize.badgeSmall;
  static double get tableHeader =>
      isTablet ? TabletFontSize.tableHeader : PhoneFontSize.tableHeader;
  static double get tableItemTitle =>
      isTablet ? TabletFontSize.tableItemTitle : PhoneFontSize.tableItemTitle;
  static double get tableItemDesc =>
      isTablet ? TabletFontSize.tableItemDesc : PhoneFontSize.tableItemDesc;
  static double get tableCell =>
      isTablet ? TabletFontSize.tableCell : PhoneFontSize.tableCell;
  static double get detailItemLabel =>
      isTablet ? TabletFontSize.detailItemLabel : PhoneFontSize.detailItemLabel;
  static double get detailItemValue =>
      isTablet ? TabletFontSize.detailItemValue : PhoneFontSize.detailItemValue;
}
