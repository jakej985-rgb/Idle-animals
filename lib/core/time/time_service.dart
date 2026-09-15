class TimeService {
  int nowMilliseconds() {
    return DateTime.now().millisecondsSinceEpoch;
  }

  DateTime now() {
    return DateTime.now();
  }
}
