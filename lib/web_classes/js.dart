// ignore_for_file: camel_case_types
class context {
  static dynamic callMethod(String s, List<String?>? r) {}
}

class JS {
  final String? name;

  const JS([this.name]);
}

class _Anonymous {
  const _Anonymous();
}

const anonymous = _Anonymous();

external F allowInterop<F extends Function>(F f);
