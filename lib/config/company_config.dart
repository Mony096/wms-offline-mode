class CompanyConfig {
  /// The current active company for the application.
  /// Change this to 'LK' or 'B1' to toggle company-specific features.
  static String currentCompany = 'LK';

  /// Determines whether the "Product" menu should be displayed on the dashboard.
  /// The LK company requested to hide this menu.
  static bool get showProductMenu {
    if (currentCompany == 'LK') {
      return false;
    }
    return true; // Shown for B1 and other companies
  }
}
