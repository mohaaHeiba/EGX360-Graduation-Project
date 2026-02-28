import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_pages.dart';

class AppRoutesHelper {
  static String getInitialRoute() {
    final session = Supabase.instance.client.auth.currentSession;
    final bool isSupabaseLoggedIn = session != null;

    if (!isSupabaseLoggedIn) {
      return AppPages.welcomePage;
    }

    return AppPages.layoutPage;
  }
}
