String buildName(String? firstName, String? lastName) {
  var res = "";
  if ( firstName!.isNotEmpty) res += firstName;
  if (lastName!.isNotEmpty) res += lastName;
  return res.trim();
}
