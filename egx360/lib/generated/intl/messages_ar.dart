// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a ar locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'ar';

  static String m0(symbol) => "تم إضافة ${symbol} إلى قائمة المتابعة الخاصة بك";

  static String m1(symbol) => "تم إزالة ${symbol} من قائمة المتابعة الخاصة بك";

  static String m2(count) => "منذ ${count} يوم";

  static String m3(count) => "منذ ${count} ساعة";

  static String m4(count) => "منذ ${count} دقيقة";

  static String m5(name) => "سعر الصرف بين ${name} والجنيه المصري";

  static String m6(email) => "لقد أرسلنا رابط تحقق إلى\n${email}";

  static String m7(symbol, error) => "فشل في إزالة ${symbol}: ${error}";

  static String m8(count) => "${count} شراء";

  static String m9(count) => "${count} محايد";

  static String m10(count) => "${count} بيع";

  static String m11(name) => "أهلاً، ${name}";

  static String m12(p, sd) => "مدة: ${p}، انحراف: ${sd}";

  static String m13(defaultPeriod) =>
      "عدد الشموع المستخدمة في الحساب (الافتراضي: ${defaultPeriod})";

  static String m14(period) => "المدة: ${period}";

  static String m15(defaultStdDev) =>
      "مسافة النطاقات عن خط المنتصف (الافتراضي: ${defaultStdDev}σ)";

  static String m16(balance) => "الرصيد المتاح: ${balance} ج.م";

  static String m17(symbol) => "تم شراء ${symbol} بدون حماية";

  static String m18(total) => "الإجمالي التقديري: ${total} ج.م";

  static String m19(symbol, msg) => "مراقبة ${symbol} — ${msg}";

  static String m20(alert) => "تنبيه فقط عند خسارة ${alert}%";

  static String m21(alert, sell) => "تنبيه: ${alert}% / بيع: ${sell}%";

  static String m22(action) => "تنفيذ أمر ${action}";

  static String m23(symbol) => "هل تريد تفعيل حماية رأس المال لـ ${symbol}؟";

  static String m24(alert) =>
      "تنبيه فقط عند خسارة ${alert}%. لا يوجد بيع تلقائي.";

  static String m25(alert, sell) =>
      "تنبيه عند خسارة ${alert}%، بيع تلقائي عند خسارة ${sell}%.";

  static String m26(qty, symbol) => "تم بيع ${qty} سهم من ${symbol}";

  static String m27(count) => "${count} أسهم";

  static String m28(name) => "رد على ${name}...";

  static String m29(name) => "رد على ${name}";

  static String m30(count) => "عرض ${count} من الردود";

  static String m31(count) => "${count} منشور";

  static String m32(symbol) => "تمت إزالة ${symbol} من قائمة المراقبة";

  static String m33(percent) => "تنبيه عند خسارة ${percent}%";

  static String m34(percent) => "بيع تلقائي عند خسارة ${percent}%";

  static String m35(error) => "فشل في إزالة القاعدة: ${error}";

  static String m36(error) => "فشل في حفظ القاعدة: ${error}";

  static String m37(count) => "المراكز (${count})";

  static String m38(alert, sell) =>
      "الحماية نشطة (تنبيه: ${alert}% / بيع: ${sell}%)";

  static String m39(symbol) => "تمت إزالة الحماية لـ ${symbol}";

  static String m40(symbol) => "تم حفظ قاعدة الحماية لـ ${symbol}";

  static String m41(symbol) => "تم تحديث قاعدة الحماية لـ ${symbol}";

  static String m42(symbol) => "ابدأ المناقشة لـ ${symbol}!";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about_developer": MessageLookupByLibrary.simpleMessage("عن المطور"),
    "about_developer_description": MessageLookupByLibrary.simpleMessage(
      "تم التطوير بواسطة محمد حيبة — طالب هندسة برمجيات متخصص في Flutter وتكامل الذكاء الاصطناعي.",
    ),
    "about_egx": MessageLookupByLibrary.simpleMessage("حول EGX"),
    "about_egx360": MessageLookupByLibrary.simpleMessage("حول EGX360"),
    "about_egx360_description": MessageLookupByLibrary.simpleMessage(
      "EGX360 هو تطبيق محاكاة حديث للبورصة المصرية، يساعد المستخدمين على التعلم والممارسة واستكشاف التداول بأمان بأموال افتراضية.",
    ),
    "about_section": MessageLookupByLibrary.simpleMessage("حول التطبيق"),
    "about_version": MessageLookupByLibrary.simpleMessage("الإصدار 1.0.0"),
    "account_actions_section": MessageLookupByLibrary.simpleMessage(
      "إجراءات الحساب",
    ),
    "account_deleted": MessageLookupByLibrary.simpleMessage("تم حذف الحساب"),
    "account_deleted_message": MessageLookupByLibrary.simpleMessage(
      "تمت إزالة حسابك نهائياً.",
    ),
    "account_deletion_failed": MessageLookupByLibrary.simpleMessage(
      "فشل حذف الحساب.",
    ),
    "account_section": MessageLookupByLibrary.simpleMessage("الحساب"),
    "active_sessions": MessageLookupByLibrary.simpleMessage("الجلسات النشطة"),
    "active_sessions_description": MessageLookupByLibrary.simpleMessage(
      "حسابك نشط حالياً على هذا الجهاز فقط.",
    ),
    "active_sessions_subtitle": MessageLookupByLibrary.simpleMessage(
      "عرض الأماكن التي تم تسجيل الدخول فيها حالياً",
    ),
    "ai_news_summary": MessageLookupByLibrary.simpleMessage(
      "ملخص الأخبار الذكية",
    ),
    "alert_summry": MessageLookupByLibrary.simpleMessage(
      "تم توليد هذا الملخص باستخدام الذكاء الاصطناعي ولا يُعد مصدرًا رسميًا للمعلومات.",
    ),
    "all_alerts_muted": MessageLookupByLibrary.simpleMessage(
      "تم كتم جميع التنبيهات داخل التطبيق",
    ),
    "allow_notifications": MessageLookupByLibrary.simpleMessage(
      "السماح بالإشعارات",
    ),
    "appTitle": MessageLookupByLibrary.simpleMessage("EGX360"),
    "app_details_section": MessageLookupByLibrary.simpleMessage(
      "تفاصيل التطبيق",
    ),
    "app_updates": MessageLookupByLibrary.simpleMessage("تحديثات التطبيق"),
    "app_updates_subtitle": MessageLookupByLibrary.simpleMessage(
      "الميزات والإصدارات الجديدة",
    ),
    "app_version": MessageLookupByLibrary.simpleMessage("إصدار التطبيق"),
    "app_version_number": MessageLookupByLibrary.simpleMessage("1.0.0 (بيتا)"),
    "apply_language": MessageLookupByLibrary.simpleMessage("تطبيق اللغة"),
    "arabic": MessageLookupByLibrary.simpleMessage("العربية"),
    "articles_analyzed": MessageLookupByLibrary.simpleMessage(
      "مقالات تم تحليلها",
    ),
    "asset_details_about": MessageLookupByLibrary.simpleMessage("عن الشركة"),
    "asset_details_ai_generated": MessageLookupByLibrary.simpleMessage(
      "تم إنشاؤه بواسطة الذكاء الاصطناعي",
    ),
    "asset_details_ai_summary": MessageLookupByLibrary.simpleMessage(
      "ملخص الذكاء الاصطناعي",
    ),
    "asset_details_ai_summary_title": MessageLookupByLibrary.simpleMessage(
      "ملخص أخبار الذكاء الاصطناعي",
    ),
    "asset_details_arabic_name": MessageLookupByLibrary.simpleMessage(
      "الاسم بالعربية",
    ),
    "asset_details_avg_volume": MessageLookupByLibrary.simpleMessage(
      "متوسط الحجم",
    ),
    "asset_details_back_news": MessageLookupByLibrary.simpleMessage(
      "العودة إلى قائمة الأخبار",
    ),
    "asset_details_company_profile": MessageLookupByLibrary.simpleMessage(
      "ملف الشركة",
    ),
    "asset_details_constituents": MessageLookupByLibrary.simpleMessage(
      "المكونات",
    ),
    "asset_details_egp": MessageLookupByLibrary.simpleMessage("ج.م"),
    "asset_details_error_load_crypto_hist":
        MessageLookupByLibrary.simpleMessage(
          "خطأ في جلب البيانات التاريخية للعملة",
        ),
    "asset_details_error_load_gauge": MessageLookupByLibrary.simpleMessage(
      "خطأ في جلب بيانات مؤشر القوة",
    ),
    "asset_details_error_load_material": MessageLookupByLibrary.simpleMessage(
      "خطأ في جلب أسعار المعادن",
    ),
    "asset_details_error_load_stock_candles":
        MessageLookupByLibrary.simpleMessage("خطأ في جلب بيانات الشموع للسهم"),
    "asset_details_error_load_ticker": MessageLookupByLibrary.simpleMessage(
      "خطأ في جلب بيانات الـ 24 ساعة",
    ),
    "asset_details_error_update_stock_candles":
        MessageLookupByLibrary.simpleMessage("خطأ في تحديث بيانات الشموع"),
    "asset_details_gold_18k": MessageLookupByLibrary.simpleMessage(
      "ذهب عيار 18",
    ),
    "asset_details_gold_21k": MessageLookupByLibrary.simpleMessage(
      "ذهب عيار 21",
    ),
    "asset_details_gold_24k": MessageLookupByLibrary.simpleMessage(
      "ذهب عيار 24",
    ),
    "asset_details_gold_bar_100g": MessageLookupByLibrary.simpleMessage(
      "سبيكة ذهب 100 جرام",
    ),
    "asset_details_gold_bar_250g": MessageLookupByLibrary.simpleMessage(
      "سبيكة ذهب 250 جرام",
    ),
    "asset_details_gold_bar_50g": MessageLookupByLibrary.simpleMessage(
      "سبيكة ذهب 50 جرام",
    ),
    "asset_details_gold_ounce": MessageLookupByLibrary.simpleMessage(
      "أوقية الذهب",
    ),
    "asset_details_gold_pound": MessageLookupByLibrary.simpleMessage(
      "الجنيه الذهب",
    ),
    "asset_details_high": MessageLookupByLibrary.simpleMessage("أعلى سعر"),
    "asset_details_index_label": MessageLookupByLibrary.simpleMessage(
      "EGX • مؤشر",
    ),
    "asset_details_isin_code": MessageLookupByLibrary.simpleMessage("كود ISIN"),
    "asset_details_key_stats": MessageLookupByLibrary.simpleMessage(
      "إحصائيات رئيسية",
    ),
    "asset_details_latest_news": MessageLookupByLibrary.simpleMessage(
      "آخر الأخبار",
    ),
    "asset_details_listing_date": MessageLookupByLibrary.simpleMessage(
      "تاريخ الإدراج",
    ),
    "asset_details_local_prices": MessageLookupByLibrary.simpleMessage(
      "الأسعار المحلية (ج.م)",
    ),
    "asset_details_low": MessageLookupByLibrary.simpleMessage("أدنى سعر"),
    "asset_details_market_data": MessageLookupByLibrary.simpleMessage(
      "بيانات السوق",
    ),
    "asset_details_mkt_cap": MessageLookupByLibrary.simpleMessage(
      "القيمة السوقية",
    ),
    "asset_details_news_fail": MessageLookupByLibrary.simpleMessage(
      "فشل التلخيص",
    ),
    "asset_details_news_fail_msg": MessageLookupByLibrary.simpleMessage(
      "فشل إنشاء الملخص. يرجى المحاولة مرة أخرى لاحقاً.",
    ),
    "asset_details_news_insufficient": MessageLookupByLibrary.simpleMessage(
      "أخبار غير كافية",
    ),
    "asset_details_news_insufficient_msg": MessageLookupByLibrary.simpleMessage(
      "لا توجد أخبار كافية لإنشاء ملخص مفيد. مطلوب 3 مقالات على الأقل.",
    ),
    "asset_details_news_no_news": MessageLookupByLibrary.simpleMessage(
      "لا توجد أخبار",
    ),
    "asset_details_news_no_news_msg": MessageLookupByLibrary.simpleMessage(
      "لا توجد أخبار متاحة لهذا الأصل لتلخيصها.",
    ),
    "asset_details_no_chart_data": MessageLookupByLibrary.simpleMessage(
      "لا توجد بيانات متاحة",
    ),
    "asset_details_no_description": MessageLookupByLibrary.simpleMessage(
      "لا يوجد وصف متاح لهذا الأصل حالياً.",
    ),
    "asset_details_no_news_available": MessageLookupByLibrary.simpleMessage(
      "لا توجد أخبار متاحة لهذا الأصل",
    ),
    "asset_details_no_posts": MessageLookupByLibrary.simpleMessage(
      "لا توجد منشورات لهذا السهم بعد",
    ),
    "asset_details_open": MessageLookupByLibrary.simpleMessage("الافتتاح"),
    "asset_details_performance": MessageLookupByLibrary.simpleMessage("الأداء"),
    "asset_details_post_like_error": MessageLookupByLibrary.simpleMessage(
      "تعذر الإعجاب بالمنشور",
    ),
    "asset_details_post_save_error": MessageLookupByLibrary.simpleMessage(
      "تعذر حفظ المنشور",
    ),
    "asset_details_prev_close": MessageLookupByLibrary.simpleMessage(
      "الإغلاق السابق",
    ),
    "asset_details_read_full": MessageLookupByLibrary.simpleMessage(
      "قراءة المقال كاملاً",
    ),
    "asset_details_silver_925": MessageLookupByLibrary.simpleMessage(
      "فضة عيار 925",
    ),
    "asset_details_silver_999": MessageLookupByLibrary.simpleMessage(
      "فضة عيار 999",
    ),
    "asset_details_stock_label": MessageLookupByLibrary.simpleMessage(
      "EGX • سهم",
    ),
    "asset_details_summarizing": MessageLookupByLibrary.simpleMessage(
      "جاري التلخيص...",
    ),
    "asset_details_tab_community": MessageLookupByLibrary.simpleMessage(
      "المجتمع",
    ),
    "asset_details_tab_live_chat": MessageLookupByLibrary.simpleMessage(
      "دردشة مباشرة",
    ),
    "asset_details_tab_news": MessageLookupByLibrary.simpleMessage("الأخبار"),
    "asset_details_tab_overview": MessageLookupByLibrary.simpleMessage(
      "نظرة عامة",
    ),
    "asset_details_technicals": MessageLookupByLibrary.simpleMessage(
      "التحليلات الفنية",
    ),
    "asset_details_usd": MessageLookupByLibrary.simpleMessage("دولار"),
    "asset_details_volatility": MessageLookupByLibrary.simpleMessage("التذبذب"),
    "asset_details_volume": MessageLookupByLibrary.simpleMessage("حجم التداول"),
    "asset_details_watchlist_added": MessageLookupByLibrary.simpleMessage(
      "تمت الإضافة للمفضلة",
    ),
    "asset_details_watchlist_added_msg": m0,
    "asset_details_watchlist_error": MessageLookupByLibrary.simpleMessage(
      "عذراً، تعذر تحديث قائمة المتابعة",
    ),
    "asset_details_watchlist_removed": MessageLookupByLibrary.simpleMessage(
      "تمت الإزالة من المفضلة",
    ),
    "asset_details_watchlist_removed_msg": m1,
    "asset_details_website": MessageLookupByLibrary.simpleMessage(
      "الموقع الإلكتروني",
    ),
    "auth_sign_in": MessageLookupByLibrary.simpleMessage("تسجيل الدخول"),
    "auth_sign_up": MessageLookupByLibrary.simpleMessage("إنشاء حساب"),
    "bio": MessageLookupByLibrary.simpleMessage("النبذة التعريفية"),
    "bio_hint": MessageLookupByLibrary.simpleMessage(
      "أخبرنا قليلاً عن نفسك...",
    ),
    "button_cancel": MessageLookupByLibrary.simpleMessage("إلغاء"),
    "button_ok": MessageLookupByLibrary.simpleMessage("موافق"),
    "button_retry": MessageLookupByLibrary.simpleMessage("إعادة المحاولة"),
    "button_submit": MessageLookupByLibrary.simpleMessage("إرسال"),
    "categories_section": MessageLookupByLibrary.simpleMessage("الفئات"),
    "change_password": MessageLookupByLibrary.simpleMessage(
      "تغيير كلمة المرور",
    ),
    "change_password_subtitle": MessageLookupByLibrary.simpleMessage(
      "تحديث كلمة مرور حسابك",
    ),
    "change_password_title": MessageLookupByLibrary.simpleMessage(
      "تغيير كلمة المرور",
    ),
    "chart_candlestick": MessageLookupByLibrary.simpleMessage("شموع"),
    "chart_header_no_results": MessageLookupByLibrary.simpleMessage(
      "لا توجد نتائج",
    ),
    "chart_header_search_hint": MessageLookupByLibrary.simpleMessage("بحث..."),
    "chart_header_select": MessageLookupByLibrary.simpleMessage("اختر"),
    "chart_header_select_crypto": MessageLookupByLibrary.simpleMessage(
      "اختر العملة",
    ),
    "chart_header_toggle_watchlist": MessageLookupByLibrary.simpleMessage(
      "تبديل قائمة المراقبة",
    ),
    "chart_line": MessageLookupByLibrary.simpleMessage("خطي"),
    "chart_loading": MessageLookupByLibrary.simpleMessage(
      "جار تحميل الرسم البياني...",
    ),
    "chart_type_bars": MessageLookupByLibrary.simpleMessage("الأعمدة"),
    "chart_type_bars_desc": MessageLookupByLibrary.simpleMessage(
      "رسم بياني للأعمدة OHLC",
    ),
    "chart_type_candles": MessageLookupByLibrary.simpleMessage("الشموع"),
    "chart_type_candles_desc": MessageLookupByLibrary.simpleMessage(
      "رسم بياني للشموع التقليدية",
    ),
    "chart_type_heikin_ashi": MessageLookupByLibrary.simpleMessage("هيكين آشي"),
    "chart_type_heikin_ashi_desc": MessageLookupByLibrary.simpleMessage(
      "شموع اتجاه منقحة",
    ),
    "chart_type_line": MessageLookupByLibrary.simpleMessage("خط"),
    "chart_type_line_desc": MessageLookupByLibrary.simpleMessage(
      "رسم بياني خطي بسيط",
    ),
    "chart_type_menu_title": MessageLookupByLibrary.simpleMessage(
      "نوع الرسم البياني",
    ),
    "chart_type_renko": MessageLookupByLibrary.simpleMessage("رينكو"),
    "chart_type_renko_desc": MessageLookupByLibrary.simpleMessage(
      "رسم بياني يعتمد على الطوب",
    ),
    "check_internet_connection": MessageLookupByLibrary.simpleMessage(
      "يرجى التحقق من اتصالك بالإنترنت.",
    ),
    "choose_theme": MessageLookupByLibrary.simpleMessage(
      "اختر المظهر المفضل لديك",
    ),
    "community_all": MessageLookupByLibrary.simpleMessage("الكل"),
    "community_all_feeds": MessageLookupByLibrary.simpleMessage("كل المنشورات"),
    "community_bearish": MessageLookupByLibrary.simpleMessage("متشائم"),
    "community_bullish": MessageLookupByLibrary.simpleMessage("متفائل"),
    "community_communities": MessageLookupByLibrary.simpleMessage("المجتمعات"),
    "community_follow": MessageLookupByLibrary.simpleMessage("متابعة"),
    "community_followers": MessageLookupByLibrary.simpleMessage("المتابعين"),
    "community_following": MessageLookupByLibrary.simpleMessage("يتابع"),
    "community_just_now": MessageLookupByLibrary.simpleMessage("الآن"),
    "community_like_failed": MessageLookupByLibrary.simpleMessage(
      "تعذر الإعجاب بالمنشور",
    ),
    "community_login_to_bookmark": MessageLookupByLibrary.simpleMessage(
      "يرجى تسجيل الدخول لحفظ المنشورات",
    ),
    "community_login_to_like": MessageLookupByLibrary.simpleMessage(
      "يرجى تسجيل الدخول للإعجاب بالمنشورات",
    ),
    "community_no_posts": MessageLookupByLibrary.simpleMessage(
      "لا توجد منشورات بعد",
    ),
    "community_posts": MessageLookupByLibrary.simpleMessage("المنشورات"),
    "community_save_failed": MessageLookupByLibrary.simpleMessage(
      "تعذر حفظ المنشور",
    ),
    "community_time_ago_days": m2,
    "community_time_ago_hours": m3,
    "community_time_ago_minutes": m4,
    "community_title": MessageLookupByLibrary.simpleMessage("المجتمع"),
    "community_trending_topics": MessageLookupByLibrary.simpleMessage(
      "المواضيع الرائجة",
    ),
    "community_user": MessageLookupByLibrary.simpleMessage("مستخدم"),
    "community_who_to_follow": MessageLookupByLibrary.simpleMessage(
      "اقتراحات المتابعة",
    ),
    "confirmPassword": MessageLookupByLibrary.simpleMessage(
      "يرجى تأكيد كلمة المرور.",
    ),
    "confirm_logout": MessageLookupByLibrary.simpleMessage(
      "تأكيد تسجيل الخروج",
    ),
    "confirm_logout_message": MessageLookupByLibrary.simpleMessage(
      "هل أنت متأكد من رغبتك في تسجيل الخروج؟",
    ),
    "contact_report": MessageLookupByLibrary.simpleMessage(
      "التواصل والإبلاغ عن مشكلة",
    ),
    "contact_report_subtitle": MessageLookupByLibrary.simpleMessage(
      "أرسل لنا بريدًا إلكترونيًا إذا كنت بحاجة إلى مساعدة أو وجدت مشكلة.",
    ),
    "continue_with": MessageLookupByLibrary.simpleMessage(
      "أو المتابعة باستخدام",
    ),
    "copyright": MessageLookupByLibrary.simpleMessage(
      "© 2025 تطبيق EGX. جميع الحقوق محفوظة.",
    ),
    "copyright_notice": MessageLookupByLibrary.simpleMessage(
      "© 2025 EGX360. جميع الحقوق محفوظة.\nمبني باستخدام Flutter و Firebase.",
    ),
    "create_account": MessageLookupByLibrary.simpleMessage("إنشاء حساب جديد"),
    "create_password_confirm_new": MessageLookupByLibrary.simpleMessage(
      "تأكيد كلمة المرور الجديدة",
    ),
    "create_password_description": MessageLookupByLibrary.simpleMessage(
      "قم بتعيين كلمة مرور قوية جديدة لتأمين حسابك.",
    ),
    "create_password_new": MessageLookupByLibrary.simpleMessage(
      "كلمة المرور الجديدة",
    ),
    "create_password_remember": MessageLookupByLibrary.simpleMessage(
      "تذكرت كلمة المرور؟ ",
    ),
    "create_password_title": MessageLookupByLibrary.simpleMessage(
      "إنشاء كلمة مرور جديدة",
    ),
    "create_password_update_button": MessageLookupByLibrary.simpleMessage(
      "تحديث كلمة المرور",
    ),
    "currency_desc": m5,
    "currency_sector": MessageLookupByLibrary.simpleMessage("عملة"),
    "current_password": MessageLookupByLibrary.simpleMessage(
      "كلمة المرور الحالية",
    ),
    "current_session_section": MessageLookupByLibrary.simpleMessage(
      "الجلسة الحالية",
    ),
    "dark": MessageLookupByLibrary.simpleMessage("داكن"),
    "dark_mode": MessageLookupByLibrary.simpleMessage("الوضع الداكن"),
    "data_source_1_content": MessageLookupByLibrary.simpleMessage(
      "نحصل على أسعار الأسهم الفورية والمؤشرات وأحجام التداول من TradingView عبر TDV ونقوم بتخزينها بشكل آمن في السحابة للوصول السريع.",
    ),
    "data_source_1_title": MessageLookupByLibrary.simpleMessage(
      "1. TradingView (TDV)",
    ),
    "data_source_2_content": MessageLookupByLibrary.simpleMessage(
      "نستخرج أسعار الذهب المحلية من مصادر موثوقة لتوفير أسعار دقيقة ومحدثة للمستثمرين.",
    ),
    "data_source_2_title": MessageLookupByLibrary.simpleMessage(
      "2. أسعار الذهب المحلية",
    ),
    "data_source_3_content": MessageLookupByLibrary.simpleMessage(
      "الوصول إلى بيانات الأسهم والمؤشرات السابقة للتحليل والرسوم البيانية والاختبار الخلفي.",
    ),
    "data_source_3_title": MessageLookupByLibrary.simpleMessage(
      "3. بيانات السوق التاريخية",
    ),
    "data_source_4_content": MessageLookupByLibrary.simpleMessage(
      "أخبار مجمعة من منافذ مالية واقتصادية معتمدة لإبقائك على اطلاع بأحداث السوق.",
    ),
    "data_source_4_title": MessageLookupByLibrary.simpleMessage(
      "4. الأخبار المالية",
    ),
    "data_source_5_content": MessageLookupByLibrary.simpleMessage(
      "عمليات التكامل مع واجهات برمجة التطبيقات الموثوقة توفر التحليلات والرسوم البيانية ومعلومات السوق الإضافية.",
    ),
    "data_source_5_title": MessageLookupByLibrary.simpleMessage(
      "5. واجهات برمجة التطبيقات الخارجية",
    ),
    "data_sources": MessageLookupByLibrary.simpleMessage("مصادر البيانات"),
    "data_sources_description": MessageLookupByLibrary.simpleMessage(
      "افهم من أين يحصل EGX360 على بيانات السوق.",
    ),
    "data_sources_intro": MessageLookupByLibrary.simpleMessage(
      "يجمع EGX360 البيانات من مصادر موثوقة وموثوقة لتوفير رؤى دقيقة للسوق.",
    ),
    "data_sources_page_title": MessageLookupByLibrary.simpleMessage(
      "مصادر البيانات",
    ),
    "data_sources_subtitle": MessageLookupByLibrary.simpleMessage(
      "افهم من أين يحصل EGX360 على بيانات السوق.",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("حذف"),
    "delete_account": MessageLookupByLibrary.simpleMessage("حذف الحساب"),
    "delete_account_confirm": MessageLookupByLibrary.simpleMessage(
      "هل أنت متأكد من رغبتك في حذف حسابك نهائياً؟ لا يمكن التراجع عن هذا الإجراء.",
    ),
    "delete_account_subtitle": MessageLookupByLibrary.simpleMessage(
      "إزالة بياناتك وحسابك نهائياً",
    ),
    "delete_action": MessageLookupByLibrary.simpleMessage("حذف"),
    "details_asset_fallback": MessageLookupByLibrary.simpleMessage("أصل"),
    "details_avg_volume_30d": MessageLookupByLibrary.simpleMessage(
      "متوسط حجم التداول (30 يوم)",
    ),
    "details_circulating_supply": MessageLookupByLibrary.simpleMessage(
      "المعروض المتداول",
    ),
    "details_fully_diluted_mc": MessageLookupByLibrary.simpleMessage(
      "القيمة السوقية المخففة بالكامل",
    ),
    "details_key_stats": MessageLookupByLibrary.simpleMessage(
      "الإحصائيات الرئيسية",
    ),
    "details_market_cap": MessageLookupByLibrary.simpleMessage(
      "القيمة السوقية",
    ),
    "details_market_closed": MessageLookupByLibrary.simpleMessage("السوق مغلق"),
    "details_market_open": MessageLookupByLibrary.simpleMessage("السوق مفتوح"),
    "details_no_asset": MessageLookupByLibrary.simpleMessage(
      "لم يتم اختيار أصل",
    ),
    "details_seasonals": MessageLookupByLibrary.simpleMessage("الموسمية"),
    "details_spot": MessageLookupByLibrary.simpleMessage("فوري"),
    "details_technicals": MessageLookupByLibrary.simpleMessage(
      "التحليلات الفنية",
    ),
    "details_vol_mc_ratio": MessageLookupByLibrary.simpleMessage(
      "الحجم / القيمة السوقية",
    ),
    "details_volume": MessageLookupByLibrary.simpleMessage("حجم التداول"),
    "details_volume_24h": MessageLookupByLibrary.simpleMessage(
      "حجم التداول خلال 24 ساعة",
    ),
    "disable_notifications_message": MessageLookupByLibrary.simpleMessage(
      "يرجى تعطيل الإشعارات من إعدادات النظام.",
    ),
    "drawing_tools_clear_all": MessageLookupByLibrary.simpleMessage("مسح الكل"),
    "drawing_tools_color": MessageLookupByLibrary.simpleMessage("اللون"),
    "drawing_tools_done": MessageLookupByLibrary.simpleMessage("تم"),
    "drawing_tools_edit_title": MessageLookupByLibrary.simpleMessage(
      "تعديل الرسم",
    ),
    "drawing_tools_h_line": MessageLookupByLibrary.simpleMessage("خط أفقي"),
    "drawing_tools_line": MessageLookupByLibrary.simpleMessage("خط"),
    "drawing_tools_preview": MessageLookupByLibrary.simpleMessage("معاينة"),
    "drawing_tools_px": MessageLookupByLibrary.simpleMessage("بكسل"),
    "drawing_tools_rect": MessageLookupByLibrary.simpleMessage("مستطيل"),
    "drawing_tools_select_tool": MessageLookupByLibrary.simpleMessage(
      "اختر الأداة",
    ),
    "drawing_tools_title": MessageLookupByLibrary.simpleMessage("أدوات الرسم"),
    "drawing_tools_v_line": MessageLookupByLibrary.simpleMessage("خط رأسي"),
    "drawing_tools_width": MessageLookupByLibrary.simpleMessage("السمك"),
    "edit_profile": MessageLookupByLibrary.simpleMessage("تعديل الملف الشخصي"),
    "edit_profile_subtitle": MessageLookupByLibrary.simpleMessage(
      "غير اسمك، صورتك، نبذتك التعريفية",
    ),
    "egx360_app_name": MessageLookupByLibrary.simpleMessage("EGX360"),
    "email_address": MessageLookupByLibrary.simpleMessage(
      "عنوان البريد الإلكتروني",
    ),
    "email_label": MessageLookupByLibrary.simpleMessage("البريد الإلكتروني"),
    "email_verification_message": MessageLookupByLibrary.simpleMessage(
      "يرجى التحقق من بريدك الإلكتروني للمتابعة...",
    ),
    "email_verification_sent": m6,
    "email_verified_message": MessageLookupByLibrary.simpleMessage(
      "تم توثيق حسابك بنجاح، يمكنك الآن استخدام كافة مميزات التطبيق.",
    ),
    "email_verified_success": MessageLookupByLibrary.simpleMessage(
      "تم تأكيد البريد!!",
    ),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "enterEmail": MessageLookupByLibrary.simpleMessage(
      "يرجى إدخال عنوان بريدك الإلكتروني.",
    ),
    "enterName": MessageLookupByLibrary.simpleMessage("يرجى إدخال اسمك."),
    "enterPassword": MessageLookupByLibrary.simpleMessage(
      "يرجى إدخال كلمة المرور.",
    ),
    "error_auth_failed_msg": MessageLookupByLibrary.simpleMessage(
      "فشل إكمال تسجيل الدخول. يرجى المحاولة مرة أخرى.",
    ),
    "error_auth_title": MessageLookupByLibrary.simpleMessage("خطأ في المصادقة"),
    "error_check_connection_msg": MessageLookupByLibrary.simpleMessage(
      "يرجى التحقق من اتصالك بالإنترنت.",
    ),
    "error_current_password_incorrect_msg":
        MessageLookupByLibrary.simpleMessage(
          "كلمة المرور الحالية التي أدخلتها غير صحيحة.",
        ),
    "error_deletion_failed_title": MessageLookupByLibrary.simpleMessage(
      "فشل الحذف",
    ),
    "error_email_already_in_use_msg": MessageLookupByLibrary.simpleMessage(
      "هذا البريد الإلكتروني مستخدم بالفعل.",
    ),
    "error_email_already_registered_title":
        MessageLookupByLibrary.simpleMessage("البريد مسجل مسبقاً"),
    "error_failed_change_password_msg": MessageLookupByLibrary.simpleMessage(
      "فشل تغيير كلمة المرور.",
    ),
    "error_google_cancelled_msg": MessageLookupByLibrary.simpleMessage(
      "تم إلغاء تسجيل الدخول عبر Google من قبلك.",
    ),
    "error_google_cancelled_title": MessageLookupByLibrary.simpleMessage(
      "تم الإلغاء",
    ),
    "error_incorrect_email_pass_msg": MessageLookupByLibrary.simpleMessage(
      "البريد الإلكتروني أو كلمة المرور غير صحيحة.",
    ),
    "error_invalid_credentials_title": MessageLookupByLibrary.simpleMessage(
      "بيانات غير صحيحة",
    ),
    "error_invalid_email": MessageLookupByLibrary.simpleMessage(
      "يرجى إدخال عنوان بريد إلكتروني صالح.",
    ),
    "error_invalid_password_title": MessageLookupByLibrary.simpleMessage(
      "كلمة مرور خاطئة",
    ),
    "error_label": MessageLookupByLibrary.simpleMessage("خطأ"),
    "error_loading_licenses": MessageLookupByLibrary.simpleMessage(
      "خطأ في تحميل التراخيص",
    ),
    "error_logout_failed_title": MessageLookupByLibrary.simpleMessage(
      "فشل تسجيل الخروج",
    ),
    "error_network": MessageLookupByLibrary.simpleMessage(
      "خطأ في الشبكة، يرجى المحاولة مرة أخرى.",
    ),
    "error_no_account_found_msg": MessageLookupByLibrary.simpleMessage(
      "لم يتم العثور على حساب بهذا البريد الإلكتروني.",
    ),
    "error_no_connection_title": MessageLookupByLibrary.simpleMessage(
      "لا يوجد اتصال",
    ),
    "error_password_too_short": MessageLookupByLibrary.simpleMessage(
      "يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.",
    ),
    "error_required_field": MessageLookupByLibrary.simpleMessage(
      "هذا الحقل مطلوب.",
    ),
    "error_signin_title": MessageLookupByLibrary.simpleMessage("خطأ في الدخول"),
    "error_signup_title": MessageLookupByLibrary.simpleMessage(
      "خطأ في التسجيل",
    ),
    "error_something_wrong_msg": MessageLookupByLibrary.simpleMessage(
      "حدث خطأ ما.",
    ),
    "error_unexpected_title": MessageLookupByLibrary.simpleMessage(
      "خطأ غير متوقع",
    ),
    "error_user_not_found_title": MessageLookupByLibrary.simpleMessage(
      "المستخدم غير موجود",
    ),
    "eur_label": MessageLookupByLibrary.simpleMessage("يورو"),
    "failed_mark_all_read": MessageLookupByLibrary.simpleMessage(
      "فشل في تحديد الكل كمقروء",
    ),
    "failed_to_change_password": MessageLookupByLibrary.simpleMessage(
      "فشل تغيير كلمة المرور.",
    ),
    "failed_to_load_data": MessageLookupByLibrary.simpleMessage(
      "فشل في تحميل البيانات",
    ),
    "failed_to_load_notifications": MessageLookupByLibrary.simpleMessage(
      "فشل في تحميل الإشعارات",
    ),
    "failed_to_load_watchlist": MessageLookupByLibrary.simpleMessage(
      "فشل في تحميل قائمة المراقبة كاملة",
    ),
    "failed_to_refresh_data": MessageLookupByLibrary.simpleMessage(
      "فشل في تحديث البيانات",
    ),
    "failed_to_remove_from_watchlist_msg": m7,
    "failed_to_update_image": MessageLookupByLibrary.simpleMessage(
      "فشل تحديث الصورة.",
    ),
    "faqs_section": MessageLookupByLibrary.simpleMessage("الأسئلة الشائعة"),
    "forgot_description": MessageLookupByLibrary.simpleMessage(
      "أدخل بريدك الإلكتروني أدناه وسنرسل لك رابطاً لإعادة تعيين كلمة المرور.",
    ),
    "forgot_loading": MessageLookupByLibrary.simpleMessage("جار الإرسال..."),
    "forgot_password": MessageLookupByLibrary.simpleMessage(
      "نسيت كلمة المرور؟",
    ),
    "forgot_remember": MessageLookupByLibrary.simpleMessage(
      "تذكرت كلمة المرور؟ ",
    ),
    "forgot_send_link": MessageLookupByLibrary.simpleMessage(
      "إرسال رابط إعادة التعيين",
    ),
    "full_name": MessageLookupByLibrary.simpleMessage("الاسم الكامل"),
    "full_name_hint": MessageLookupByLibrary.simpleMessage("أدخل اسمك الكامل"),
    "gauge_bollinger_desc": MessageLookupByLibrary.simpleMessage(
      "إشارة شراء بولينجر باند (السعر عند النطاق السفلي + مؤشر القوة النسبية متشبع بالبيع)",
    ),
    "gauge_buy": MessageLookupByLibrary.simpleMessage("شراء"),
    "gauge_buy_count": m8,
    "gauge_neutral": MessageLookupByLibrary.simpleMessage("محايد"),
    "gauge_neutral_count": m9,
    "gauge_oscillators": MessageLookupByLibrary.simpleMessage("المذبذبات"),
    "gauge_sell": MessageLookupByLibrary.simpleMessage("بيع"),
    "gauge_sell_count": m10,
    "gauge_strong_buy": MessageLookupByLibrary.simpleMessage("شراء قوي"),
    "gauge_strong_sell": MessageLookupByLibrary.simpleMessage("بيع قوي"),
    "gauge_trend_ma": MessageLookupByLibrary.simpleMessage(
      "الاتجاه (المتوسطات المتحركة)",
    ),
    "gbp_label": MessageLookupByLibrary.simpleMessage("جنيه إسترليني"),
    "general_section": MessageLookupByLibrary.simpleMessage("عام"),
    "get_started": MessageLookupByLibrary.simpleMessage("ابدأ الآن"),
    "gold_21k_desc": MessageLookupByLibrary.simpleMessage(
      "سعر الذهب عيار 21 بالجنيه المصري",
    ),
    "gold_21k_title": MessageLookupByLibrary.simpleMessage("ذهب عيار 21"),
    "help_support": MessageLookupByLibrary.simpleMessage("المساعدة والدعم"),
    "home_greeting": m11,
    "home_title": MessageLookupByLibrary.simpleMessage("الرئيسية"),
    "how_to_step_1_content": MessageLookupByLibrary.simpleMessage(
      "تنقل عبر المؤشرات والقطاعات والأسهم باستخدام القائمة السفلية وشريط البحث.",
    ),
    "how_to_step_1_title": MessageLookupByLibrary.simpleMessage(
      "1. استكشف الأسواق",
    ),
    "how_to_step_2_content": MessageLookupByLibrary.simpleMessage(
      "الوصول إلى أسعار السوق المباشرة والحجم والاتجاهات التاريخية لاتخاذ قرارات مستنيرة.",
    ),
    "how_to_step_2_title": MessageLookupByLibrary.simpleMessage(
      "2. البيانات الفورية",
    ),
    "how_to_step_3_content": MessageLookupByLibrary.simpleMessage(
      "تتبع استثماراتك، وأنشئ قوائم المراقبة، واحصل على تنبيهات حول تحركات الأسعار.",
    ),
    "how_to_step_3_title": MessageLookupByLibrary.simpleMessage(
      "3. إدارة المحفظة",
    ),
    "how_to_step_4_content": MessageLookupByLibrary.simpleMessage(
      "استخدم الرسوم البيانية والمؤشرات ورؤى الذكاء الاصطناعي لتحليل أنماط السوق.",
    ),
    "how_to_step_4_title": MessageLookupByLibrary.simpleMessage(
      "4. أدوات التحليل",
    ),
    "how_to_use_description": MessageLookupByLibrary.simpleMessage(
      "تعلم كيفية استكشاف ميزات EGX360 بفعالية.",
    ),
    "how_to_use_egx360": MessageLookupByLibrary.simpleMessage(
      "كيفية استخدام EGX360؟",
    ),
    "how_to_use_intro": MessageLookupByLibrary.simpleMessage(
      "تم تصميم EGX360 لتزويدك ببيانات وتحليلات السوق الفورية. اتبع هذه الخطوات لتحقيق أقصى استفادة من تجربتك:",
    ),
    "how_to_use_page_title": MessageLookupByLibrary.simpleMessage(
      "كيفية استخدام EGX360",
    ),
    "how_to_use_subtitle": MessageLookupByLibrary.simpleMessage(
      "تعرف على كيفية استكشاف الأسواق والوصول إلى البيانات الفورية.",
    ),
    "incorrect_current_password": MessageLookupByLibrary.simpleMessage(
      "كلمة المرور الحالية التي أدخلتها غير صحيحة.",
    ),
    "indicators_apply": MessageLookupByLibrary.simpleMessage("تطبيق الإعدادات"),
    "indicators_bollinger": MessageLookupByLibrary.simpleMessage(
      "بولينجر باندز",
    ),
    "indicators_bollinger_desc": MessageLookupByLibrary.simpleMessage(
      "يعرض تقلبات الأسعار بنطاقات علوية وسفلية حول متوسط متحرك. تميل الأسعار للارتداد داخل النطاقات.",
    ),
    "indicators_bollinger_short": MessageLookupByLibrary.simpleMessage(
      "بولينجر",
    ),
    "indicators_bollinger_val": m12,
    "indicators_config_hint": MessageLookupByLibrary.simpleMessage(
      "اضغط على المؤشر لضبط إعداداته",
    ),
    "indicators_default": MessageLookupByLibrary.simpleMessage("الافتراضي"),
    "indicators_ema": MessageLookupByLibrary.simpleMessage(
      "المتوسط المتحرك الأسي (EMA)",
    ),
    "indicators_ema_desc": MessageLookupByLibrary.simpleMessage(
      "يشبه المتوسط المتحرك البسيط ولكنه يعطي وزناً أكبر للأسعار الأخيرة، مما يجعله يستجيب بشكل أسرع للتغيرات.",
    ),
    "indicators_ema_short": MessageLookupByLibrary.simpleMessage("EMA"),
    "indicators_enable": MessageLookupByLibrary.simpleMessage("تفعيل المؤشر"),
    "indicators_normal": MessageLookupByLibrary.simpleMessage("عادي"),
    "indicators_period": MessageLookupByLibrary.simpleMessage("المدة"),
    "indicators_period_desc": m13,
    "indicators_period_val": m14,
    "indicators_quick_select": MessageLookupByLibrary.simpleMessage(
      "اختيار سريع:",
    ),
    "indicators_reset": MessageLookupByLibrary.simpleMessage("إعادة ضبط"),
    "indicators_rsi": MessageLookupByLibrary.simpleMessage(
      "مؤشر القوة النسبية (RSI)",
    ),
    "indicators_rsi_desc": MessageLookupByLibrary.simpleMessage(
      "يقيس سرعة وحجم تغيرات الأسعار. القيم فوق 70 تشير إلى تشبع شرائي، وتحت 30 تشير إلى تشبع بيعي.",
    ),
    "indicators_rsi_short": MessageLookupByLibrary.simpleMessage("RSI"),
    "indicators_sma": MessageLookupByLibrary.simpleMessage(
      "المتوسط المتحرك البسيط (SMA)",
    ),
    "indicators_sma_desc": MessageLookupByLibrary.simpleMessage(
      "يعرض متوسط السعر خلال فترة محددة، مما يساعد في تحديد الاتجاهات.",
    ),
    "indicators_sma_short": MessageLookupByLibrary.simpleMessage("SMA"),
    "indicators_std_dev": MessageLookupByLibrary.simpleMessage(
      "الانحراف المعياري",
    ),
    "indicators_std_dev_desc": m15,
    "indicators_tight": MessageLookupByLibrary.simpleMessage("ضيق"),
    "indicators_title": MessageLookupByLibrary.simpleMessage("المؤشرات الفنية"),
    "indicators_volume": MessageLookupByLibrary.simpleMessage("أعمدة الحجم"),
    "indicators_volume_desc": MessageLookupByLibrary.simpleMessage(
      "إظهار حجم التداول في أسفل الرسم البياني",
    ),
    "indicators_wide": MessageLookupByLibrary.simpleMessage("واسع"),
    "invalidEmail": MessageLookupByLibrary.simpleMessage(
      "يرجى إدخال بريد إلكتروني صحيح.",
    ),
    "invalid_password": MessageLookupByLibrary.simpleMessage(
      "كلمة مرور غير صالحة",
    ),
    "language": MessageLookupByLibrary.simpleMessage("اللغة"),
    "language_arabic_subtitle": MessageLookupByLibrary.simpleMessage(
      "اضبط لغة التطبيق إلى العربية",
    ),
    "language_changed": MessageLookupByLibrary.simpleMessage("تم تغيير اللغة"),
    "language_changed_to_arabic": MessageLookupByLibrary.simpleMessage(
      "تم تغيير اللغة إلى العربية",
    ),
    "language_changed_to_english": MessageLookupByLibrary.simpleMessage(
      "App language set to English",
    ),
    "language_english": MessageLookupByLibrary.simpleMessage("الإنجليزية"),
    "language_english_subtitle": MessageLookupByLibrary.simpleMessage(
      "Set app language to English",
    ),
    "language_name_arabic": MessageLookupByLibrary.simpleMessage("العربية"),
    "language_name_english": MessageLookupByLibrary.simpleMessage("الإنجليزية"),
    "last_active_now": MessageLookupByLibrary.simpleMessage("الآن"),
    "last_updated": MessageLookupByLibrary.simpleMessage(
      "آخر تحديث: 26 أكتوبر 2025",
    ),
    "latest_news_title": MessageLookupByLibrary.simpleMessage("آخر الأخبار"),
    "licenses": MessageLookupByLibrary.simpleMessage("التراخيص"),
    "light": MessageLookupByLibrary.simpleMessage("فاتح"),
    "loading": MessageLookupByLibrary.simpleMessage("جار التحميل..."),
    "location_egypt": MessageLookupByLibrary.simpleMessage("القاهرة، مصر"),
    "logged_out": MessageLookupByLibrary.simpleMessage("تم تسجيل الخروج"),
    "logged_out_success": MessageLookupByLibrary.simpleMessage(
      "تم تسجيل خروجك بنجاح.",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("تسجيل الخروج"),
    "logout_failed": MessageLookupByLibrary.simpleMessage("فشل تسجيل الخروج."),
    "mark_all_read_btn": MessageLookupByLibrary.simpleMessage(
      "تحديد الكل كمقروء",
    ),
    "market_alerts": MessageLookupByLibrary.simpleMessage("تنبيهات السوق"),
    "market_alerts_subtitle": MessageLookupByLibrary.simpleMessage(
      "تحركات الأسعار، ارتفاع الحجم",
    ),
    "market_cap_label": MessageLookupByLibrary.simpleMessage(
      "رأس المال السوقي",
    ),
    "market_closed": MessageLookupByLibrary.simpleMessage("مغلق"),
    "market_crypto": MessageLookupByLibrary.simpleMessage("سوق الكريبتو"),
    "market_egx": MessageLookupByLibrary.simpleMessage("البورصة المصرية"),
    "market_indices_title": MessageLookupByLibrary.simpleMessage(
      "مؤشرات السوق",
    ),
    "market_label": MessageLookupByLibrary.simpleMessage("السوق"),
    "market_live": MessageLookupByLibrary.simpleMessage("مباشر"),
    "market_status_closed": MessageLookupByLibrary.simpleMessage("مغلق"),
    "market_status_open": MessageLookupByLibrary.simpleMessage("مفتوح"),
    "market_status_title": MessageLookupByLibrary.simpleMessage("حالة السوق"),
    "markets_select_asset": MessageLookupByLibrary.simpleMessage(
      "اختر أصلًا من القائمة",
    ),
    "markets_title": MessageLookupByLibrary.simpleMessage("الأسواق"),
    "menu_settings": MessageLookupByLibrary.simpleMessage("الإعدادات"),
    "msg_password_reset": MessageLookupByLibrary.simpleMessage(
      "تم إرسال تعليمات إعادة تعيين كلمة المرور إذا كان هذا البريد مسجلاً.",
    ),
    "msg_verification_sent": MessageLookupByLibrary.simpleMessage(
      "تم إرسال رمز التحقق إلى بريدك الإلكتروني.",
    ),
    "mute_all_alerts": MessageLookupByLibrary.simpleMessage(
      "كتم جميع تنبيهات التطبيق",
    ),
    "muted": MessageLookupByLibrary.simpleMessage("صامت"),
    "my_portfolio": MessageLookupByLibrary.simpleMessage("محفظتي"),
    "nameMinChars": MessageLookupByLibrary.simpleMessage(
      "يجب أن يتكون الاسم من 3 أحرف على الأقل.",
    ),
    "name_label": MessageLookupByLibrary.simpleMessage("الاسم الكامل"),
    "nav_community": MessageLookupByLibrary.simpleMessage("المجتمع"),
    "nav_home": MessageLookupByLibrary.simpleMessage("الرئيسية"),
    "nav_markets": MessageLookupByLibrary.simpleMessage("الأسواق"),
    "nav_menu": MessageLookupByLibrary.simpleMessage("القائمة"),
    "nav_search": MessageLookupByLibrary.simpleMessage("بحث"),
    "nav_settings": MessageLookupByLibrary.simpleMessage("الإعدادات"),
    "nav_simulation": MessageLookupByLibrary.simpleMessage("المحاكاة"),
    "need_help": MessageLookupByLibrary.simpleMessage("تحتاج مساعدة؟"),
    "need_help_subtitle": MessageLookupByLibrary.simpleMessage(
      "احصل على إجابات سريعة أو تواصل للحصول على الدعم.",
    ),
    "new_password": MessageLookupByLibrary.simpleMessage("كلمة المرور الجديدة"),
    "news_updates": MessageLookupByLibrary.simpleMessage("تحديثات الأخبار"),
    "news_updates_subtitle": MessageLookupByLibrary.simpleMessage(
      "الأخبار المالية والسوقية",
    ),
    "no_news_available": MessageLookupByLibrary.simpleMessage(
      "لا توجد أخبار متاحة",
    ),
    "no_notifications_msg": MessageLookupByLibrary.simpleMessage(
      "لا توجد إشعارات حتى الآن",
    ),
    "no_results": MessageLookupByLibrary.simpleMessage("لا توجد نتائج"),
    "not_available": MessageLookupByLibrary.simpleMessage("غير متوفر"),
    "notification_fallback_title": MessageLookupByLibrary.simpleMessage(
      "إشعار",
    ),
    "notification_sounds": MessageLookupByLibrary.simpleMessage(
      "أصوات الإشعارات",
    ),
    "notification_sounds_subtitle": MessageLookupByLibrary.simpleMessage(
      "تشغيل صوت للتنبيهات الجديدة",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("الإشعارات"),
    "notifications_title": MessageLookupByLibrary.simpleMessage("الإشعارات"),
    "now_label": MessageLookupByLibrary.simpleMessage("الآن"),
    "open_source_licenses": MessageLookupByLibrary.simpleMessage(
      "تراخيص المصادر المفتوحة",
    ),
    "order_alert_threshold": MessageLookupByLibrary.simpleMessage(
      "📢 حد التنبيه",
    ),
    "order_auto_sell": MessageLookupByLibrary.simpleMessage("بيع تلقائي"),
    "order_auto_sell_threshold": MessageLookupByLibrary.simpleMessage(
      "🛡️ حد البيع التلقائي",
    ),
    "order_available_balance": m16,
    "order_bought_msg": m17,
    "order_buy": MessageLookupByLibrary.simpleMessage("شراء"),
    "order_enable_protection": MessageLookupByLibrary.simpleMessage(
      "تفعيل الحماية",
    ),
    "order_est_total": m18,
    "order_limit": MessageLookupByLibrary.simpleMessage("محدد"),
    "order_market": MessageLookupByLibrary.simpleMessage("سوق"),
    "order_monitoring_msg": m19,
    "order_msg_alert": m20,
    "order_msg_both": m21,
    "order_place_order": m22,
    "order_price": MessageLookupByLibrary.simpleMessage("السعر"),
    "order_protection_desc": m23,
    "order_protection_enabled": MessageLookupByLibrary.simpleMessage(
      "تم تفعيل الحماية 🛡️",
    ),
    "order_protection_info_alert": m24,
    "order_protection_info_both": m25,
    "order_protection_title": MessageLookupByLibrary.simpleMessage(
      "🎉 تمت الصفقة بنجاح!",
    ),
    "order_quantity": MessageLookupByLibrary.simpleMessage("الكمية"),
    "order_saving": MessageLookupByLibrary.simpleMessage("جاري الحفظ..."),
    "order_sell": MessageLookupByLibrary.simpleMessage("بيع"),
    "order_sim_not_available": MessageLookupByLibrary.simpleMessage(
      "ميزة المحاكاة غير متاحة حالياً",
    ),
    "order_skip": MessageLookupByLibrary.simpleMessage("تخطي"),
    "order_sold_msg": m26,
    "order_trade_executed": MessageLookupByLibrary.simpleMessage(
      "تم تنفيذ الصفقة",
    ),
    "order_valid_qty": MessageLookupByLibrary.simpleMessage(
      "يرجى إدخال كمية صالحة",
    ),
    "passwordMinChars": MessageLookupByLibrary.simpleMessage(
      "يجب أن تتكون كلمة المرور من 6 أحرف على الأقل.",
    ),
    "passwordUpperNumber": MessageLookupByLibrary.simpleMessage(
      "يجب أن تحتوي كلمة المرور على حرف كبير ورقم.",
    ),
    "password_changed_success": MessageLookupByLibrary.simpleMessage(
      "تم تغيير كلمة المرور بنجاح.",
    ),
    "password_label": MessageLookupByLibrary.simpleMessage("كلمة المرور"),
    "password_updated": MessageLookupByLibrary.simpleMessage(
      "تم تحديث كلمة المرور",
    ),
    "passwordsNotMatch": MessageLookupByLibrary.simpleMessage(
      "كلمات المرور غير متطابقة.",
    ),
    "phone_label": MessageLookupByLibrary.simpleMessage("رقم الهاتف"),
    "placeholder_email": MessageLookupByLibrary.simpleMessage(
      "you@example.com",
    ),
    "placeholder_name": MessageLookupByLibrary.simpleMessage("اسمك الكامل"),
    "placeholder_password": MessageLookupByLibrary.simpleMessage(
      "أدخل كلمة المرور",
    ),
    "policy_agreement": MessageLookupByLibrary.simpleMessage(
      "بالمتابعة، أنت توافق على شروط الخدمة وسياسة الخصوصية الخاصة بنا",
    ),
    "portfolio_title": MessageLookupByLibrary.simpleMessage("المحفظة"),
    "position_avg_buy_price": MessageLookupByLibrary.simpleMessage(
      "متوسط سعر الشراء",
    ),
    "position_current_price": MessageLookupByLibrary.simpleMessage(
      "السعر الحالي",
    ),
    "position_current_value": MessageLookupByLibrary.simpleMessage(
      "القيمة الحالية",
    ),
    "position_my_position": MessageLookupByLibrary.simpleMessage("مركزي"),
    "position_pl_short": MessageLookupByLibrary.simpleMessage("الربح/الخسارة"),
    "position_shares": m27,
    "position_shares_owned": MessageLookupByLibrary.simpleMessage(
      "الأسهم المملوكة",
    ),
    "position_total_cost": MessageLookupByLibrary.simpleMessage(
      "إجمالي التكلفة",
    ),
    "position_total_pl": MessageLookupByLibrary.simpleMessage(
      "إجمالي الربح/الخسارة",
    ),
    "post_details_bearish": MessageLookupByLibrary.simpleMessage("تشاؤمي"),
    "post_details_bullish": MessageLookupByLibrary.simpleMessage("تفاؤلي"),
    "post_details_comments_header": MessageLookupByLibrary.simpleMessage(
      "التعليقات",
    ),
    "post_details_error_add_comment": MessageLookupByLibrary.simpleMessage(
      "فشل في إضافة التعليق",
    ),
    "post_details_error_load": MessageLookupByLibrary.simpleMessage(
      "فشل في تحميل المنشور",
    ),
    "post_details_error_vote": MessageLookupByLibrary.simpleMessage(
      "فشل في التصويت",
    ),
    "post_details_no_comments": MessageLookupByLibrary.simpleMessage(
      "لا توجد تعليقات بعد",
    ),
    "post_details_replies_title": MessageLookupByLibrary.simpleMessage(
      "الردود",
    ),
    "post_details_reply": MessageLookupByLibrary.simpleMessage("رد"),
    "post_details_reply_to_hint": m28,
    "post_details_replying": MessageLookupByLibrary.simpleMessage("يرد حالياً"),
    "post_details_replying_to": m29,
    "post_details_share_thoughts": MessageLookupByLibrary.simpleMessage(
      "شاركنا رأيك...",
    ),
    "post_details_someone": MessageLookupByLibrary.simpleMessage("شخص ما"),
    "post_details_user_fallback": MessageLookupByLibrary.simpleMessage(
      "مستخدم",
    ),
    "post_details_view_replies": m30,
    "preferences_section": MessageLookupByLibrary.simpleMessage("التفضيلات"),
    "privacy_intro": MessageLookupByLibrary.simpleMessage(
      "في تطبيق EGX، نحن نقدّر خصوصيتك ونلتزم بحماية معلوماتك الشخصية. توضح سياسة الخصوصية هذه كيفية جمع واستخدام وحماية بياناتك عند استخدام خدماتنا.",
    ),
    "privacy_policy": MessageLookupByLibrary.simpleMessage("سياسة الخصوصية"),
    "privacy_policy_title": MessageLookupByLibrary.simpleMessage(
      "سياسة الخصوصية",
    ),
    "privacy_section_1_content": MessageLookupByLibrary.simpleMessage(
      "قد نجمع معلومات مثل اسمك وعنوان بريدك الإلكتروني وتفضيلات المحفظة ونشاط الاستخدام داخل التطبيق لتحسين تجربتك.",
    ),
    "privacy_section_1_title": MessageLookupByLibrary.simpleMessage(
      "1. المعلومات التي نجمعها",
    ),
    "privacy_section_2_content": MessageLookupByLibrary.simpleMessage(
      "تساعدنا بياناتك على تقديم محتوى مخصص وتحسين أداء التطبيق وضمان أمان حسابك.",
    ),
    "privacy_section_2_title": MessageLookupByLibrary.simpleMessage(
      "2. كيف نستخدم معلوماتك",
    ),
    "privacy_section_3_content": MessageLookupByLibrary.simpleMessage(
      "نستخدم التشفير الآمن وطرق المصادقة لحماية بياناتك. لا تتم مشاركة معلوماتك مع أطراف ثالثة دون موافقتك.",
    ),
    "privacy_section_3_title": MessageLookupByLibrary.simpleMessage(
      "3. حماية البيانات",
    ),
    "privacy_section_4_content": MessageLookupByLibrary.simpleMessage(
      "قد نتكامل مع خدمات موثوقة مثل Firebase أو أدوات التحليلات لتتبع الأداء والإبلاغ عن الأعطال.",
    ),
    "privacy_section_4_title": MessageLookupByLibrary.simpleMessage(
      "4. خدمات الطرف الثالث",
    ),
    "privacy_section_5_content": MessageLookupByLibrary.simpleMessage(
      "لديك الحق في الوصول إلى بياناتك أو تعديلها أو حذفها. يمكنك طلب ذلك عبر إعدادات التطبيق أو الاتصال بالدعم.",
    ),
    "privacy_section_5_title": MessageLookupByLibrary.simpleMessage("5. حقوقك"),
    "privacy_section_6_content": MessageLookupByLibrary.simpleMessage(
      "قد نقوم بتحديث سياسة الخصوصية هذه من وقت لآخر. سيتم عكس جميع التغييرات هنا مع تاريخ \'آخر تحديث\' جديد.",
    ),
    "privacy_section_6_title": MessageLookupByLibrary.simpleMessage(
      "6. تحديثات هذه السياسة",
    ),
    "privacy_security": MessageLookupByLibrary.simpleMessage(
      "الخصوصية والأمان",
    ),
    "profile_create_post": MessageLookupByLibrary.simpleMessage("إنشاء منشور"),
    "profile_failed_to_create_post": MessageLookupByLibrary.simpleMessage(
      "فشل في إنشاء المنشور",
    ),
    "profile_failed_to_follow": MessageLookupByLibrary.simpleMessage(
      "فشل في تحديث حالة المتابعة",
    ),
    "profile_followers": MessageLookupByLibrary.simpleMessage("المتابعون"),
    "profile_following": MessageLookupByLibrary.simpleMessage("المتابَعون"),
    "profile_headline_hint": MessageLookupByLibrary.simpleMessage("العنوان"),
    "profile_idea_published": MessageLookupByLibrary.simpleMessage(
      "تم نشر الفكرة بنجاح!",
    ),
    "profile_login_to_post": MessageLookupByLibrary.simpleMessage(
      "يرجى تسجيل الدخول لإنشاء منشور",
    ),
    "profile_no_followers": MessageLookupByLibrary.simpleMessage(
      "لا يوجد متابعون بعد",
    ),
    "profile_no_posts": MessageLookupByLibrary.simpleMessage(
      "لا توجد منشورات مشاركة بعد",
    ),
    "profile_not_following_anyone": MessageLookupByLibrary.simpleMessage(
      "لا تتابع أحداً بعد",
    ),
    "profile_picture_updated": MessageLookupByLibrary.simpleMessage(
      "تم تحديث صورة الملف الشخصي بنجاح!",
    ),
    "profile_post_button": MessageLookupByLibrary.simpleMessage("نشر"),
    "profile_post_hint": MessageLookupByLibrary.simpleMessage(
      "شارك تحليلك للسوق...\nاستخدم \$ للرموز مثل \$EGX30",
    ),
    "profile_posts": MessageLookupByLibrary.simpleMessage("المنشورات"),
    "profile_posts_count": m31,
    "profile_suggested_stocks": MessageLookupByLibrary.simpleMessage(
      "الأسهم المقترحة",
    ),
    "profile_title": MessageLookupByLibrary.simpleMessage("الملف الشخصي"),
    "profile_updated_success": MessageLookupByLibrary.simpleMessage(
      "تم تحديث ملفك الشخصي بنجاح!",
    ),
    "profile_user_not_found": MessageLookupByLibrary.simpleMessage(
      "المستخدم غير موجود",
    ),
    "range_1d": MessageLookupByLibrary.simpleMessage("يوم"),
    "range_1m": MessageLookupByLibrary.simpleMessage("شهر"),
    "range_1w": MessageLookupByLibrary.simpleMessage("أسبوع"),
    "range_1y": MessageLookupByLibrary.simpleMessage("سنة"),
    "range_3m": MessageLookupByLibrary.simpleMessage("٣ أشهر"),
    "range_5d": MessageLookupByLibrary.simpleMessage("٥ أيام"),
    "range_5y": MessageLookupByLibrary.simpleMessage("٥ سنوات"),
    "range_6m": MessageLookupByLibrary.simpleMessage("٦ أشهر"),
    "range_all": MessageLookupByLibrary.simpleMessage("الكل"),
    "register_description": MessageLookupByLibrary.simpleMessage(
      "انضم إلينا وابدأ في استكشاف جميع الميزات الرائعة التي نقدمها!",
    ),
    "register_have_account": MessageLookupByLibrary.simpleMessage(
      "لديك حساب بالفعل؟ ",
    ),
    "register_login": MessageLookupByLibrary.simpleMessage("تسجيل الدخول"),
    "removed_from_watchlist_msg": m32,
    "retry_btn": MessageLookupByLibrary.simpleMessage("إعادة المحاولة"),
    "save_changes": MessageLookupByLibrary.simpleMessage("حفظ التغييرات"),
    "search_all_news": MessageLookupByLibrary.simpleMessage("كل الأخبار"),
    "search_asset": MessageLookupByLibrary.simpleMessage("أصل"),
    "search_cat_all": MessageLookupByLibrary.simpleMessage("الكل"),
    "search_cat_crypto": MessageLookupByLibrary.simpleMessage(
      "العملات الرقمية",
    ),
    "search_cat_indices": MessageLookupByLibrary.simpleMessage("المؤشرات"),
    "search_cat_materials": MessageLookupByLibrary.simpleMessage(
      "المواد الخام",
    ),
    "search_cat_stocks": MessageLookupByLibrary.simpleMessage("الأسهم"),
    "search_currency_usd": MessageLookupByLibrary.simpleMessage("\$"),
    "search_egp": MessageLookupByLibrary.simpleMessage("ج.م."),
    "search_egx_news": MessageLookupByLibrary.simpleMessage(
      "أخبار البورصة المصرية",
    ),
    "search_hint": MessageLookupByLibrary.simpleMessage("بحث"),
    "search_hint_main": MessageLookupByLibrary.simpleMessage("بحث عن رمز..."),
    "search_latest_news": MessageLookupByLibrary.simpleMessage("آخر الأخبار"),
    "search_market_movers": MessageLookupByLibrary.simpleMessage(
      "الأكثر حركة في السوق",
    ),
    "search_market_overview": MessageLookupByLibrary.simpleMessage(
      "نظرة عامة على السوق",
    ),
    "search_news_details": MessageLookupByLibrary.simpleMessage("تفاصيل الخبر"),
    "search_no_content": MessageLookupByLibrary.simpleMessage(
      "لا يوجد محتوى متاح.",
    ),
    "search_no_news": MessageLookupByLibrary.simpleMessage(
      "لا توجد أخبار متاحة",
    ),
    "search_pts": MessageLookupByLibrary.simpleMessage("نقطة"),
    "search_read_original": MessageLookupByLibrary.simpleMessage(
      "قراءة المقال الأصلي",
    ),
    "search_results_not_found": MessageLookupByLibrary.simpleMessage(
      "لم يتم العثور على نتائج",
    ),
    "search_tts_check_source": MessageLookupByLibrary.simpleMessage(
      "يرجى مراجعة المصدر للتفاصيل",
    ),
    "search_view_all": MessageLookupByLibrary.simpleMessage("عرض الكل"),
    "security_section": MessageLookupByLibrary.simpleMessage("الأمان"),
    "see_all_btn": MessageLookupByLibrary.simpleMessage("عرض الكل"),
    "select_language": MessageLookupByLibrary.simpleMessage(
      "اختر لغتك المفضلة",
    ),
    "send_code": MessageLookupByLibrary.simpleMessage("إرسال الرمز"),
    "session_active": MessageLookupByLibrary.simpleMessage("نشط"),
    "settings_title": MessageLookupByLibrary.simpleMessage("الإعدادات"),
    "sidebar_chg": MessageLookupByLibrary.simpleMessage("التغيير"),
    "sidebar_chg_percent": MessageLookupByLibrary.simpleMessage("التغيير %"),
    "sidebar_details": MessageLookupByLibrary.simpleMessage("التفاصيل"),
    "sidebar_last": MessageLookupByLibrary.simpleMessage("الأخيرة"),
    "sidebar_no_assets": MessageLookupByLibrary.simpleMessage(
      "لا توجد أصول متاحة",
    ),
    "sidebar_no_results": MessageLookupByLibrary.simpleMessage(
      "لم يتم العثور على نتائج",
    ),
    "sidebar_search_symbol": MessageLookupByLibrary.simpleMessage("بحث عن رمز"),
    "sidebar_show_details": MessageLookupByLibrary.simpleMessage(
      "إظهار التفاصيل",
    ),
    "sidebar_show_watchlist": MessageLookupByLibrary.simpleMessage(
      "إظهار قائمة المراقبة",
    ),
    "sidebar_symbol": MessageLookupByLibrary.simpleMessage("الرمز"),
    "sidebar_watchlist": MessageLookupByLibrary.simpleMessage("قائمة المراقبة"),
    "sign_google": MessageLookupByLibrary.simpleMessage(
      "تسجيل الدخول عبر Google",
    ),
    "silver_999_desc": MessageLookupByLibrary.simpleMessage(
      "سعر الفضة 999 بالجنيه المصري",
    ),
    "silver_999_title": MessageLookupByLibrary.simpleMessage("فضة 999"),
    "sim_alert_at_msg": m33,
    "sim_alert_desc": MessageLookupByLibrary.simpleMessage(
      "تنبيه عند وصول الخسارة للحد المحدد",
    ),
    "sim_alert_me": MessageLookupByLibrary.simpleMessage("تنبيه"),
    "sim_auto": MessageLookupByLibrary.simpleMessage("تلقائي"),
    "sim_auto_sell_at_msg": m34,
    "sim_auto_sell_desc": MessageLookupByLibrary.simpleMessage(
      "البيع تلقائياً عند وصول الخسارة للحد المحدد",
    ),
    "sim_auto_sell_protection": MessageLookupByLibrary.simpleMessage(
      "بيع تلقائي",
    ),
    "sim_available_cash": MessageLookupByLibrary.simpleMessage("النقد المتاح"),
    "sim_avg_price": MessageLookupByLibrary.simpleMessage("متوسط السعر"),
    "sim_both_disabled_msg": MessageLookupByLibrary.simpleMessage(
      "كلتا الميزتين معطلتان. قم بتفعيل واحدة على الأقل لحماية رأس مالك.",
    ),
    "sim_capital_protection": MessageLookupByLibrary.simpleMessage(
      "حماية رأس المال",
    ),
    "sim_current_price": MessageLookupByLibrary.simpleMessage("السعر الحالي"),
    "sim_failed_to_fetch_holdings": MessageLookupByLibrary.simpleMessage(
      "فشل في جلب المراكز",
    ),
    "sim_failed_to_fetch_transactions": MessageLookupByLibrary.simpleMessage(
      "فشل في جلب سجل المعاملات",
    ),
    "sim_failed_to_fetch_wallet": MessageLookupByLibrary.simpleMessage(
      "فشل في جلب بيانات المحفظة",
    ),
    "sim_failed_to_load": MessageLookupByLibrary.simpleMessage(
      "فشل في تحميل بيانات المحاكاة",
    ),
    "sim_failed_to_remove_rule": m35,
    "sim_failed_to_save_rule": m36,
    "sim_go_to_markets": MessageLookupByLibrary.simpleMessage(
      "اذهب إلى الأسواق",
    ),
    "sim_holdings": MessageLookupByLibrary.simpleMessage("المراكز"),
    "sim_holdings_count": m37,
    "sim_no_holdings": MessageLookupByLibrary.simpleMessage(
      "لا توجد مراكز بعد",
    ),
    "sim_no_transactions": MessageLookupByLibrary.simpleMessage(
      "لا توجد معاملات بعد",
    ),
    "sim_pl": MessageLookupByLibrary.simpleMessage("الربح/الخسارة"),
    "sim_portfolio_title": MessageLookupByLibrary.simpleMessage(
      "محفظة المحاكاة",
    ),
    "sim_positions": MessageLookupByLibrary.simpleMessage("المراكز"),
    "sim_price": MessageLookupByLibrary.simpleMessage("السعر"),
    "sim_protection_active": m38,
    "sim_protection_removed": m39,
    "sim_protection_saved": m40,
    "sim_protection_updated": m41,
    "sim_quantity": MessageLookupByLibrary.simpleMessage("الكمية"),
    "sim_remove": MessageLookupByLibrary.simpleMessage("إزالة"),
    "sim_save_rule": MessageLookupByLibrary.simpleMessage("حفظ القاعدة"),
    "sim_set_protection": MessageLookupByLibrary.simpleMessage("ضبط الحماية"),
    "sim_shares_unit": MessageLookupByLibrary.simpleMessage("أسهم"),
    "sim_start_trading": MessageLookupByLibrary.simpleMessage(
      "ابدأ التداول لبناء محفظتك",
    ),
    "sim_total_capital": MessageLookupByLibrary.simpleMessage("الإجمالي"),
    "sim_total_portfolio_value": MessageLookupByLibrary.simpleMessage(
      "إجمالي قيمة المحفظة",
    ),
    "sim_trading_history_desc": MessageLookupByLibrary.simpleMessage(
      "سوف يظهر سجل تداولك هنا",
    ),
    "sim_transaction_history": MessageLookupByLibrary.simpleMessage(
      "سجل المعاملات",
    ),
    "sim_update_rule": MessageLookupByLibrary.simpleMessage("تحديث القاعدة"),
    "sim_user_not_auth": MessageLookupByLibrary.simpleMessage(
      "المستخدم غير مسجل الدخول",
    ),
    "sim_view_all": MessageLookupByLibrary.simpleMessage("عرض الكل"),
    "simulation_available_cash": MessageLookupByLibrary.simpleMessage(
      "النقد المتاح",
    ),
    "simulation_portfolio": MessageLookupByLibrary.simpleMessage(
      "محفظة المحاكاة",
    ),
    "simulation_positions": MessageLookupByLibrary.simpleMessage("المراكز"),
    "simulation_total_pl": MessageLookupByLibrary.simpleMessage(
      "إجمالي الربح والخسارة",
    ),
    "skip": MessageLookupByLibrary.simpleMessage("تخطي"),
    "snackbar_error": MessageLookupByLibrary.simpleMessage("خطأ"),
    "snackbar_no_connection": MessageLookupByLibrary.simpleMessage(
      "لا يوجد اتصال",
    ),
    "snackbar_success": MessageLookupByLibrary.simpleMessage("نجح"),
    "snackbar_unexpected_error": MessageLookupByLibrary.simpleMessage(
      "خطأ غير متوقع",
    ),
    "snackbar_warning": MessageLookupByLibrary.simpleMessage("تحذير"),
    "something_went_wrong": MessageLookupByLibrary.simpleMessage("حدث خطأ ما."),
    "sounds_alerts_section": MessageLookupByLibrary.simpleMessage(
      "الأصوات والتنبيهات",
    ),
    "start_trading_btn": MessageLookupByLibrary.simpleMessage("ابدأ التداول"),
    "stock_chat_error_send": MessageLookupByLibrary.simpleMessage(
      "فشل في إرسال الرسالة",
    ),
    "stock_chat_input_hint": MessageLookupByLibrary.simpleMessage(
      "انضم إلى المناقشة...",
    ),
    "stock_chat_start_discussion": m42,
    "stock_chat_user_prefix": MessageLookupByLibrary.simpleMessage("مستخدم"),
    "stock_chat_you": MessageLookupByLibrary.simpleMessage("أنت"),
    "success_account_created_title": MessageLookupByLibrary.simpleMessage(
      "تم إنشاء الحساب بنجاح!",
    ),
    "success_account_deleted_msg": MessageLookupByLibrary.simpleMessage(
      "تم حذف حسابك نهائياً.",
    ),
    "success_account_deleted_title": MessageLookupByLibrary.simpleMessage(
      "تم حذف الحساب",
    ),
    "success_email_sent_title": MessageLookupByLibrary.simpleMessage(
      "تم إرسال البريد",
    ),
    "success_google_signed_in_msg": MessageLookupByLibrary.simpleMessage(
      "تم تسجيل الدخول عبر Google بنجاح.",
    ),
    "success_label": MessageLookupByLibrary.simpleMessage("نجاح"),
    "success_logged_out_msg": MessageLookupByLibrary.simpleMessage(
      "لقد قمت بتسجيل الخروج بنجاح.",
    ),
    "success_logged_out_title": MessageLookupByLibrary.simpleMessage(
      "تم تسجيل الخروج",
    ),
    "success_mark_all_read": MessageLookupByLibrary.simpleMessage(
      "تم تحديد جميع الإشعارات كمقروءة",
    ),
    "success_password_changed_msg": MessageLookupByLibrary.simpleMessage(
      "تم تغيير كلمة المرور الخاصة بك بنجاح.",
    ),
    "success_password_updated_title": MessageLookupByLibrary.simpleMessage(
      "تم تحديث كلمة المرور",
    ),
    "success_reset_link_sent_msg": MessageLookupByLibrary.simpleMessage(
      "تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك.",
    ),
    "success_signed_in_msg": MessageLookupByLibrary.simpleMessage(
      "تم تسجيل الدخول بنجاح!",
    ),
    "success_verification_sent_msg": MessageLookupByLibrary.simpleMessage(
      "تم إرسال رابط التحقق إلى بريدك الإلكتروني.",
    ),
    "success_welcome_back_title": MessageLookupByLibrary.simpleMessage(
      "مرحباً بعودتك",
    ),
    "support_section": MessageLookupByLibrary.simpleMessage("الدعم"),
    "system_notifications_on": MessageLookupByLibrary.simpleMessage(
      "إشعارات النظام مفعّلة",
    ),
    "system_settings": MessageLookupByLibrary.simpleMessage("إعدادات النظام"),
    "system_theme_description": MessageLookupByLibrary.simpleMessage(
      "سيتغير المظهر حسب إعدادات الهاتف",
    ),
    "tap_to_enable": MessageLookupByLibrary.simpleMessage(
      "اضغط للتفعيل في الإعدادات",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("المظهر"),
    "this_device": MessageLookupByLibrary.simpleMessage("هذا الجهاز"),
    "today": MessageLookupByLibrary.simpleMessage("اليوم"),
    "trending_stocks_title": MessageLookupByLibrary.simpleMessage(
      "الأسهم الرائجة",
    ),
    "unable_to_open_email": MessageLookupByLibrary.simpleMessage(
      "تعذر فتح تطبيق البريد الإلكتروني.",
    ),
    "unknown_error": MessageLookupByLibrary.simpleMessage("حدث خطأ ما."),
    "update_password": MessageLookupByLibrary.simpleMessage(
      "تحديث كلمة المرور",
    ),
    "usd_label": MessageLookupByLibrary.simpleMessage("دولار"),
    "use_system_theme": MessageLookupByLibrary.simpleMessage(
      "استخدام مظهر النظام",
    ),
    "value_traded_label": MessageLookupByLibrary.simpleMessage("قيمة التداول"),
    "verify_code": MessageLookupByLibrary.simpleMessage("تحقق من الرمز"),
    "version_number": MessageLookupByLibrary.simpleMessage("الإصدار 1.0.0"),
    "view_all_notifications_btn": MessageLookupByLibrary.simpleMessage(
      "عرض كل الإشعارات",
    ),
    "virtual_balance_title": MessageLookupByLibrary.simpleMessage(
      "رصيد المحاكاة الحالي",
    ),
    "watchlist_add": MessageLookupByLibrary.simpleMessage(
      "إضافة إلى قائمة المتابعة",
    ),
    "watchlist_remove": MessageLookupByLibrary.simpleMessage(
      "إزالة من قائمة المتابعة",
    ),
    "welcome_dialog_message": MessageLookupByLibrary.simpleMessage(
      "تم تمويل حسابك بنجاح. يمكنك الآن البدء في ممارسة استراتيجيات التداول الخاصة بك دون مخاطر.",
    ),
    "welcome_subtitle": MessageLookupByLibrary.simpleMessage(
      "بيانات السوق، الرسوم البيانية، والمزيد - كل ذلك في مكان واحد.",
    ),
    "welcome_title": MessageLookupByLibrary.simpleMessage(
      "مرحباً بك مرة أخرى!!",
    ),
    "your_watchlist_title": MessageLookupByLibrary.simpleMessage(
      "قائمة المراقبة",
    ),
  };
}
