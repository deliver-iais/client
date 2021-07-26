String buildName(String firstName, String lastName) {
  var res = "";
  if (firstName != null && firstName.isNotEmpty) res += firstName;
  if (lastName != null && lastName.isNotEmpty) res += lastName;
  return res.trim();
}