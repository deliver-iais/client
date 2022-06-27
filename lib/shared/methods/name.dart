String buildName(String? firstName, String? lastName) {
  return "${(firstName?? "").trim()} ${(lastName ?? "").trim()}".trim();
}
