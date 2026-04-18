// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(symbol) => "${symbol} has been added to your watchlist";

  static String m1(symbol) => "${symbol} has been removed from your watchlist";

  static String m2(count) => "${count}d ago";

  static String m3(count) => "${count}h ago";

  static String m4(count) => "${count}m ago";

  static String m5(name) => "Exchange rate between ${name} and Egyptian Pound";

  static String m6(email) => "We\'ve sent a verification link to\n${email}";

  static String m7(symbol, error) => "Failed to remove ${symbol}: ${error}";

  static String m8(count) => "${count} Buy";

  static String m9(count) => "${count} Neutral";

  static String m10(count) => "${count} Sell";

  static String m11(name) => "Hello, ${name}";

  static String m12(p, sd) => "P: ${p}, SD: ${sd}";

  static String m13(defaultPeriod) =>
      "Number of candles used for calculation (Default: ${defaultPeriod})";

  static String m14(period) => "Period: ${period}";

  static String m15(defaultStdDev) =>
      "Distance of bands from the middle line (Default: ${defaultStdDev}σ)";

  static String m16(balance) => "Available Balance: EGP ${balance}";

  static String m17(symbol) => "Bought ${symbol} without protection";

  static String m18(total) => "Estimated Total: EGP ${total}";

  static String m19(symbol, msg) => "Monitoring ${symbol} — ${msg}";

  static String m20(alert) => "Alert only at ${alert}% loss";

  static String m21(alert, sell) => "Alert: ${alert}% / Sell: ${sell}%";

  static String m22(action) => "PLACE ${action} ORDER";

  static String m23(symbol) => "Enable capital protection for ${symbol}?";

  static String m24(alert) =>
      "Alert only at ${alert}% loss. No automatic selling.";

  static String m25(alert, sell) =>
      "Alert at ${alert}% loss, auto-sell at ${sell}% loss.";

  static String m26(qty, symbol) => "Sold ${qty} shares of ${symbol}";

  static String m27(count) => "${count} Shares";

  static String m28(name) => "Reply to ${name}...";

  static String m29(name) => "Replying to ${name}";

  static String m30(count) => "View ${count} replies";

  static String m31(count) => "${count} posts";

  static String m32(symbol) => "Removed ${symbol} from watchlist";

  static String m33(percent) => "Alert at ${percent}% loss";

  static String m34(percent) => "Auto-sell at ${percent}% loss";

  static String m35(error) => "Failed to remove rule: ${error}";

  static String m36(error) => "Failed to save rule: ${error}";

  static String m37(count) => "Holdings (${count})";

  static String m38(alert, sell) =>
      "Protection Active (Alert: ${alert}% / Sell: ${sell}%)";

  static String m39(symbol) => "Protection removed for ${symbol}";

  static String m40(symbol) => "Protection rule saved for ${symbol}";

  static String m41(symbol) => "Protection rule updated for ${symbol}";

  static String m42(symbol) => "Start the discussion for ${symbol}!";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "about_developer": MessageLookupByLibrary.simpleMessage(
      "About the Developer",
    ),
    "about_developer_description": MessageLookupByLibrary.simpleMessage(
      "Developed by Mohamed Heiba — Software Engineering student specializing in Flutter and AI integrations.",
    ),
    "about_egx": MessageLookupByLibrary.simpleMessage("About EGX"),
    "about_egx360": MessageLookupByLibrary.simpleMessage("About EGX360"),
    "about_egx360_description": MessageLookupByLibrary.simpleMessage(
      "EGX360 is a modern stock market simulator app for the Egyptian Exchange, helping users learn, practice, and explore trading safely with virtual funds.",
    ),
    "about_section": MessageLookupByLibrary.simpleMessage("ABOUT"),
    "about_version": MessageLookupByLibrary.simpleMessage("Version 1.0.0"),
    "account_actions_section": MessageLookupByLibrary.simpleMessage(
      "ACCOUNT ACTIONS",
    ),
    "account_deleted": MessageLookupByLibrary.simpleMessage("Account Deleted"),
    "account_deleted_message": MessageLookupByLibrary.simpleMessage(
      "Your account has been permanently removed.",
    ),
    "account_deletion_failed": MessageLookupByLibrary.simpleMessage(
      "Account deletion failed.",
    ),
    "account_section": MessageLookupByLibrary.simpleMessage("ACCOUNT"),
    "active_sessions": MessageLookupByLibrary.simpleMessage("Active Sessions"),
    "active_sessions_description": MessageLookupByLibrary.simpleMessage(
      "Your account is currently active on this device only.",
    ),
    "active_sessions_subtitle": MessageLookupByLibrary.simpleMessage(
      "View where your account is currently logged in",
    ),
    "ai_news_summary": MessageLookupByLibrary.simpleMessage("AI News Summary"),
    "alert_summry": MessageLookupByLibrary.simpleMessage(
      "This summary was generated by AI and should be used for informational purposes only.",
    ),
    "all_alerts_muted": MessageLookupByLibrary.simpleMessage(
      "All in-app alerts muted",
    ),
    "allow_notifications": MessageLookupByLibrary.simpleMessage(
      "Allow Notifications",
    ),
    "appTitle": MessageLookupByLibrary.simpleMessage("EGX360"),
    "app_details_section": MessageLookupByLibrary.simpleMessage("APP DETAILS"),
    "app_updates": MessageLookupByLibrary.simpleMessage("App Updates"),
    "app_updates_subtitle": MessageLookupByLibrary.simpleMessage(
      "New features and versions",
    ),
    "app_version": MessageLookupByLibrary.simpleMessage("App Version"),
    "app_version_number": MessageLookupByLibrary.simpleMessage("1.0.0 (Beta)"),
    "apply_language": MessageLookupByLibrary.simpleMessage("Apply Language"),
    "arabic": MessageLookupByLibrary.simpleMessage("العربية"),
    "articles_analyzed": MessageLookupByLibrary.simpleMessage(
      "Articles Analyzed",
    ),
    "asset_details_about": MessageLookupByLibrary.simpleMessage("About"),
    "asset_details_ai_generated": MessageLookupByLibrary.simpleMessage(
      "AI Generated",
    ),
    "asset_details_ai_summary": MessageLookupByLibrary.simpleMessage(
      "AI Summary",
    ),
    "asset_details_ai_summary_title": MessageLookupByLibrary.simpleMessage(
      "AI News Summary",
    ),
    "asset_details_arabic_name": MessageLookupByLibrary.simpleMessage(
      "Arabic Name",
    ),
    "asset_details_avg_volume": MessageLookupByLibrary.simpleMessage(
      "Avg Volume",
    ),
    "asset_details_back_news": MessageLookupByLibrary.simpleMessage(
      "Back to news list",
    ),
    "asset_details_company_profile": MessageLookupByLibrary.simpleMessage(
      "Company Profile",
    ),
    "asset_details_constituents": MessageLookupByLibrary.simpleMessage(
      "Constituents",
    ),
    "asset_details_egp": MessageLookupByLibrary.simpleMessage("EGP"),
    "asset_details_error_load_crypto_hist":
        MessageLookupByLibrary.simpleMessage(
          "Error fetching crypto historical data",
        ),
    "asset_details_error_load_gauge": MessageLookupByLibrary.simpleMessage(
      "Gauge candle fetch error",
    ),
    "asset_details_error_load_material": MessageLookupByLibrary.simpleMessage(
      "Error fetching material price",
    ),
    "asset_details_error_load_stock_candles":
        MessageLookupByLibrary.simpleMessage("Error fetching stock candles"),
    "asset_details_error_load_ticker": MessageLookupByLibrary.simpleMessage(
      "Error fetching 24hr ticker",
    ),
    "asset_details_error_update_stock_candles":
        MessageLookupByLibrary.simpleMessage("Error updating stock candles"),
    "asset_details_gold_18k": MessageLookupByLibrary.simpleMessage("18k Gold"),
    "asset_details_gold_21k": MessageLookupByLibrary.simpleMessage("21k Gold"),
    "asset_details_gold_24k": MessageLookupByLibrary.simpleMessage("24k Gold"),
    "asset_details_gold_bar_100g": MessageLookupByLibrary.simpleMessage(
      "Gold Bar 100g",
    ),
    "asset_details_gold_bar_250g": MessageLookupByLibrary.simpleMessage(
      "Gold Bar 250g",
    ),
    "asset_details_gold_bar_50g": MessageLookupByLibrary.simpleMessage(
      "Gold Bar 50g",
    ),
    "asset_details_gold_ounce": MessageLookupByLibrary.simpleMessage(
      "Gold Ounce",
    ),
    "asset_details_gold_pound": MessageLookupByLibrary.simpleMessage(
      "Gold Pound",
    ),
    "asset_details_high": MessageLookupByLibrary.simpleMessage("High"),
    "asset_details_index_label": MessageLookupByLibrary.simpleMessage(
      "EGX • Index",
    ),
    "asset_details_isin_code": MessageLookupByLibrary.simpleMessage(
      "ISIN Code",
    ),
    "asset_details_key_stats": MessageLookupByLibrary.simpleMessage(
      "Key Statistics",
    ),
    "asset_details_latest_news": MessageLookupByLibrary.simpleMessage(
      "Latest News",
    ),
    "asset_details_listing_date": MessageLookupByLibrary.simpleMessage(
      "Listing Date",
    ),
    "asset_details_local_prices": MessageLookupByLibrary.simpleMessage(
      "Local Prices (EGP)",
    ),
    "asset_details_low": MessageLookupByLibrary.simpleMessage("Low"),
    "asset_details_market_data": MessageLookupByLibrary.simpleMessage(
      "Market Data",
    ),
    "asset_details_mkt_cap": MessageLookupByLibrary.simpleMessage("Mkt Cap"),
    "asset_details_news_fail": MessageLookupByLibrary.simpleMessage(
      "Summarization Failed",
    ),
    "asset_details_news_fail_msg": MessageLookupByLibrary.simpleMessage(
      "Failed to generate summary. Please try again later.",
    ),
    "asset_details_news_insufficient": MessageLookupByLibrary.simpleMessage(
      "Insufficient News",
    ),
    "asset_details_news_insufficient_msg": MessageLookupByLibrary.simpleMessage(
      "Not enough recent news to generate a meaningful summary. At least 3 articles are required.",
    ),
    "asset_details_news_no_news": MessageLookupByLibrary.simpleMessage(
      "No News Available",
    ),
    "asset_details_news_no_news_msg": MessageLookupByLibrary.simpleMessage(
      "There is no news available for this asset to summarize.",
    ),
    "asset_details_no_chart_data": MessageLookupByLibrary.simpleMessage(
      "No Data Available",
    ),
    "asset_details_no_description": MessageLookupByLibrary.simpleMessage(
      "No description available.",
    ),
    "asset_details_no_news_available": MessageLookupByLibrary.simpleMessage(
      "No news available for this asset",
    ),
    "asset_details_no_posts": MessageLookupByLibrary.simpleMessage(
      "No posts yet for this stock",
    ),
    "asset_details_open": MessageLookupByLibrary.simpleMessage("Open"),
    "asset_details_performance": MessageLookupByLibrary.simpleMessage(
      "Performance",
    ),
    "asset_details_post_like_error": MessageLookupByLibrary.simpleMessage(
      "Could not like post",
    ),
    "asset_details_post_save_error": MessageLookupByLibrary.simpleMessage(
      "Could not save post",
    ),
    "asset_details_prev_close": MessageLookupByLibrary.simpleMessage(
      "Prev Close",
    ),
    "asset_details_read_full": MessageLookupByLibrary.simpleMessage(
      "Read Full Article",
    ),
    "asset_details_silver_925": MessageLookupByLibrary.simpleMessage(
      "Silver 925",
    ),
    "asset_details_silver_999": MessageLookupByLibrary.simpleMessage(
      "Silver 999",
    ),
    "asset_details_stock_label": MessageLookupByLibrary.simpleMessage(
      "EGX • Stock",
    ),
    "asset_details_summarizing": MessageLookupByLibrary.simpleMessage(
      "Summarizing...",
    ),
    "asset_details_tab_community": MessageLookupByLibrary.simpleMessage(
      "Community",
    ),
    "asset_details_tab_live_chat": MessageLookupByLibrary.simpleMessage(
      "Live Chat",
    ),
    "asset_details_tab_news": MessageLookupByLibrary.simpleMessage("News"),
    "asset_details_tab_overview": MessageLookupByLibrary.simpleMessage(
      "Overview",
    ),
    "asset_details_technicals": MessageLookupByLibrary.simpleMessage(
      "Technicals",
    ),
    "asset_details_usd": MessageLookupByLibrary.simpleMessage("USD"),
    "asset_details_volatility": MessageLookupByLibrary.simpleMessage(
      "Volatility",
    ),
    "asset_details_volume": MessageLookupByLibrary.simpleMessage("Volume"),
    "asset_details_watchlist_added": MessageLookupByLibrary.simpleMessage(
      "Added to Watchlist",
    ),
    "asset_details_watchlist_added_msg": m0,
    "asset_details_watchlist_error": MessageLookupByLibrary.simpleMessage(
      "Could not update watchlist",
    ),
    "asset_details_watchlist_removed": MessageLookupByLibrary.simpleMessage(
      "Removed from Watchlist",
    ),
    "asset_details_watchlist_removed_msg": m1,
    "asset_details_website": MessageLookupByLibrary.simpleMessage("Website"),
    "auth_sign_in": MessageLookupByLibrary.simpleMessage("Sign in"),
    "auth_sign_up": MessageLookupByLibrary.simpleMessage("Sign up"),
    "bio": MessageLookupByLibrary.simpleMessage("Bio"),
    "bio_hint": MessageLookupByLibrary.simpleMessage(
      "Tell us a bit about yourself...",
    ),
    "button_cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "button_ok": MessageLookupByLibrary.simpleMessage("OK"),
    "button_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "button_submit": MessageLookupByLibrary.simpleMessage("Submit"),
    "categories_section": MessageLookupByLibrary.simpleMessage("CATEGORIES"),
    "change_password": MessageLookupByLibrary.simpleMessage("Change Password"),
    "change_password_subtitle": MessageLookupByLibrary.simpleMessage(
      "Update your account password",
    ),
    "change_password_title": MessageLookupByLibrary.simpleMessage(
      "Change Password",
    ),
    "chart_candlestick": MessageLookupByLibrary.simpleMessage("Candlestick"),
    "chart_header_no_results": MessageLookupByLibrary.simpleMessage(
      "No results",
    ),
    "chart_header_search_hint": MessageLookupByLibrary.simpleMessage(
      "Search...",
    ),
    "chart_header_select": MessageLookupByLibrary.simpleMessage("Select"),
    "chart_header_select_crypto": MessageLookupByLibrary.simpleMessage(
      "Select Crypto",
    ),
    "chart_header_toggle_watchlist": MessageLookupByLibrary.simpleMessage(
      "Toggle Watchlist",
    ),
    "chart_line": MessageLookupByLibrary.simpleMessage("Line"),
    "chart_loading": MessageLookupByLibrary.simpleMessage("Loading chart..."),
    "chart_type_bars": MessageLookupByLibrary.simpleMessage("Bars"),
    "chart_type_bars_desc": MessageLookupByLibrary.simpleMessage(
      "OHLC bar chart",
    ),
    "chart_type_candles": MessageLookupByLibrary.simpleMessage("Candles"),
    "chart_type_candles_desc": MessageLookupByLibrary.simpleMessage(
      "Traditional candlestick chart",
    ),
    "chart_type_heikin_ashi": MessageLookupByLibrary.simpleMessage(
      "Heikin Ashi",
    ),
    "chart_type_heikin_ashi_desc": MessageLookupByLibrary.simpleMessage(
      "Smoothed trend candles",
    ),
    "chart_type_line": MessageLookupByLibrary.simpleMessage("Line"),
    "chart_type_line_desc": MessageLookupByLibrary.simpleMessage(
      "Simple line chart",
    ),
    "chart_type_menu_title": MessageLookupByLibrary.simpleMessage("Chart Type"),
    "chart_type_renko": MessageLookupByLibrary.simpleMessage("Renko"),
    "chart_type_renko_desc": MessageLookupByLibrary.simpleMessage(
      "Brick-based chart",
    ),
    "check_internet_connection": MessageLookupByLibrary.simpleMessage(
      "Please check your internet connection.",
    ),
    "choose_theme": MessageLookupByLibrary.simpleMessage(
      "Choose your preferred theme",
    ),
    "community_all": MessageLookupByLibrary.simpleMessage("All"),
    "community_all_feeds": MessageLookupByLibrary.simpleMessage("All Feeds"),
    "community_bearish": MessageLookupByLibrary.simpleMessage("Bearish"),
    "community_bullish": MessageLookupByLibrary.simpleMessage("Bullish"),
    "community_communities": MessageLookupByLibrary.simpleMessage(
      "COMMUNITIES",
    ),
    "community_follow": MessageLookupByLibrary.simpleMessage("Follow"),
    "community_followers": MessageLookupByLibrary.simpleMessage("Followers"),
    "community_following": MessageLookupByLibrary.simpleMessage("Following"),
    "community_just_now": MessageLookupByLibrary.simpleMessage("Just now"),
    "community_like_failed": MessageLookupByLibrary.simpleMessage(
      "Could not like post",
    ),
    "community_login_to_bookmark": MessageLookupByLibrary.simpleMessage(
      "Please login to bookmark posts",
    ),
    "community_login_to_like": MessageLookupByLibrary.simpleMessage(
      "Please login to like posts",
    ),
    "community_no_posts": MessageLookupByLibrary.simpleMessage("No posts yet"),
    "community_posts": MessageLookupByLibrary.simpleMessage("Posts"),
    "community_save_failed": MessageLookupByLibrary.simpleMessage(
      "Could not save post",
    ),
    "community_time_ago_days": m2,
    "community_time_ago_hours": m3,
    "community_time_ago_minutes": m4,
    "community_title": MessageLookupByLibrary.simpleMessage("Community"),
    "community_trending_topics": MessageLookupByLibrary.simpleMessage(
      "Trending Topics",
    ),
    "community_user": MessageLookupByLibrary.simpleMessage("User"),
    "community_who_to_follow": MessageLookupByLibrary.simpleMessage(
      "Who to follow",
    ),
    "confirmPassword": MessageLookupByLibrary.simpleMessage(
      "Please confirm your password.",
    ),
    "confirm_logout": MessageLookupByLibrary.simpleMessage("Confirm Logout"),
    "confirm_logout_message": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to logout?",
    ),
    "contact_report": MessageLookupByLibrary.simpleMessage(
      "Contact & Report Issue",
    ),
    "contact_report_subtitle": MessageLookupByLibrary.simpleMessage(
      "Send us an email if you need help or found a problem.",
    ),
    "continue_with": MessageLookupByLibrary.simpleMessage("or continue with"),
    "copyright": MessageLookupByLibrary.simpleMessage(
      "© 2025 EGX App. All rights reserved.",
    ),
    "copyright_notice": MessageLookupByLibrary.simpleMessage(
      "© 2025 EGX360. All rights reserved.\nBuilt with Flutter & Firebase.",
    ),
    "create_account": MessageLookupByLibrary.simpleMessage("Create an account"),
    "create_password_confirm_new": MessageLookupByLibrary.simpleMessage(
      "Confirm New Password",
    ),
    "create_password_description": MessageLookupByLibrary.simpleMessage(
      "Set a strong new password to secure your account.",
    ),
    "create_password_new": MessageLookupByLibrary.simpleMessage("New Password"),
    "create_password_remember": MessageLookupByLibrary.simpleMessage(
      "Remembered your password? ",
    ),
    "create_password_title": MessageLookupByLibrary.simpleMessage(
      "Create New Password",
    ),
    "create_password_update_button": MessageLookupByLibrary.simpleMessage(
      "Update Password",
    ),
    "currency_desc": m5,
    "currency_sector": MessageLookupByLibrary.simpleMessage("Currency"),
    "current_password": MessageLookupByLibrary.simpleMessage(
      "Current Password",
    ),
    "current_session_section": MessageLookupByLibrary.simpleMessage(
      "CURRENT SESSION",
    ),
    "dark": MessageLookupByLibrary.simpleMessage("Dark"),
    "dark_mode": MessageLookupByLibrary.simpleMessage("Dark Mode"),
    "data_source_1_content": MessageLookupByLibrary.simpleMessage(
      "We fetch real-time stock quotes, indices, and trading volumes from TradingView via TDV and store them securely in our cloud for fast access.",
    ),
    "data_source_1_title": MessageLookupByLibrary.simpleMessage(
      "1. TradingView (TDV)",
    ),
    "data_source_2_content": MessageLookupByLibrary.simpleMessage(
      "We scrape local gold prices from trusted sources to provide accurate and up-to-date pricing for investors.",
    ),
    "data_source_2_title": MessageLookupByLibrary.simpleMessage(
      "2. Gold Local Prices",
    ),
    "data_source_3_content": MessageLookupByLibrary.simpleMessage(
      "Access past stock and index data for analysis, charting, and backtesting.",
    ),
    "data_source_3_title": MessageLookupByLibrary.simpleMessage(
      "3. Historical Market Data",
    ),
    "data_source_4_content": MessageLookupByLibrary.simpleMessage(
      "Aggregated news from verified financial and economic outlets to keep you updated with market events.",
    ),
    "data_source_4_title": MessageLookupByLibrary.simpleMessage(
      "4. Financial News",
    ),
    "data_source_5_content": MessageLookupByLibrary.simpleMessage(
      "Integrations with trusted APIs provide analytics, charts, and additional market information.",
    ),
    "data_source_5_title": MessageLookupByLibrary.simpleMessage(
      "5. Third-Party APIs",
    ),
    "data_sources": MessageLookupByLibrary.simpleMessage("Data Sources"),
    "data_sources_description": MessageLookupByLibrary.simpleMessage(
      "Understand where EGX360 gets its market data.",
    ),
    "data_sources_intro": MessageLookupByLibrary.simpleMessage(
      "EGX360 aggregates data from reliable and trusted sources to provide accurate market insights.",
    ),
    "data_sources_page_title": MessageLookupByLibrary.simpleMessage(
      "Data Sources",
    ),
    "data_sources_subtitle": MessageLookupByLibrary.simpleMessage(
      "Understand where EGX360 gets its market data from.",
    ),
    "delete": MessageLookupByLibrary.simpleMessage("Delete"),
    "delete_account": MessageLookupByLibrary.simpleMessage("Delete Account"),
    "delete_account_confirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to permanently delete your account? This action cannot be undone.",
    ),
    "delete_account_subtitle": MessageLookupByLibrary.simpleMessage(
      "Permanently remove your data and account",
    ),
    "delete_action": MessageLookupByLibrary.simpleMessage("Delete"),
    "details_asset_fallback": MessageLookupByLibrary.simpleMessage("Asset"),
    "details_avg_volume_30d": MessageLookupByLibrary.simpleMessage(
      "Average Volume (30D)",
    ),
    "details_circulating_supply": MessageLookupByLibrary.simpleMessage(
      "Circulating supply",
    ),
    "details_fully_diluted_mc": MessageLookupByLibrary.simpleMessage(
      "Fully diluted market cap",
    ),
    "details_key_stats": MessageLookupByLibrary.simpleMessage("Key stats"),
    "details_market_cap": MessageLookupByLibrary.simpleMessage(
      "Market capitalization",
    ),
    "details_market_closed": MessageLookupByLibrary.simpleMessage(
      "Market closed",
    ),
    "details_market_open": MessageLookupByLibrary.simpleMessage("Market open"),
    "details_no_asset": MessageLookupByLibrary.simpleMessage(
      "No asset selected",
    ),
    "details_seasonals": MessageLookupByLibrary.simpleMessage("Seasonals"),
    "details_spot": MessageLookupByLibrary.simpleMessage("Spot"),
    "details_technicals": MessageLookupByLibrary.simpleMessage("Technicals"),
    "details_vol_mc_ratio": MessageLookupByLibrary.simpleMessage(
      "Volume / Market Cap",
    ),
    "details_volume": MessageLookupByLibrary.simpleMessage("Volume"),
    "details_volume_24h": MessageLookupByLibrary.simpleMessage(
      "Trading Volume 24h",
    ),
    "disable_notifications_message": MessageLookupByLibrary.simpleMessage(
      "Please disable notifications from system settings.",
    ),
    "drawing_tools_clear_all": MessageLookupByLibrary.simpleMessage(
      "Clear All",
    ),
    "drawing_tools_color": MessageLookupByLibrary.simpleMessage("Color"),
    "drawing_tools_done": MessageLookupByLibrary.simpleMessage("Done"),
    "drawing_tools_edit_title": MessageLookupByLibrary.simpleMessage(
      "Edit Drawing",
    ),
    "drawing_tools_h_line": MessageLookupByLibrary.simpleMessage("H-Line"),
    "drawing_tools_line": MessageLookupByLibrary.simpleMessage("Line"),
    "drawing_tools_preview": MessageLookupByLibrary.simpleMessage("Preview"),
    "drawing_tools_px": MessageLookupByLibrary.simpleMessage("px"),
    "drawing_tools_rect": MessageLookupByLibrary.simpleMessage("Rect"),
    "drawing_tools_select_tool": MessageLookupByLibrary.simpleMessage(
      "Select Tool",
    ),
    "drawing_tools_title": MessageLookupByLibrary.simpleMessage(
      "Drawing Tools",
    ),
    "drawing_tools_v_line": MessageLookupByLibrary.simpleMessage("V-Line"),
    "drawing_tools_width": MessageLookupByLibrary.simpleMessage("Width"),
    "edit_profile": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "edit_profile_subtitle": MessageLookupByLibrary.simpleMessage(
      "Change your name, avatar, bio",
    ),
    "egx360_app_name": MessageLookupByLibrary.simpleMessage("EGX360"),
    "email_address": MessageLookupByLibrary.simpleMessage("Email Address"),
    "email_label": MessageLookupByLibrary.simpleMessage("Email"),
    "email_verification_message": MessageLookupByLibrary.simpleMessage(
      "Please verify your email to continue...",
    ),
    "email_verification_sent": m6,
    "email_verified_message": MessageLookupByLibrary.simpleMessage(
      "Your account has been successfully verified.",
    ),
    "email_verified_success": MessageLookupByLibrary.simpleMessage(
      "Email Verified!!",
    ),
    "english": MessageLookupByLibrary.simpleMessage("English"),
    "enterEmail": MessageLookupByLibrary.simpleMessage(
      "Please enter your email address.",
    ),
    "enterName": MessageLookupByLibrary.simpleMessage(
      "Please enter your name.",
    ),
    "enterPassword": MessageLookupByLibrary.simpleMessage(
      "Please enter your password.",
    ),
    "error_auth_failed_msg": MessageLookupByLibrary.simpleMessage(
      "Failed to complete sign-in. Please try again.",
    ),
    "error_auth_title": MessageLookupByLibrary.simpleMessage(
      "Authentication Error",
    ),
    "error_check_connection_msg": MessageLookupByLibrary.simpleMessage(
      "Please check your internet connection.",
    ),
    "error_current_password_incorrect_msg":
        MessageLookupByLibrary.simpleMessage(
          "The current password you entered is incorrect.",
        ),
    "error_deletion_failed_title": MessageLookupByLibrary.simpleMessage(
      "Deletion Failed",
    ),
    "error_email_already_in_use_msg": MessageLookupByLibrary.simpleMessage(
      "This email is already in use.",
    ),
    "error_email_already_registered_title":
        MessageLookupByLibrary.simpleMessage("Email Already Registered"),
    "error_failed_change_password_msg": MessageLookupByLibrary.simpleMessage(
      "Failed to change password.",
    ),
    "error_google_cancelled_msg": MessageLookupByLibrary.simpleMessage(
      "Google sign-in was cancelled by you.",
    ),
    "error_google_cancelled_title": MessageLookupByLibrary.simpleMessage(
      "Cancelled",
    ),
    "error_incorrect_email_pass_msg": MessageLookupByLibrary.simpleMessage(
      "Incorrect email or password.",
    ),
    "error_invalid_credentials_title": MessageLookupByLibrary.simpleMessage(
      "Invalid Credentials",
    ),
    "error_invalid_email": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid email address.",
    ),
    "error_invalid_password_title": MessageLookupByLibrary.simpleMessage(
      "Invalid Password",
    ),
    "error_label": MessageLookupByLibrary.simpleMessage("Error"),
    "error_loading_licenses": MessageLookupByLibrary.simpleMessage(
      "Error loading licenses",
    ),
    "error_logout_failed_title": MessageLookupByLibrary.simpleMessage(
      "Logout Failed",
    ),
    "error_network": MessageLookupByLibrary.simpleMessage(
      "Network error, please try again.",
    ),
    "error_no_account_found_msg": MessageLookupByLibrary.simpleMessage(
      "No account found with this email.",
    ),
    "error_no_connection_title": MessageLookupByLibrary.simpleMessage(
      "No Connection",
    ),
    "error_password_too_short": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters.",
    ),
    "error_required_field": MessageLookupByLibrary.simpleMessage(
      "This field is required.",
    ),
    "error_signin_title": MessageLookupByLibrary.simpleMessage("Sign-in Error"),
    "error_signup_title": MessageLookupByLibrary.simpleMessage("Signup Error"),
    "error_something_wrong_msg": MessageLookupByLibrary.simpleMessage(
      "Something went wrong.",
    ),
    "error_unexpected_title": MessageLookupByLibrary.simpleMessage(
      "Unexpected Error",
    ),
    "error_user_not_found_title": MessageLookupByLibrary.simpleMessage(
      "User Not Found",
    ),
    "eur_label": MessageLookupByLibrary.simpleMessage("EUR"),
    "failed_mark_all_read": MessageLookupByLibrary.simpleMessage(
      "Failed to mark all as read",
    ),
    "failed_to_change_password": MessageLookupByLibrary.simpleMessage(
      "Failed to change password.",
    ),
    "failed_to_load_data": MessageLookupByLibrary.simpleMessage(
      "Failed to load data",
    ),
    "failed_to_load_notifications": MessageLookupByLibrary.simpleMessage(
      "Failed to load notifications",
    ),
    "failed_to_load_watchlist": MessageLookupByLibrary.simpleMessage(
      "Failed to load full watchlist",
    ),
    "failed_to_refresh_data": MessageLookupByLibrary.simpleMessage(
      "Failed to refresh data",
    ),
    "failed_to_remove_from_watchlist_msg": m7,
    "failed_to_update_image": MessageLookupByLibrary.simpleMessage(
      "Failed to update image.",
    ),
    "faqs_section": MessageLookupByLibrary.simpleMessage("FAQs"),
    "forgot_description": MessageLookupByLibrary.simpleMessage(
      "Enter your email below and we’ll send you a link to reset your password.",
    ),
    "forgot_loading": MessageLookupByLibrary.simpleMessage("Sending..."),
    "forgot_password": MessageLookupByLibrary.simpleMessage("Forgot password?"),
    "forgot_remember": MessageLookupByLibrary.simpleMessage(
      "Remember your password? ",
    ),
    "forgot_send_link": MessageLookupByLibrary.simpleMessage("Send Reset Link"),
    "full_name": MessageLookupByLibrary.simpleMessage("Full Name"),
    "full_name_hint": MessageLookupByLibrary.simpleMessage(
      "Enter your full name",
    ),
    "gauge_bollinger_desc": MessageLookupByLibrary.simpleMessage(
      "Bollinger Band Buy Signal (Price at Lower Band + Oversold RSI)",
    ),
    "gauge_buy": MessageLookupByLibrary.simpleMessage("Buy"),
    "gauge_buy_count": m8,
    "gauge_neutral": MessageLookupByLibrary.simpleMessage("Neutral"),
    "gauge_neutral_count": m9,
    "gauge_oscillators": MessageLookupByLibrary.simpleMessage("Oscillators"),
    "gauge_sell": MessageLookupByLibrary.simpleMessage("Sell"),
    "gauge_sell_count": m10,
    "gauge_strong_buy": MessageLookupByLibrary.simpleMessage("Strong Buy"),
    "gauge_strong_sell": MessageLookupByLibrary.simpleMessage("Strong Sell"),
    "gauge_trend_ma": MessageLookupByLibrary.simpleMessage(
      "Trend (Moving Averages)",
    ),
    "gbp_label": MessageLookupByLibrary.simpleMessage("GBP"),
    "general_section": MessageLookupByLibrary.simpleMessage("GENERAL"),
    "get_started": MessageLookupByLibrary.simpleMessage("Get started"),
    "gold_21k_desc": MessageLookupByLibrary.simpleMessage(
      "Gold 21k Price in EGP",
    ),
    "gold_21k_title": MessageLookupByLibrary.simpleMessage("Gold 21k"),
    "help_support": MessageLookupByLibrary.simpleMessage("Help & Support"),
    "home_greeting": m11,
    "home_title": MessageLookupByLibrary.simpleMessage("Home"),
    "how_to_step_1_content": MessageLookupByLibrary.simpleMessage(
      "Navigate through indices, sectors, and stocks using the bottom menu and search bar.",
    ),
    "how_to_step_1_title": MessageLookupByLibrary.simpleMessage(
      "1. Explore Markets",
    ),
    "how_to_step_2_content": MessageLookupByLibrary.simpleMessage(
      "Access live market prices, volume, and historical trends for informed decision-making.",
    ),
    "how_to_step_2_title": MessageLookupByLibrary.simpleMessage(
      "2. Real-Time Data",
    ),
    "how_to_step_3_content": MessageLookupByLibrary.simpleMessage(
      "Track your investments, create watchlists, and get alerts on price movements.",
    ),
    "how_to_step_3_title": MessageLookupByLibrary.simpleMessage(
      "3. Portfolio Management",
    ),
    "how_to_step_4_content": MessageLookupByLibrary.simpleMessage(
      "Use charts, indicators, and AI insights to analyze market patterns.",
    ),
    "how_to_step_4_title": MessageLookupByLibrary.simpleMessage(
      "4. Analysis Tools",
    ),
    "how_to_use_description": MessageLookupByLibrary.simpleMessage(
      "Learn how to explore EGX360 features effectively.",
    ),
    "how_to_use_egx360": MessageLookupByLibrary.simpleMessage(
      "How to use EGX360?",
    ),
    "how_to_use_intro": MessageLookupByLibrary.simpleMessage(
      "EGX360 is designed to give you real-time market data and analytics. Follow these steps to maximize your experience:",
    ),
    "how_to_use_page_title": MessageLookupByLibrary.simpleMessage(
      "How to use EGX360",
    ),
    "how_to_use_subtitle": MessageLookupByLibrary.simpleMessage(
      "Learn how to explore markets and access real-time data.",
    ),
    "incorrect_current_password": MessageLookupByLibrary.simpleMessage(
      "The current password you entered is incorrect.",
    ),
    "indicators_apply": MessageLookupByLibrary.simpleMessage("Apply Settings"),
    "indicators_bollinger": MessageLookupByLibrary.simpleMessage(
      "Bollinger Bands",
    ),
    "indicators_bollinger_desc": MessageLookupByLibrary.simpleMessage(
      "Shows price volatility with upper and lower bands around a moving average. Prices tend to bounce within the bands.",
    ),
    "indicators_bollinger_short": MessageLookupByLibrary.simpleMessage(
      "Bollinger",
    ),
    "indicators_bollinger_val": m12,
    "indicators_config_hint": MessageLookupByLibrary.simpleMessage(
      "Tap an indicator to configure its settings",
    ),
    "indicators_default": MessageLookupByLibrary.simpleMessage("Default"),
    "indicators_ema": MessageLookupByLibrary.simpleMessage(
      "Exponential Moving Average (EMA)",
    ),
    "indicators_ema_desc": MessageLookupByLibrary.simpleMessage(
      "Similar to SMA but gives more weight to recent prices, reacting faster to changes.",
    ),
    "indicators_ema_short": MessageLookupByLibrary.simpleMessage("EMA"),
    "indicators_enable": MessageLookupByLibrary.simpleMessage(
      "Enable Indicator",
    ),
    "indicators_normal": MessageLookupByLibrary.simpleMessage("Normal"),
    "indicators_period": MessageLookupByLibrary.simpleMessage("Period"),
    "indicators_period_desc": m13,
    "indicators_period_val": m14,
    "indicators_quick_select": MessageLookupByLibrary.simpleMessage(
      "Quick select:",
    ),
    "indicators_reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "indicators_rsi": MessageLookupByLibrary.simpleMessage(
      "Relative Strength Index (RSI)",
    ),
    "indicators_rsi_desc": MessageLookupByLibrary.simpleMessage(
      "Measures the speed and magnitude of price changes. Values above 70 indicate overbought, below 30 indicate oversold.",
    ),
    "indicators_rsi_short": MessageLookupByLibrary.simpleMessage("RSI"),
    "indicators_sma": MessageLookupByLibrary.simpleMessage(
      "Simple Moving Average (SMA)",
    ),
    "indicators_sma_desc": MessageLookupByLibrary.simpleMessage(
      "Shows the average price over a specified period, helping identify trends.",
    ),
    "indicators_sma_short": MessageLookupByLibrary.simpleMessage("SMA"),
    "indicators_std_dev": MessageLookupByLibrary.simpleMessage(
      "Standard Deviation",
    ),
    "indicators_std_dev_desc": m15,
    "indicators_tight": MessageLookupByLibrary.simpleMessage("Tight"),
    "indicators_title": MessageLookupByLibrary.simpleMessage(
      "Technical Indicators",
    ),
    "indicators_volume": MessageLookupByLibrary.simpleMessage("Volume Bars"),
    "indicators_volume_desc": MessageLookupByLibrary.simpleMessage(
      "Show trading volume at the bottom of the chart",
    ),
    "indicators_wide": MessageLookupByLibrary.simpleMessage("Wide"),
    "invalidEmail": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid email address.",
    ),
    "invalid_password": MessageLookupByLibrary.simpleMessage(
      "Invalid Password",
    ),
    "language": MessageLookupByLibrary.simpleMessage("Language"),
    "language_arabic_subtitle": MessageLookupByLibrary.simpleMessage(
      "اضبط لغة التطبيق إلى العربية",
    ),
    "language_changed": MessageLookupByLibrary.simpleMessage(
      "Language Changed",
    ),
    "language_changed_to_arabic": MessageLookupByLibrary.simpleMessage(
      "تم تغيير اللغة إلى العربية",
    ),
    "language_changed_to_english": MessageLookupByLibrary.simpleMessage(
      "App language set to English",
    ),
    "language_english": MessageLookupByLibrary.simpleMessage("English"),
    "language_english_subtitle": MessageLookupByLibrary.simpleMessage(
      "Set app language to English",
    ),
    "language_name_arabic": MessageLookupByLibrary.simpleMessage("Arabic"),
    "language_name_english": MessageLookupByLibrary.simpleMessage("English"),
    "last_active_now": MessageLookupByLibrary.simpleMessage("Just now"),
    "last_updated": MessageLookupByLibrary.simpleMessage(
      "Last Updated: October 26, 2025",
    ),
    "latest_news_title": MessageLookupByLibrary.simpleMessage("Latest News"),
    "licenses": MessageLookupByLibrary.simpleMessage("Licenses"),
    "light": MessageLookupByLibrary.simpleMessage("Light"),
    "loading": MessageLookupByLibrary.simpleMessage("Loading..."),
    "location_egypt": MessageLookupByLibrary.simpleMessage("Cairo, Egypt"),
    "logged_out": MessageLookupByLibrary.simpleMessage("Logged Out"),
    "logged_out_success": MessageLookupByLibrary.simpleMessage(
      "You have been logged out successfully.",
    ),
    "logout": MessageLookupByLibrary.simpleMessage("Logout"),
    "logout_failed": MessageLookupByLibrary.simpleMessage("Logout failed."),
    "mark_all_read_btn": MessageLookupByLibrary.simpleMessage("Mark all read"),
    "market_alerts": MessageLookupByLibrary.simpleMessage("Market Alerts"),
    "market_alerts_subtitle": MessageLookupByLibrary.simpleMessage(
      "Price movements, volume spikes",
    ),
    "market_cap_label": MessageLookupByLibrary.simpleMessage("Market Cap"),
    "market_closed": MessageLookupByLibrary.simpleMessage("CLOSED"),
    "market_crypto": MessageLookupByLibrary.simpleMessage("Crypto Market"),
    "market_egx": MessageLookupByLibrary.simpleMessage("Egyptian Exchange"),
    "market_indices_title": MessageLookupByLibrary.simpleMessage(
      "Market Indices",
    ),
    "market_label": MessageLookupByLibrary.simpleMessage("Market"),
    "market_live": MessageLookupByLibrary.simpleMessage("LIVE"),
    "market_status_closed": MessageLookupByLibrary.simpleMessage("Closed"),
    "market_status_open": MessageLookupByLibrary.simpleMessage("Open"),
    "market_status_title": MessageLookupByLibrary.simpleMessage(
      "Market Status",
    ),
    "markets_select_asset": MessageLookupByLibrary.simpleMessage(
      "Select an Asset from the list",
    ),
    "markets_title": MessageLookupByLibrary.simpleMessage("Markets"),
    "menu_settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "msg_password_reset": MessageLookupByLibrary.simpleMessage(
      "Password reset instructions were sent if that email exists.",
    ),
    "msg_verification_sent": MessageLookupByLibrary.simpleMessage(
      "A verification code was sent to your email.",
    ),
    "mute_all_alerts": MessageLookupByLibrary.simpleMessage(
      "Mute All App Alerts",
    ),
    "muted": MessageLookupByLibrary.simpleMessage("Muted"),
    "my_portfolio": MessageLookupByLibrary.simpleMessage("My Portfolio"),
    "nameMinChars": MessageLookupByLibrary.simpleMessage(
      "Name must be at least 3 characters.",
    ),
    "name_label": MessageLookupByLibrary.simpleMessage("Full name"),
    "nav_community": MessageLookupByLibrary.simpleMessage("Community"),
    "nav_home": MessageLookupByLibrary.simpleMessage("Home"),
    "nav_markets": MessageLookupByLibrary.simpleMessage("Markets"),
    "nav_menu": MessageLookupByLibrary.simpleMessage("Menu"),
    "nav_search": MessageLookupByLibrary.simpleMessage("Search"),
    "nav_settings": MessageLookupByLibrary.simpleMessage("Settings"),
    "nav_simulation": MessageLookupByLibrary.simpleMessage("Simulation"),
    "need_help": MessageLookupByLibrary.simpleMessage("Need Help?"),
    "need_help_subtitle": MessageLookupByLibrary.simpleMessage(
      "Find quick answers or reach out for support.",
    ),
    "new_password": MessageLookupByLibrary.simpleMessage("New Password"),
    "news_updates": MessageLookupByLibrary.simpleMessage("News Updates"),
    "news_updates_subtitle": MessageLookupByLibrary.simpleMessage(
      "Financial and market news",
    ),
    "no_news_available": MessageLookupByLibrary.simpleMessage(
      "No news available",
    ),
    "no_notifications_msg": MessageLookupByLibrary.simpleMessage(
      "No notifications yet",
    ),
    "no_results": MessageLookupByLibrary.simpleMessage("No results found"),
    "not_available": MessageLookupByLibrary.simpleMessage("N/A"),
    "notification_fallback_title": MessageLookupByLibrary.simpleMessage(
      "Notification",
    ),
    "notification_sounds": MessageLookupByLibrary.simpleMessage(
      "Notification Sounds",
    ),
    "notification_sounds_subtitle": MessageLookupByLibrary.simpleMessage(
      "Play sound for new alerts",
    ),
    "notifications": MessageLookupByLibrary.simpleMessage("Notifications"),
    "notifications_title": MessageLookupByLibrary.simpleMessage(
      "Notifications",
    ),
    "now_label": MessageLookupByLibrary.simpleMessage("Now"),
    "open_source_licenses": MessageLookupByLibrary.simpleMessage(
      "Open Source Licenses",
    ),
    "order_alert_threshold": MessageLookupByLibrary.simpleMessage(
      "📢 Alert Threshold",
    ),
    "order_auto_sell": MessageLookupByLibrary.simpleMessage("Auto-Sell"),
    "order_auto_sell_threshold": MessageLookupByLibrary.simpleMessage(
      "🛡️ Auto-Sell Threshold",
    ),
    "order_available_balance": m16,
    "order_bought_msg": m17,
    "order_buy": MessageLookupByLibrary.simpleMessage("Buy"),
    "order_enable_protection": MessageLookupByLibrary.simpleMessage(
      "Enable Protection",
    ),
    "order_est_total": m18,
    "order_limit": MessageLookupByLibrary.simpleMessage("Limit"),
    "order_market": MessageLookupByLibrary.simpleMessage("Market"),
    "order_monitoring_msg": m19,
    "order_msg_alert": m20,
    "order_msg_both": m21,
    "order_place_order": m22,
    "order_price": MessageLookupByLibrary.simpleMessage("Price"),
    "order_protection_desc": m23,
    "order_protection_enabled": MessageLookupByLibrary.simpleMessage(
      "Protection Enabled 🛡️",
    ),
    "order_protection_info_alert": m24,
    "order_protection_info_both": m25,
    "order_protection_title": MessageLookupByLibrary.simpleMessage(
      "🎉 Trade Successful!",
    ),
    "order_quantity": MessageLookupByLibrary.simpleMessage("Quantity"),
    "order_saving": MessageLookupByLibrary.simpleMessage("Saving..."),
    "order_sell": MessageLookupByLibrary.simpleMessage("Sell"),
    "order_sim_not_available": MessageLookupByLibrary.simpleMessage(
      "Simulation feature is not available right now",
    ),
    "order_skip": MessageLookupByLibrary.simpleMessage("Skip"),
    "order_sold_msg": m26,
    "order_trade_executed": MessageLookupByLibrary.simpleMessage(
      "Trade Executed",
    ),
    "order_valid_qty": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid quantity",
    ),
    "passwordMinChars": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters.",
    ),
    "passwordUpperNumber": MessageLookupByLibrary.simpleMessage(
      "Password must contain an uppercase letter and a number.",
    ),
    "password_changed_success": MessageLookupByLibrary.simpleMessage(
      "Your password has been changed successfully.",
    ),
    "password_label": MessageLookupByLibrary.simpleMessage("Password"),
    "password_updated": MessageLookupByLibrary.simpleMessage(
      "Password Updated",
    ),
    "passwordsNotMatch": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match.",
    ),
    "phone_label": MessageLookupByLibrary.simpleMessage("Phone"),
    "placeholder_email": MessageLookupByLibrary.simpleMessage(
      "you@example.com",
    ),
    "placeholder_name": MessageLookupByLibrary.simpleMessage("Your full name"),
    "placeholder_password": MessageLookupByLibrary.simpleMessage(
      "Enter your password",
    ),
    "policy_agreement": MessageLookupByLibrary.simpleMessage(
      "By continuing, you agree to our Terms of Service and Privacy Policy",
    ),
    "portfolio_title": MessageLookupByLibrary.simpleMessage("Portfolio"),
    "position_avg_buy_price": MessageLookupByLibrary.simpleMessage(
      "Avg. Buy Price",
    ),
    "position_current_price": MessageLookupByLibrary.simpleMessage(
      "Current Price",
    ),
    "position_current_value": MessageLookupByLibrary.simpleMessage(
      "Current Value",
    ),
    "position_my_position": MessageLookupByLibrary.simpleMessage("My Position"),
    "position_pl_short": MessageLookupByLibrary.simpleMessage("P&L"),
    "position_shares": m27,
    "position_shares_owned": MessageLookupByLibrary.simpleMessage(
      "Shares Owned",
    ),
    "position_total_cost": MessageLookupByLibrary.simpleMessage("Total Cost"),
    "position_total_pl": MessageLookupByLibrary.simpleMessage("Total P&L"),
    "post_details_bearish": MessageLookupByLibrary.simpleMessage("Bearish"),
    "post_details_bullish": MessageLookupByLibrary.simpleMessage("Bullish"),
    "post_details_comments_header": MessageLookupByLibrary.simpleMessage(
      "Comments",
    ),
    "post_details_error_add_comment": MessageLookupByLibrary.simpleMessage(
      "Failed to add comment",
    ),
    "post_details_error_load": MessageLookupByLibrary.simpleMessage(
      "Failed to load post",
    ),
    "post_details_error_vote": MessageLookupByLibrary.simpleMessage(
      "Failed to vote",
    ),
    "post_details_no_comments": MessageLookupByLibrary.simpleMessage(
      "No comments yet",
    ),
    "post_details_replies_title": MessageLookupByLibrary.simpleMessage(
      "Replies",
    ),
    "post_details_reply": MessageLookupByLibrary.simpleMessage("Reply"),
    "post_details_reply_to_hint": m28,
    "post_details_replying": MessageLookupByLibrary.simpleMessage("Replying"),
    "post_details_replying_to": m29,
    "post_details_share_thoughts": MessageLookupByLibrary.simpleMessage(
      "Share your thoughts...",
    ),
    "post_details_someone": MessageLookupByLibrary.simpleMessage("Someone"),
    "post_details_user_fallback": MessageLookupByLibrary.simpleMessage("User"),
    "post_details_view_replies": m30,
    "preferences_section": MessageLookupByLibrary.simpleMessage("PREFERENCES"),
    "privacy_intro": MessageLookupByLibrary.simpleMessage(
      "At EGX App, we value your privacy and are committed to protecting your personal information. This Privacy Policy explains how we collect, use, and protect your data when you use our services.",
    ),
    "privacy_policy": MessageLookupByLibrary.simpleMessage("Privacy Policy"),
    "privacy_policy_title": MessageLookupByLibrary.simpleMessage(
      "Privacy Policy",
    ),
    "privacy_section_1_content": MessageLookupByLibrary.simpleMessage(
      "We may collect information such as your name, email address, portfolio preferences, and usage activity within the app to enhance your experience.",
    ),
    "privacy_section_1_title": MessageLookupByLibrary.simpleMessage(
      "1. Information We Collect",
    ),
    "privacy_section_2_content": MessageLookupByLibrary.simpleMessage(
      "Your data helps us provide personalized content, improve app performance, and ensure security of your account.",
    ),
    "privacy_section_2_title": MessageLookupByLibrary.simpleMessage(
      "2. How We Use Your Information",
    ),
    "privacy_section_3_content": MessageLookupByLibrary.simpleMessage(
      "We use secure encryption and authentication methods to protect your data. Your information is not shared with third parties without your consent.",
    ),
    "privacy_section_3_title": MessageLookupByLibrary.simpleMessage(
      "3. Data Protection",
    ),
    "privacy_section_4_content": MessageLookupByLibrary.simpleMessage(
      "We may integrate with trusted services like Firebase or analytics tools for performance tracking and crash reporting.",
    ),
    "privacy_section_4_title": MessageLookupByLibrary.simpleMessage(
      "4. Third-Party Services",
    ),
    "privacy_section_5_content": MessageLookupByLibrary.simpleMessage(
      "You have the right to access, modify, or delete your data. You can request this via the app settings or contact support.",
    ),
    "privacy_section_5_title": MessageLookupByLibrary.simpleMessage(
      "5. Your Rights",
    ),
    "privacy_section_6_content": MessageLookupByLibrary.simpleMessage(
      "We may update this Privacy Policy from time to time. All changes will be reflected here with a new \'Last Updated\' date.",
    ),
    "privacy_section_6_title": MessageLookupByLibrary.simpleMessage(
      "6. Updates to This Policy",
    ),
    "privacy_security": MessageLookupByLibrary.simpleMessage(
      "Privacy & Security",
    ),
    "profile_create_post": MessageLookupByLibrary.simpleMessage("Create Post"),
    "profile_failed_to_create_post": MessageLookupByLibrary.simpleMessage(
      "Failed to create post",
    ),
    "profile_failed_to_follow": MessageLookupByLibrary.simpleMessage(
      "Failed to update follow status",
    ),
    "profile_followers": MessageLookupByLibrary.simpleMessage("Followers"),
    "profile_following": MessageLookupByLibrary.simpleMessage("Following"),
    "profile_headline_hint": MessageLookupByLibrary.simpleMessage("Headline"),
    "profile_idea_published": MessageLookupByLibrary.simpleMessage(
      "Idea published successfully!",
    ),
    "profile_login_to_post": MessageLookupByLibrary.simpleMessage(
      "Please login to create a post",
    ),
    "profile_no_followers": MessageLookupByLibrary.simpleMessage(
      "No followers yet",
    ),
    "profile_no_posts": MessageLookupByLibrary.simpleMessage(
      "No posts shared yet",
    ),
    "profile_not_following_anyone": MessageLookupByLibrary.simpleMessage(
      "Not following anyone yet",
    ),
    "profile_picture_updated": MessageLookupByLibrary.simpleMessage(
      "Profile picture updated successfully!",
    ),
    "profile_post_button": MessageLookupByLibrary.simpleMessage("Post"),
    "profile_post_hint": MessageLookupByLibrary.simpleMessage(
      "Share your market analysis...\nUse \$ for symbols like \$EGX30",
    ),
    "profile_posts": MessageLookupByLibrary.simpleMessage("Posts"),
    "profile_posts_count": m31,
    "profile_suggested_stocks": MessageLookupByLibrary.simpleMessage(
      "SUGGESTED STOCKS",
    ),
    "profile_title": MessageLookupByLibrary.simpleMessage("Profile"),
    "profile_updated_success": MessageLookupByLibrary.simpleMessage(
      "Your profile has been updated successfully!",
    ),
    "profile_user_not_found": MessageLookupByLibrary.simpleMessage(
      "User not found",
    ),
    "range_1d": MessageLookupByLibrary.simpleMessage("1D"),
    "range_1m": MessageLookupByLibrary.simpleMessage("1M"),
    "range_1w": MessageLookupByLibrary.simpleMessage("1W"),
    "range_1y": MessageLookupByLibrary.simpleMessage("1Y"),
    "range_3m": MessageLookupByLibrary.simpleMessage("3M"),
    "range_5d": MessageLookupByLibrary.simpleMessage("5D"),
    "range_5y": MessageLookupByLibrary.simpleMessage("5Y"),
    "range_6m": MessageLookupByLibrary.simpleMessage("6M"),
    "range_all": MessageLookupByLibrary.simpleMessage("All"),
    "register_description": MessageLookupByLibrary.simpleMessage(
      "Join us and start exploring all the amazing features we offer!",
    ),
    "register_have_account": MessageLookupByLibrary.simpleMessage(
      "Already have an account? ",
    ),
    "register_login": MessageLookupByLibrary.simpleMessage("Log In"),
    "removed_from_watchlist_msg": m32,
    "retry_btn": MessageLookupByLibrary.simpleMessage("Retry"),
    "save_changes": MessageLookupByLibrary.simpleMessage("Save Changes"),
    "search_all_news": MessageLookupByLibrary.simpleMessage("All News"),
    "search_asset": MessageLookupByLibrary.simpleMessage("Asset"),
    "search_cat_all": MessageLookupByLibrary.simpleMessage("All"),
    "search_cat_crypto": MessageLookupByLibrary.simpleMessage("Crypto"),
    "search_cat_indices": MessageLookupByLibrary.simpleMessage("Indices"),
    "search_cat_materials": MessageLookupByLibrary.simpleMessage("Materials"),
    "search_cat_stocks": MessageLookupByLibrary.simpleMessage("Stocks"),
    "search_currency_usd": MessageLookupByLibrary.simpleMessage("\$"),
    "search_egp": MessageLookupByLibrary.simpleMessage("EGP"),
    "search_egx_news": MessageLookupByLibrary.simpleMessage("EGX News"),
    "search_hint": MessageLookupByLibrary.simpleMessage("Search"),
    "search_hint_main": MessageLookupByLibrary.simpleMessage(
      "Search symbol...",
    ),
    "search_latest_news": MessageLookupByLibrary.simpleMessage("Latest News"),
    "search_market_movers": MessageLookupByLibrary.simpleMessage(
      "Market Movers",
    ),
    "search_market_overview": MessageLookupByLibrary.simpleMessage(
      "Market Overview",
    ),
    "search_news_details": MessageLookupByLibrary.simpleMessage("News Details"),
    "search_no_content": MessageLookupByLibrary.simpleMessage(
      "No content available.",
    ),
    "search_no_news": MessageLookupByLibrary.simpleMessage("No news available"),
    "search_pts": MessageLookupByLibrary.simpleMessage("Pts"),
    "search_read_original": MessageLookupByLibrary.simpleMessage(
      "Read Original Article",
    ),
    "search_results_not_found": MessageLookupByLibrary.simpleMessage(
      "No results found",
    ),
    "search_tts_check_source": MessageLookupByLibrary.simpleMessage(
      "Please check the source for details",
    ),
    "search_view_all": MessageLookupByLibrary.simpleMessage("View All"),
    "security_section": MessageLookupByLibrary.simpleMessage("SECURITY"),
    "see_all_btn": MessageLookupByLibrary.simpleMessage("See All"),
    "select_language": MessageLookupByLibrary.simpleMessage(
      "Select your preferred language",
    ),
    "send_code": MessageLookupByLibrary.simpleMessage("Send code"),
    "session_active": MessageLookupByLibrary.simpleMessage("Active"),
    "settings_title": MessageLookupByLibrary.simpleMessage("Settings"),
    "sidebar_chg": MessageLookupByLibrary.simpleMessage("Chg"),
    "sidebar_chg_percent": MessageLookupByLibrary.simpleMessage("Chg%"),
    "sidebar_details": MessageLookupByLibrary.simpleMessage("Details"),
    "sidebar_last": MessageLookupByLibrary.simpleMessage("Last"),
    "sidebar_no_assets": MessageLookupByLibrary.simpleMessage(
      "No assets available",
    ),
    "sidebar_no_results": MessageLookupByLibrary.simpleMessage(
      "No results found",
    ),
    "sidebar_search_symbol": MessageLookupByLibrary.simpleMessage(
      "Search Symbol",
    ),
    "sidebar_show_details": MessageLookupByLibrary.simpleMessage(
      "Show Details",
    ),
    "sidebar_show_watchlist": MessageLookupByLibrary.simpleMessage(
      "Show Watchlist",
    ),
    "sidebar_symbol": MessageLookupByLibrary.simpleMessage("Symbol"),
    "sidebar_watchlist": MessageLookupByLibrary.simpleMessage("Watchlist"),
    "sign_google": MessageLookupByLibrary.simpleMessage("Sign in with Google"),
    "silver_999_desc": MessageLookupByLibrary.simpleMessage(
      "Silver 999 Price in EGP",
    ),
    "silver_999_title": MessageLookupByLibrary.simpleMessage("Silver 999"),
    "sim_alert_at_msg": m33,
    "sim_alert_desc": MessageLookupByLibrary.simpleMessage(
      "Notify when loss reaches threshold",
    ),
    "sim_alert_me": MessageLookupByLibrary.simpleMessage("Alert Me"),
    "sim_auto": MessageLookupByLibrary.simpleMessage("AUTO"),
    "sim_auto_sell_at_msg": m34,
    "sim_auto_sell_desc": MessageLookupByLibrary.simpleMessage(
      "Automatically sell when loss reaches threshold",
    ),
    "sim_auto_sell_protection": MessageLookupByLibrary.simpleMessage(
      "Auto-Sell",
    ),
    "sim_available_cash": MessageLookupByLibrary.simpleMessage(
      "Available Cash",
    ),
    "sim_avg_price": MessageLookupByLibrary.simpleMessage("Avg Price"),
    "sim_both_disabled_msg": MessageLookupByLibrary.simpleMessage(
      "Both features are disabled. Enable at least one to protect your capital.",
    ),
    "sim_capital_protection": MessageLookupByLibrary.simpleMessage(
      "Capital Protection",
    ),
    "sim_current_price": MessageLookupByLibrary.simpleMessage("Current Price"),
    "sim_failed_to_fetch_holdings": MessageLookupByLibrary.simpleMessage(
      "Failed to fetch holdings",
    ),
    "sim_failed_to_fetch_transactions": MessageLookupByLibrary.simpleMessage(
      "Failed to fetch transactions",
    ),
    "sim_failed_to_fetch_wallet": MessageLookupByLibrary.simpleMessage(
      "Failed to fetch wallet",
    ),
    "sim_failed_to_load": MessageLookupByLibrary.simpleMessage(
      "Failed to load simulation data",
    ),
    "sim_failed_to_remove_rule": m35,
    "sim_failed_to_save_rule": m36,
    "sim_go_to_markets": MessageLookupByLibrary.simpleMessage("Go to Markets"),
    "sim_holdings": MessageLookupByLibrary.simpleMessage("Holdings"),
    "sim_holdings_count": m37,
    "sim_no_holdings": MessageLookupByLibrary.simpleMessage("No holdings yet"),
    "sim_no_transactions": MessageLookupByLibrary.simpleMessage(
      "No transactions yet",
    ),
    "sim_pl": MessageLookupByLibrary.simpleMessage("P&L"),
    "sim_portfolio_title": MessageLookupByLibrary.simpleMessage(
      "Simulation Portfolio",
    ),
    "sim_positions": MessageLookupByLibrary.simpleMessage("Positions"),
    "sim_price": MessageLookupByLibrary.simpleMessage("Price"),
    "sim_protection_active": m38,
    "sim_protection_removed": m39,
    "sim_protection_saved": m40,
    "sim_protection_updated": m41,
    "sim_quantity": MessageLookupByLibrary.simpleMessage("Quantity"),
    "sim_remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "sim_save_rule": MessageLookupByLibrary.simpleMessage("Save Rule"),
    "sim_set_protection": MessageLookupByLibrary.simpleMessage(
      "Set Protection",
    ),
    "sim_shares_unit": MessageLookupByLibrary.simpleMessage("shares"),
    "sim_start_trading": MessageLookupByLibrary.simpleMessage(
      "Start trading to build your portfolio",
    ),
    "sim_total_capital": MessageLookupByLibrary.simpleMessage("Total"),
    "sim_total_portfolio_value": MessageLookupByLibrary.simpleMessage(
      "Total Portfolio Value",
    ),
    "sim_trading_history_desc": MessageLookupByLibrary.simpleMessage(
      "Your trading history will appear here",
    ),
    "sim_transaction_history": MessageLookupByLibrary.simpleMessage(
      "Transaction History",
    ),
    "sim_update_rule": MessageLookupByLibrary.simpleMessage("Update Rule"),
    "sim_user_not_auth": MessageLookupByLibrary.simpleMessage(
      "User not authenticated",
    ),
    "sim_view_all": MessageLookupByLibrary.simpleMessage("View All"),
    "simulation_available_cash": MessageLookupByLibrary.simpleMessage(
      "Available Cash",
    ),
    "simulation_portfolio": MessageLookupByLibrary.simpleMessage(
      "Simulation Portfolio",
    ),
    "simulation_positions": MessageLookupByLibrary.simpleMessage("Positions"),
    "simulation_total_pl": MessageLookupByLibrary.simpleMessage("Total P&L"),
    "skip": MessageLookupByLibrary.simpleMessage("Skip"),
    "snackbar_error": MessageLookupByLibrary.simpleMessage("Error"),
    "snackbar_no_connection": MessageLookupByLibrary.simpleMessage(
      "No Connection",
    ),
    "snackbar_success": MessageLookupByLibrary.simpleMessage("Success"),
    "snackbar_unexpected_error": MessageLookupByLibrary.simpleMessage(
      "Unexpected Error",
    ),
    "snackbar_warning": MessageLookupByLibrary.simpleMessage("Warning"),
    "something_went_wrong": MessageLookupByLibrary.simpleMessage(
      "Something went wrong.",
    ),
    "sounds_alerts_section": MessageLookupByLibrary.simpleMessage(
      "SOUNDS & ALERTS",
    ),
    "start_trading_btn": MessageLookupByLibrary.simpleMessage("START TRADING"),
    "stock_chat_error_send": MessageLookupByLibrary.simpleMessage(
      "Failed to send message",
    ),
    "stock_chat_input_hint": MessageLookupByLibrary.simpleMessage(
      "Join the discussion...",
    ),
    "stock_chat_start_discussion": m42,
    "stock_chat_user_prefix": MessageLookupByLibrary.simpleMessage("User"),
    "stock_chat_you": MessageLookupByLibrary.simpleMessage("You"),
    "success_account_created_title": MessageLookupByLibrary.simpleMessage(
      "Account Created Successfully!",
    ),
    "success_account_deleted_msg": MessageLookupByLibrary.simpleMessage(
      "Your account has been permanently removed.",
    ),
    "success_account_deleted_title": MessageLookupByLibrary.simpleMessage(
      "Account Deleted",
    ),
    "success_email_sent_title": MessageLookupByLibrary.simpleMessage(
      "Email Sent",
    ),
    "success_google_signed_in_msg": MessageLookupByLibrary.simpleMessage(
      "Signed in successfully with Google.",
    ),
    "success_label": MessageLookupByLibrary.simpleMessage("Success"),
    "success_logged_out_msg": MessageLookupByLibrary.simpleMessage(
      "You have been logged out successfully.",
    ),
    "success_logged_out_title": MessageLookupByLibrary.simpleMessage(
      "Logged Out",
    ),
    "success_mark_all_read": MessageLookupByLibrary.simpleMessage(
      "All notifications marked as read",
    ),
    "success_password_changed_msg": MessageLookupByLibrary.simpleMessage(
      "Your password has been changed successfully.",
    ),
    "success_password_updated_title": MessageLookupByLibrary.simpleMessage(
      "Password Updated",
    ),
    "success_reset_link_sent_msg": MessageLookupByLibrary.simpleMessage(
      "A password reset link has been sent to your email.",
    ),
    "success_signed_in_msg": MessageLookupByLibrary.simpleMessage(
      "You’ve signed in successfully!",
    ),
    "success_verification_sent_msg": MessageLookupByLibrary.simpleMessage(
      "A verification link has been sent to your email.",
    ),
    "success_welcome_back_title": MessageLookupByLibrary.simpleMessage(
      "Welcome Back",
    ),
    "support_section": MessageLookupByLibrary.simpleMessage("SUPPORT"),
    "system_notifications_on": MessageLookupByLibrary.simpleMessage(
      "System notifications are ON",
    ),
    "system_settings": MessageLookupByLibrary.simpleMessage("System Settings"),
    "system_theme_description": MessageLookupByLibrary.simpleMessage(
      "Theme will change depending on phone settings",
    ),
    "tap_to_enable": MessageLookupByLibrary.simpleMessage(
      "Tap to enable in settings",
    ),
    "theme": MessageLookupByLibrary.simpleMessage("Theme"),
    "this_device": MessageLookupByLibrary.simpleMessage("This Device"),
    "today": MessageLookupByLibrary.simpleMessage("today"),
    "trending_stocks_title": MessageLookupByLibrary.simpleMessage(
      "Trending Stocks",
    ),
    "unable_to_open_email": MessageLookupByLibrary.simpleMessage(
      "Unable to open email app.",
    ),
    "unknown_error": MessageLookupByLibrary.simpleMessage(
      "Something went wrong.",
    ),
    "update_password": MessageLookupByLibrary.simpleMessage("Update Password"),
    "usd_label": MessageLookupByLibrary.simpleMessage("USD"),
    "use_system_theme": MessageLookupByLibrary.simpleMessage(
      "Use System Theme",
    ),
    "value_traded_label": MessageLookupByLibrary.simpleMessage("Value Traded"),
    "verify_code": MessageLookupByLibrary.simpleMessage("Verify code"),
    "version_number": MessageLookupByLibrary.simpleMessage("Version 1.0.0"),
    "view_all_notifications_btn": MessageLookupByLibrary.simpleMessage(
      "View all notifications",
    ),
    "virtual_balance_title": MessageLookupByLibrary.simpleMessage(
      "CURRENT VIRTUAL BALANCE",
    ),
    "watchlist_add": MessageLookupByLibrary.simpleMessage("Add to Watchlist"),
    "watchlist_remove": MessageLookupByLibrary.simpleMessage(
      "Remove from Watchlist",
    ),
    "welcome_dialog_message": MessageLookupByLibrary.simpleMessage(
      "Your account has been successfully funded. You can now start practicing your trading strategies risk-free.",
    ),
    "welcome_subtitle": MessageLookupByLibrary.simpleMessage(
      "Market data, charts and more — all in one place.",
    ),
    "welcome_title": MessageLookupByLibrary.simpleMessage("Welcome Back!!"),
    "your_watchlist_title": MessageLookupByLibrary.simpleMessage(
      "Your Watchlist",
    ),
  };
}
