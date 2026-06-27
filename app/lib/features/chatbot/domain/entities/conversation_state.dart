class ConversationState {
  double? investmentAmount;
  String? riskTolerance;
  DateTime? lastInteractionTime;

  bool get isExpired =>
      lastInteractionTime != null &&
      DateTime.now().difference(lastInteractionTime!).inMinutes >= 5;

  void clear() {
    investmentAmount = null;
    riskTolerance = null;
    lastInteractionTime = null;
  }
}
