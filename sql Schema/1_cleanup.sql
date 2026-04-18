-- ==============================================================================
-- 1. CLEANUP — حذف كل حاجة بالترتيب الصح
-- ==============================================================================

-- Triggers
DROP TRIGGER IF EXISTS on_auth_user_created       ON auth.users;
DROP TRIGGER IF EXISTS on_comment_created         ON public.comments;
DROP TRIGGER IF EXISTS on_post_like               ON public.post_votes;
DROP TRIGGER IF EXISTS on_comment_like            ON public.comment_votes;
DROP TRIGGER IF EXISTS on_follow_created          ON public.follows;
DROP TRIGGER IF EXISTS on_post_created            ON public.posts;

-- Functions
DROP FUNCTION IF EXISTS public.handle_new_user                 CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_comment_notification   CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_like_notification      CASCADE;
DROP FUNCTION IF EXISTS public.handle_comment_like_notification  CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_follow_notification    CASCADE;
DROP FUNCTION IF EXISTS public.handle_new_post_notification      CASCADE;
DROP FUNCTION IF EXISTS public.setup_user_portfolio              CASCADE;
DROP FUNCTION IF EXISTS public.execute_trade                     CASCADE;
DROP FUNCTION IF EXISTS get_posts_with_status                    CASCADE;
DROP FUNCTION IF EXISTS get_comments_with_status                 CASCADE;
DROP FUNCTION IF EXISTS get_trending_stocks                      CASCADE;
DROP FUNCTION IF EXISTS get_stocks_with_sparklines               CASCADE;
DROP FUNCTION IF EXISTS get_indices_with_sparklines              CASCADE;
DROP FUNCTION IF EXISTS get_watchlist_with_sparklines            CASCADE;
DROP FUNCTION IF EXISTS get_chart_history                        CASCADE;
DROP FUNCTION IF EXISTS get_gold_chart_data                      CASCADE;

-- Tables (child → parent order)
DROP TABLE IF EXISTS public.ai_predictions          CASCADE;
DROP TABLE IF EXISTS public.user_protection_rules   CASCADE;
DROP TABLE IF EXISTS public.user_transactions       CASCADE;
DROP TABLE IF EXISTS public.user_holdings           CASCADE;
DROP TABLE IF EXISTS public.user_wallets            CASCADE;
DROP TABLE IF EXISTS public.user_risk_profiles      CASCADE;
DROP TABLE IF EXISTS public.market_history          CASCADE;
DROP TABLE IF EXISTS public.materials_prices        CASCADE;
DROP TABLE IF EXISTS public.notifications           CASCADE;
DROP TABLE IF EXISTS public.comment_votes           CASCADE;
DROP TABLE IF EXISTS public.post_votes              CASCADE;
DROP TABLE IF EXISTS public.bookmarks               CASCADE;
DROP TABLE IF EXISTS public.follows                 CASCADE;
DROP TABLE IF EXISTS public.comments                CASCADE;
DROP TABLE IF EXISTS public.user_watchlist          CASCADE;
DROP TABLE IF EXISTS public.posts                   CASCADE;
DROP TABLE IF EXISTS public.profiles                CASCADE;
DROP TABLE IF EXISTS public.stock_messages          CASCADE;