String buildName(String? firstName, String? lastName) {
  return "${firstName != null ? firstName.trim() : ""} ${lastName != null ? lastName.trim() : ""}";
}
