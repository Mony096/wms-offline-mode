String splitDate(String date) {
  return date.split("T")[0];
}
String splitDate2(String date) {
  return date.split(" ")[0];
}
String replaceStringStatus(String word) {
  return word.split("_")[1].toUpperCase() ?? "";
}
