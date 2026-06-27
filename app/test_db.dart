import 'package:supabase/supabase.dart';
void main() async {
  final supabase = SupabaseClient('https://zlcddmhcxtxvgzxcfvxx.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpsY2RkbWhjeHR4dmd6eGNmdnh4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjUyOTM0MTcsImV4cCI6MjA4MDg2OTQxN30.F5SxofdTfi9oBO3db1nygSXIiYEqoXgZ0OTW_Fu5Kew');
  final res = await supabase.from('stocks').select().eq('symbol', 'AAPL');
  print(res);
}
