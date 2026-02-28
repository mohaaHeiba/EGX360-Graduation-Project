class NewsSummaryEntity {
  final String summary;
  final int newsCount;
  final DateTime? oldestNewsDate;
  final DateTime? newestNewsDate;
  final List<String> newsIds;

  NewsSummaryEntity({
    required this.summary,
    required this.newsCount,
    this.oldestNewsDate,
    this.newestNewsDate,
    required this.newsIds,
  });

  /// Get a formatted date range string for display
  String getDateRangeText() {
    if (oldestNewsDate == null || newestNewsDate == null) {
      return 'Recent news';
    }

    final oldest = oldestNewsDate!;
    final newest = newestNewsDate!;

    // If same day, just show one date
    if (oldest.year == newest.year &&
        oldest.month == newest.month &&
        oldest.day == newest.day) {
      return _formatDate(newest);
    }

    // Show range
    return '${_formatDate(oldest)} - ${_formatDate(newest)}';
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
