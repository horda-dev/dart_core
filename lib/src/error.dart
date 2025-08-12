class FluirError extends Error {
  FluirError(this.msg);

  final String msg;

  @override
  String toString() => msg;

  Map<String, dynamic> toJson() {
    return {'msg': msg};
  }
}
