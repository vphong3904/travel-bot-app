// lib/admin/shared/models/dashboard_overview.dart

class DashboardKpi {
  final int totalUsers;
  final int newUsersThisPeriod;
  final int totalChatSessions;
  final int totalMessages;
  final double answeredRate;
  final int pendingUnanswered;
  final int pendingFlagged;

  const DashboardKpi({
    required this.totalUsers,
    required this.newUsersThisPeriod,
    required this.totalChatSessions,
    required this.totalMessages,
    required this.answeredRate,
    required this.pendingUnanswered,
    required this.pendingFlagged,
  });

  factory DashboardKpi.fromJson(Map<String, dynamic> json) => DashboardKpi(
        totalUsers: json['total_users'] as int,
        newUsersThisPeriod: json['new_users_this_period'] as int,
        totalChatSessions: json['total_chat_sessions'] as int,
        totalMessages: json['total_messages'] as int,
        answeredRate: (json['answered_rate'] as num).toDouble(),
        pendingUnanswered: json['pending_unanswered'] as int,
        pendingFlagged: json['pending_flagged'] as int,
      );
}

class TimeSeriesPoint {
  final DateTime date;
  final int count;

  const TimeSeriesPoint({required this.date, required this.count});

  factory TimeSeriesPoint.fromJson(Map<String, dynamic> json) =>
      TimeSeriesPoint(
        date: DateTime.parse(json['date'] as String),
        count: json['count'] as int,
      );
}

class TopDestinationItem {
  final String destination;
  final int count;

  const TopDestinationItem({required this.destination, required this.count});

  factory TopDestinationItem.fromJson(Map<String, dynamic> json) =>
      TopDestinationItem(
        destination: json['destination'] as String,
        count: json['count'] as int,
      );
}

class IntentItem {
  final String intent;
  final int count;

  const IntentItem({required this.intent, required this.count});

  factory IntentItem.fromJson(Map<String, dynamic> json) => IntentItem(
        intent: json['intent'] as String,
        count: json['count'] as int,
      );

  String get displayLabel => switch (intent) {
        'find_hotel' => 'Tìm khách sạn',
        'find_restaurant' => 'Tìm nhà hàng',
        'plan_itinerary' => 'Lập lịch trình',
        'find_destination' => 'Tìm điểm đến',
        'ask_faq' => 'Hỏi FAQ',
        'find_transport' => 'Di chuyển',
        _ => intent,
      };
}

class DashboardOverview {
  final String period;
  final DashboardKpi kpi;
  final List<TimeSeriesPoint> usersOverTime;
  final List<TimeSeriesPoint> messagesOverTime;
  final List<TopDestinationItem> topDestinations;
  final List<IntentItem> intentBreakdown;

  const DashboardOverview({
    required this.period,
    required this.kpi,
    required this.usersOverTime,
    required this.messagesOverTime,
    required this.topDestinations,
    required this.intentBreakdown,
  });

  factory DashboardOverview.fromJson(Map<String, dynamic> json) =>
      DashboardOverview(
        period: json['period'] as String,
        kpi: DashboardKpi.fromJson(json['kpi'] as Map<String, dynamic>),
        usersOverTime: (json['users_over_time'] as List)
            .map((e) => TimeSeriesPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        messagesOverTime: (json['messages_over_time'] as List)
            .map((e) => TimeSeriesPoint.fromJson(e as Map<String, dynamic>))
            .toList(),
        topDestinations: (json['top_destinations'] as List)
            .map((e) =>
                TopDestinationItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        intentBreakdown: (json['intent_breakdown'] as List)
            .map((e) => IntentItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
