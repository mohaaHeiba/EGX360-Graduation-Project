class AiResponseModel {
  final String action; // "reply_to_user", "fetch_stock_data"
  final String? actionTarget; // e.g., "EAST"
  final String replyText;
  final String uiAction; // e.g., "none", "show_technical_table"

  AiResponseModel({
    required this.action,
    this.actionTarget,
    required this.replyText,
    required this.uiAction,
  });

  factory AiResponseModel.fromJson(Map<String, dynamic> json) {
    var rawTarget = json['actionTarget']?.toString();
    if (rawTarget != null) {
      rawTarget = rawTarget.replaceAll(RegExp(r'[\[\]]'), '').trim();
    }
    return AiResponseModel(
      action: json['action'] ?? 'reply_to_user',
      actionTarget: rawTarget,
      replyText: json['replyText'] ?? '',
      uiAction: json['uiAction'] ?? 'none',
    );
  }
}
