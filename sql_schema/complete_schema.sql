-- -- ==============================================================================
-- -- egx360 — Complete Supabase Schema
-- -- ==============================================================================
-- -- This file contains every active SQL statement needed to bootstrap the egx360
-- -- database from scratch:
-- --   1. Cleanup (Drop existing triggers & functions)
-- --   2. Create Tables
-- --   3. Data Restoration & Indexes
-- --   4. Triggers & Auto-notification Functions
-- --   5. RPC Functions used by the Flutter app
-- --   6. Row Level Security (RLS) Policies
-- --   7. Simulation Tables (wallets, holdings, transactions, protection rules)
-- --   8. Market History Table
-- --   9. Trending Stocks Function
-- --  10. Additional Crypto Symbols (stocks table inserts)
-- -- ==============================================================================
--
--
-- -- ==============================================================================
-- -- 1. CLEANUP — Drop existing triggers & functions (safe re-run)
-- -- ==============================================================================
--
-- -- Triggers
-- DROP TRIGGER IF EXISTS on_auth_user_created    ON auth.users;
-- DROP TRIGGER IF EXISTS on_comment_created      ON public.comments;
-- DROP TRIGGER IF EXISTS on_post_like            ON public.post_votes;
-- DROP TRIGGER IF EXISTS on_follow_created       ON public.follows;
-- DROP TRIGGER IF EXISTS on_comment_like         ON public.comment_votes;
--
-- -- Functions
-- DROP FUNCTION IF EXISTS get_posts_with_status                  CASCADE;
-- DROP FUNCTION IF EXISTS get_comments_with_status               CASCADE;
-- DROP FUNCTION IF EXISTS public.handle_new_user                 CASCADE;
-- DROP FUNCTION IF EXISTS public.handle_new_comment_notification CASCADE;
-- DROP FUNCTION IF EXISTS public.handle_new_like_notification    CASCADE;
-- DROP FUNCTION IF EXISTS public.handle_new_follow_notification  CASCADE;
-- DROP FUNCTION IF EXISTS public.handle_comment_like_notification CASCADE;
-- DROP FUNCTION IF EXISTS get_trending_stocks                    CASCADE;
--
--
-- -- ==============================================================================
-- -- 2. CREATE TABLES
-- -- ==============================================================================
--
-- -- Backup watchlist before full rebuild (safe no-op if table doesn't exist yet)
-- CREATE TABLE IF NOT EXISTS temp_watchlist_backup AS
--   SELECT * FROM public.user_watchlist;
--
-- -- Drop tables in child→parent order to avoid FK violations
-- DROP TABLE IF EXISTS public.user_protection_rules CASCADE;
-- DROP TABLE IF EXISTS public.user_transactions      CASCADE;
-- DROP TABLE IF EXISTS public.user_holdings          CASCADE;
-- DROP TABLE IF EXISTS public.user_wallets           CASCADE;
-- DROP TABLE IF EXISTS public.notifications          CASCADE;
-- DROP TABLE IF EXISTS public.comment_votes          CASCADE;
-- DROP TABLE IF EXISTS public.post_votes             CASCADE;
-- DROP TABLE IF EXISTS public.bookmarks              CASCADE;
-- DROP TABLE IF EXISTS public.follows                CASCADE;
-- DROP TABLE IF EXISTS public.comments               CASCADE;
-- DROP TABLE IF EXISTS public.user_watchlist         CASCADE;
-- DROP TABLE IF EXISTS public.posts                  CASCADE;
-- DROP TABLE IF EXISTS public.profiles               CASCADE;
-- DROP TABLE IF EXISTS market_history                CASCADE;
--
-- -- ── A. Profiles ─────────────────────────────────────────────────────────────
-- CREATE TABLE public.profiles (
--     id           uuid         REFERENCES auth.users ON DELETE CASCADE NOT NULL PRIMARY KEY,
--     email        varchar(255) UNIQUE NOT NULL,
--     name         varchar(255),
--     avatar_url   text,
--     bio          text,
--     fcm_token    text,
--     last_active_at timestamptz,
--     created_at   timestamptz  DEFAULT timezone('utc'::text, now()) NOT NULL,
--     updated_at   timestamptz  DEFAULT timezone('utc'::text, now()) NOT NULL
-- );
--
-- -- ── B. User Watchlist ────────────────────────────────────────────────────────
-- CREATE TABLE public.user_watchlist (
--     user_id      uuid  REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     stock_symbol text  NOT NULL,
--     created_at   timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
--     PRIMARY KEY (user_id, stock_symbol)
-- );
--
-- -- ── C. Follows ───────────────────────────────────────────────────────────────
-- CREATE TABLE public.follows (
--     follower_id  uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     following_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     created_at   timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
--     PRIMARY KEY  (follower_id, following_id),
--     CONSTRAINT   cant_follow_self CHECK (follower_id != following_id)
-- );
--
-- -- ── D. Posts ─────────────────────────────────────────────────────────────────
-- CREATE TABLE public.posts (
--     id         bigint       GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
--     user_id    uuid         REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     content    text,
--     image_url  text,
--     sentiment  varchar(10)  CHECK (sentiment IN ('bullish', 'bearish')),
--     cashtags   text[],
--     created_at timestamptz  DEFAULT timezone('utc'::text, now()) NOT NULL
-- );
--
-- -- ── E. Post Votes (Likes / Dislikes) ─────────────────────────────────────────
-- CREATE TABLE public.post_votes (
--     user_id    uuid    REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     post_id    bigint  REFERENCES public.posts(id)    ON DELETE CASCADE NOT NULL,
--     vote_type  int     NOT NULL CHECK (vote_type IN (1, -1)),
--     created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
--     PRIMARY KEY (user_id, post_id)
-- );
--
-- -- ── F. Bookmarks ─────────────────────────────────────────────────────────────
-- CREATE TABLE public.bookmarks (
--     user_id    uuid    REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     post_id    bigint  REFERENCES public.posts(id)    ON DELETE CASCADE NOT NULL,
--     created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
--     PRIMARY KEY (user_id, post_id)
-- );
--
-- -- ── G. Comments (supports nested replies via parent_id) ───────────────────────
-- CREATE TABLE public.comments (
--     id         bigint  GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
--     user_id    uuid    REFERENCES public.profiles(id)   ON DELETE CASCADE NOT NULL,
--     post_id    bigint  REFERENCES public.posts(id)      ON DELETE CASCADE NOT NULL,
--     parent_id  bigint  REFERENCES public.comments(id)   ON DELETE CASCADE,
--     content    text    NOT NULL,
--     created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL
-- );
--
-- -- ── H. Comment Votes ─────────────────────────────────────────────────────────
-- CREATE TABLE public.comment_votes (
--     user_id    uuid    REFERENCES public.profiles(id)   ON DELETE CASCADE NOT NULL,
--     comment_id bigint  REFERENCES public.comments(id)   ON DELETE CASCADE NOT NULL,
--     vote_type  int     NOT NULL CHECK (vote_type IN (1, -1)),
--     created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,
--     PRIMARY KEY (user_id, comment_id)
-- );
--
-- -- ── I. Notifications ─────────────────────────────────────────────────────────
-- CREATE TABLE public.notifications (
--     id           bigint  GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
--     recipient_id uuid    REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     sender_id    uuid    REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     resource_id  bigint  NOT NULL,
--     type         text    NOT NULL CHECK (type IN ('comment', 'reply', 'like', 'follow')),
--     title        text,
--     body         text,
--     metadata     jsonb   DEFAULT '{}'::jsonb,
--     is_read      boolean DEFAULT false,
--     created_at   timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL
-- );
--
-- -- ── J. Market History ────────────────────────────────────────────────────────
-- CREATE TABLE public.market_history (
--     id           bigint  GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
--     trade_date   date    NOT NULL,
--     market_cap   text,
--     value_traded text,
--     updated_at   timestamptz DEFAULT timezone('utc'::text, now())
-- );
--
-- -- ── K. Simulation — User Wallets ─────────────────────────────────────────────
-- CREATE TABLE public.user_wallets (
--     user_id         uuid    REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL PRIMARY KEY,
--     balance         numeric DEFAULT 100000.00,
--     initial_balance numeric DEFAULT 100000.00,
--     created_at      timestamptz DEFAULT now()
-- );
--
-- -- ── L. Simulation — Holdings ─────────────────────────────────────────────────
-- CREATE TABLE public.user_holdings (
--     user_id       uuid    REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     symbol        text    NOT NULL,
--     quantity      numeric NOT NULL DEFAULT 0,
--     average_price numeric NOT NULL DEFAULT 0,
--     updated_at    timestamptz DEFAULT now(),
--     PRIMARY KEY (user_id, symbol)
-- );
--
-- -- ── M. Simulation — Transactions ─────────────────────────────────────────────
-- CREATE TABLE public.user_transactions (
--     id               bigint  GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
--     user_id          uuid    REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     symbol           text    NOT NULL,
--     type             text    CHECK (type IN ('buy', 'sell')),
--     quantity         numeric NOT NULL,
--     price            numeric NOT NULL,
--     total_value      numeric NOT NULL,
--     execution_type   text    DEFAULT 'manual' CHECK (execution_type IN ('manual', 'auto_protection')),
--     created_at       timestamptz DEFAULT now()
-- );
--
-- -- ── N. Simulation — Protection Rules ─────────────────────────────────────────
-- CREATE TABLE public.user_protection_rules (
--     id                       bigint  GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
--     user_id                  uuid    REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
--     symbol                   text    NOT NULL,
--     alert_percentage         numeric DEFAULT 5.0,
--     liquidation_percentage   numeric DEFAULT 10.0,
--     is_alert_enabled         boolean DEFAULT false,
--     is_sell_enabled          boolean DEFAULT false,
--     last_alert_sent_at       timestamptz,
--     created_at               timestamptz DEFAULT now(),
--     UNIQUE (user_id, symbol)
-- );
--
--
-- -- ==============================================================================
-- -- 3. INDEXES FOR PERFORMANCE
-- -- ==============================================================================
--
-- CREATE INDEX idx_posts_cashtags            ON public.posts           USING GIN (cashtags);
-- CREATE INDEX idx_comments_post_id          ON public.comments        (post_id);
-- CREATE INDEX idx_post_votes_post_id        ON public.post_votes      (post_id);
-- CREATE INDEX idx_notifications_recipient   ON public.notifications   (recipient_id, is_read);
-- CREATE INDEX idx_notifications_created_at  ON public.notifications   (created_at DESC);
-- CREATE INDEX idx_market_history_trade_date ON public.market_history  (trade_date);
--
--
-- -- ==============================================================================
-- -- 4. DATA RESTORATION
-- -- ==============================================================================
--
-- -- Restore profiles from auth.users (idempotent)
-- INSERT INTO public.profiles (id, email, name, avatar_url, created_at, updated_at)
-- SELECT
--     id,
--     email,
--     COALESCE(raw_user_meta_data->>'name', raw_user_meta_data->>'full_name', split_part(email, '@', 1)),
--     COALESCE(raw_user_meta_data->>'avatar_url', raw_user_meta_data->>'picture'),
--     created_at,
--     COALESCE(updated_at, created_at)
-- FROM auth.users
-- ON CONFLICT (id) DO NOTHING;
--
-- -- Create simulation wallets for existing users
-- INSERT INTO public.user_wallets (user_id, balance)
-- SELECT id, 100000.00 FROM public.profiles
-- ON CONFLICT (user_id) DO NOTHING;
--
-- -- Restore watchlist
-- INSERT INTO public.user_watchlist (user_id, stock_symbol, created_at)
-- SELECT t.user_id, t.stock_symbol, t.created_at
-- FROM   temp_watchlist_backup t
-- JOIN   public.profiles p ON t.user_id = p.id
-- ON CONFLICT DO NOTHING;
--
-- DROP TABLE IF EXISTS temp_watchlist_backup;
--
--
-- -- ==============================================================================
-- -- 5. ROW LEVEL SECURITY (RLS)
-- -- ==============================================================================
--
-- ALTER TABLE public.profiles             ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.posts                ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.comments             ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.follows              ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.post_votes           ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.comment_votes        ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.bookmarks            ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.user_watchlist       ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.notifications        ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.market_history       ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.user_wallets         ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.user_holdings        ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.user_transactions    ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE public.user_protection_rules ENABLE ROW LEVEL SECURITY;
--
-- -- Drop old policies (safe)
-- DO $$ BEGIN
--   DROP POLICY IF EXISTS "Public profiles viewable"         ON public.profiles;
--   DROP POLICY IF EXISTS "Users update own"                 ON public.profiles;
--   DROP POLICY IF EXISTS "Public posts viewable"            ON public.posts;
--   DROP POLICY IF EXISTS "Users insert own posts"           ON public.posts;
--   DROP POLICY IF EXISTS "Users delete own posts"           ON public.posts;
--   DROP POLICY IF EXISTS "Public comments viewable"         ON public.comments;
--   DROP POLICY IF EXISTS "Users insert own comments"        ON public.comments;
--   DROP POLICY IF EXISTS "Users delete own comments"        ON public.comments;
--   DROP POLICY IF EXISTS "Public votes viewable"            ON public.post_votes;
--   DROP POLICY IF EXISTS "Users vote posts"                 ON public.post_votes;
--   DROP POLICY IF EXISTS "Users unvote posts"               ON public.post_votes;
--   DROP POLICY IF EXISTS "Public comment votes viewable"    ON public.comment_votes;
--   DROP POLICY IF EXISTS "Users vote comments"              ON public.comment_votes;
--   DROP POLICY IF EXISTS "Users unvote comments"            ON public.comment_votes;
--   DROP POLICY IF EXISTS "Public follows viewable"          ON public.follows;
--   DROP POLICY IF EXISTS "Users follow"                     ON public.follows;
--   DROP POLICY IF EXISTS "Users unfollow"                   ON public.follows;
--   DROP POLICY IF EXISTS "Users view own bookmarks"         ON public.bookmarks;
--   DROP POLICY IF EXISTS "Users bookmark posts"             ON public.bookmarks;
--   DROP POLICY IF EXISTS "Users remove bookmark"            ON public.bookmarks;
--   DROP POLICY IF EXISTS "Users view own watchlist"         ON public.user_watchlist;
--   DROP POLICY IF EXISTS "Users add to watchlist"           ON public.user_watchlist;
--   DROP POLICY IF EXISTS "Users remove from watchlist"      ON public.user_watchlist;
--   DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;
--   DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;
--   DROP POLICY IF EXISTS "notifications_owner_select"       ON public.notifications;
--   DROP POLICY IF EXISTS "notifications_owner_update"       ON public.notifications;
--   DROP POLICY IF EXISTS "Users can manage their own rules" ON public.user_protection_rules;
-- END $$;
--
-- -- Profiles
-- CREATE POLICY "Public profiles viewable" ON public.profiles FOR SELECT USING (true);
-- CREATE POLICY "Users update own"         ON public.profiles FOR UPDATE USING (auth.uid() = id);
--
-- -- Posts
-- CREATE POLICY "Public posts viewable"    ON public.posts FOR SELECT USING (true);
-- CREATE POLICY "Users insert own posts"   ON public.posts FOR INSERT WITH CHECK (auth.uid() = user_id);
-- CREATE POLICY "Users delete own posts"   ON public.posts FOR DELETE USING (auth.uid() = user_id);
--
-- -- Comments
-- CREATE POLICY "Public comments viewable"   ON public.comments FOR SELECT USING (true);
-- CREATE POLICY "Users insert own comments"  ON public.comments FOR INSERT WITH CHECK (auth.uid() = user_id);
-- CREATE POLICY "Users delete own comments"  ON public.comments FOR DELETE USING (auth.uid() = user_id);
--
-- -- Post Votes
-- CREATE POLICY "Public votes viewable" ON public.post_votes FOR SELECT USING (true);
-- CREATE POLICY "Users vote posts"      ON public.post_votes FOR INSERT WITH CHECK (auth.uid() = user_id);
-- CREATE POLICY "Users unvote posts"    ON public.post_votes FOR DELETE USING (auth.uid() = user_id);
--
-- -- Comment Votes
-- CREATE POLICY "Public comment votes viewable" ON public.comment_votes FOR SELECT USING (true);
-- CREATE POLICY "Users vote comments"           ON public.comment_votes FOR INSERT WITH CHECK (auth.uid() = user_id);
-- CREATE POLICY "Users unvote comments"         ON public.comment_votes FOR DELETE USING (auth.uid() = user_id);
--
-- -- Follows
-- CREATE POLICY "Public follows viewable" ON public.follows FOR SELECT USING (true);
-- CREATE POLICY "Users follow"            ON public.follows FOR INSERT WITH CHECK (auth.uid() = follower_id);
-- CREATE POLICY "Users unfollow"          ON public.follows FOR DELETE USING (auth.uid() = follower_id);
--
-- -- Bookmarks
-- CREATE POLICY "Users view own bookmarks" ON public.bookmarks FOR SELECT USING (auth.uid() = user_id);
-- CREATE POLICY "Users bookmark posts"     ON public.bookmarks FOR INSERT WITH CHECK (auth.uid() = user_id);
-- CREATE POLICY "Users remove bookmark"    ON public.bookmarks FOR DELETE USING (auth.uid() = user_id);
--
-- -- Watchlist
-- CREATE POLICY "Users view own watchlist"    ON public.user_watchlist FOR SELECT USING (auth.uid() = user_id);
-- CREATE POLICY "Users add to watchlist"      ON public.user_watchlist FOR INSERT WITH CHECK (auth.uid() = user_id);
-- CREATE POLICY "Users remove from watchlist" ON public.user_watchlist FOR DELETE USING (auth.uid() = user_id);
--
-- -- Notifications
-- CREATE POLICY "notifications_owner_select"
--     ON public.notifications FOR SELECT USING (auth.uid() = recipient_id);
-- CREATE POLICY "notifications_owner_update"
--     ON public.notifications FOR UPDATE
--     USING (auth.uid() = recipient_id)
--     WITH CHECK (auth.uid() = recipient_id);
--
-- -- Market History (public read)
-- CREATE POLICY "Public market history viewable" ON public.market_history FOR SELECT USING (true);
--
-- -- Simulation tables (owner-only)
-- CREATE POLICY "Users manage own wallet"       ON public.user_wallets          FOR ALL USING (auth.uid() = user_id);
-- CREATE POLICY "Users manage own holdings"     ON public.user_holdings         FOR ALL USING (auth.uid() = user_id);
-- CREATE POLICY "Users manage own transactions" ON public.user_transactions      FOR ALL USING (auth.uid() = user_id);
-- CREATE POLICY "Users can manage their own rules" ON public.user_protection_rules FOR ALL USING (auth.uid() = user_id);
--
--
-- -- ==============================================================================
-- -- 6. TRIGGER FUNCTIONS
-- -- ==============================================================================
--
-- -- ── A. Auto-Create Profile on Sign-Up ────────────────────────────────────────
-- CREATE OR REPLACE FUNCTION public.handle_new_user()
-- RETURNS TRIGGER AS $$
-- BEGIN
--   INSERT INTO public.profiles (id, email, name, avatar_url)
--   VALUES (
--     new.id,
--     new.email,
--     COALESCE(new.raw_user_meta_data->>'name',
--              new.raw_user_meta_data->>'full_name',
--              split_part(new.email, '@', 1)),
--     COALESCE(new.raw_user_meta_data->>'avatar_url',
--              new.raw_user_meta_data->>'picture')
--   )
--   ON CONFLICT (id) DO UPDATE SET
--     email      = EXCLUDED.email,
--     name       = COALESCE(EXCLUDED.name, public.profiles.name),
--     avatar_url = COALESCE(EXCLUDED.avatar_url, public.profiles.avatar_url),
--     updated_at = now();
--
--   -- Create simulation wallet for new user
--   INSERT INTO public.user_wallets (user_id, balance)
--   VALUES (new.id, 100000.00)
--   ON CONFLICT (user_id) DO NOTHING;
--
--   RETURN new;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;
--
-- CREATE TRIGGER on_auth_user_created
--   AFTER INSERT ON auth.users
--   FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
--
-- -- ── B. Comment & Reply Notifications ─────────────────────────────────────────
-- CREATE OR REPLACE FUNCTION public.handle_new_comment_notification()
-- RETURNS TRIGGER AS $$
-- DECLARE
--   post_owner_id   uuid;
--   parent_owner_id uuid;
--   sender_name     text;
-- BEGIN
--   SELECT name INTO sender_name FROM public.profiles WHERE id = new.user_id;
--
--   -- Reply to a comment
--   IF new.parent_id IS NOT NULL THEN
--     SELECT user_id INTO parent_owner_id FROM public.comments WHERE id = new.parent_id;
--     IF parent_owner_id != new.user_id THEN
--       INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body, metadata)
--       VALUES (parent_owner_id, new.user_id, new.post_id, 'reply',
--               'New Reply', sender_name || ' replied to your comment',
--               jsonb_build_object('post_id', new.post_id, 'comment_id', new.id));
--     END IF;
--
--   -- Comment on a post
--   ELSE
--     SELECT user_id INTO post_owner_id FROM public.posts WHERE id = new.post_id;
--     IF post_owner_id != new.user_id THEN
--       INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body, metadata)
--       VALUES (post_owner_id, new.user_id, new.post_id, 'comment',
--               'New Comment', sender_name || ' commented on your post',
--               jsonb_build_object('post_id', new.post_id));
--     END IF;
--   END IF;
--
--   RETURN new;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;
--
-- CREATE TRIGGER on_comment_created
--   AFTER INSERT ON public.comments
--   FOR EACH ROW EXECUTE PROCEDURE public.handle_new_comment_notification();
--
-- -- ── C. Post Like Notifications ────────────────────────────────────────────────
-- CREATE OR REPLACE FUNCTION public.handle_new_like_notification()
-- RETURNS TRIGGER AS $$
-- DECLARE
--   post_owner_id uuid;
--   sender_name   text;
-- BEGIN
--   IF new.vote_type = 1 THEN
--     SELECT name INTO sender_name FROM public.profiles WHERE id = new.user_id;
--     SELECT user_id INTO post_owner_id FROM public.posts WHERE id = new.post_id;
--
--     IF post_owner_id != new.user_id THEN
--       INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body, metadata)
--       VALUES (post_owner_id, new.user_id, new.post_id, 'like',
--               'New Like', sender_name || ' liked your post',
--               jsonb_build_object('post_id', new.post_id));
--     END IF;
--   END IF;
--
--   RETURN new;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;
--
-- CREATE TRIGGER on_post_like
--   AFTER INSERT ON public.post_votes
--   FOR EACH ROW EXECUTE PROCEDURE public.handle_new_like_notification();
--
-- -- ── D. Comment Like Notifications ────────────────────────────────────────────
-- CREATE OR REPLACE FUNCTION public.handle_comment_like_notification()
-- RETURNS TRIGGER AS $$
-- DECLARE
--   comment_owner_id uuid;
--   sender_name      text;
--   post_id_val      bigint;
-- BEGIN
--   IF new.vote_type = 1 THEN
--     SELECT name INTO sender_name FROM public.profiles WHERE id = new.user_id;
--     SELECT user_id, post_id INTO comment_owner_id, post_id_val
--     FROM   public.comments WHERE id = new.comment_id;
--
--     IF comment_owner_id != new.user_id THEN
--       INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body, metadata)
--       VALUES (comment_owner_id, new.user_id, new.comment_id, 'like',
--               'Comment Liked', sender_name || ' liked your comment',
--               jsonb_build_object('post_id', post_id_val, 'comment_id', new.comment_id));
--     END IF;
--   END IF;
--
--   RETURN new;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;
--
-- CREATE TRIGGER on_comment_like
--   AFTER INSERT ON public.comment_votes
--   FOR EACH ROW EXECUTE PROCEDURE public.handle_comment_like_notification();
--
-- -- ── E. Follow Notifications ───────────────────────────────────────────────────
-- CREATE OR REPLACE FUNCTION public.handle_new_follow_notification()
-- RETURNS TRIGGER AS $$
-- DECLARE
--   sender_name text;
-- BEGIN
--   SELECT name INTO sender_name FROM public.profiles WHERE id = new.follower_id;
--
--   INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body, metadata)
--   VALUES (new.following_id, new.follower_id, 0, 'follow',
--           'New Follower', sender_name || ' started following you',
--           jsonb_build_object('follower_id', new.follower_id));
--
--   RETURN new;
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;
--
-- CREATE TRIGGER on_follow_created
--   AFTER INSERT ON public.follows
--   FOR EACH ROW EXECUTE PROCEDURE public.handle_new_follow_notification();
--
--
-- -- ==============================================================================
-- -- 7. RPC FUNCTIONS (Flutter API Layer)
-- -- ==============================================================================
--
-- -- ── A. get_posts_with_status ──────────────────────────────────────────────────
-- CREATE OR REPLACE FUNCTION get_posts_with_status(
--   viewer_id       uuid,
--   target_user_id  uuid,
--   limit_val       int,
--   offset_val      int,
--   category_filter text DEFAULT NULL
-- )
-- RETURNS TABLE (
--   id             bigint,
--   user_id        uuid,
--   content        text,
--   image_url      text,
--   sentiment      text,
--   cashtags       text[],
--   created_at     timestamptz,
--   user_name      text,
--   user_avatar    text,
--   likes_count    bigint,
--   dislikes_count bigint,
--   comments_count bigint,
--   is_liked       boolean,
--   is_bookmarked  boolean
-- )
-- LANGUAGE plpgsql AS $$
-- BEGIN
--   RETURN QUERY
--   SELECT
--     p.id, p.user_id, p.content, p.image_url, p.sentiment::text, p.cashtags, p.created_at,
--     pr.name::text, pr.avatar_url::text,
--     (SELECT count(*) FROM public.post_votes v WHERE v.post_id = p.id AND v.vote_type =  1),
--     (SELECT count(*) FROM public.post_votes v WHERE v.post_id = p.id AND v.vote_type = -1),
--     (SELECT count(*) FROM public.comments  c WHERE c.post_id = p.id),
--     EXISTS(SELECT 1 FROM public.post_votes v WHERE v.post_id = p.id AND v.user_id = viewer_id AND v.vote_type = 1),
--     EXISTS(SELECT 1 FROM public.bookmarks  b WHERE b.post_id = p.id AND b.user_id = viewer_id)
--   FROM public.posts p
--   LEFT JOIN public.profiles pr ON p.user_id = pr.id
--   WHERE
--     (target_user_id IS NULL OR p.user_id = target_user_id)
--     AND (
--       category_filter IS NULL
--       OR EXISTS (
--         SELECT 1 FROM unnest(p.cashtags) AS tag
--         WHERE tag ILIKE '%' || category_filter || '%'
--       )
--     )
--   ORDER BY p.created_at DESC
--   LIMIT limit_val OFFSET offset_val;
-- END;
-- $$;
--
-- -- ── B. get_comments_with_status ───────────────────────────────────────────────
-- CREATE OR REPLACE FUNCTION get_comments_with_status(
--   viewer_id      uuid,
--   target_post_id bigint
-- )
-- RETURNS TABLE (
--   id               bigint,
--   post_id          bigint,
--   parent_id        bigint,
--   content          text,
--   created_at       timestamptz,
--   user_id          uuid,
--   user_name        text,
--   user_avatar      text,
--   likes_count      bigint,
--   dislikes_count   bigint,
--   user_vote_type   int,
--   parent_username  text
-- )
-- LANGUAGE plpgsql AS $$
-- BEGIN
--   RETURN QUERY
--   SELECT
--     c.id, c.post_id, c.parent_id, c.content, c.created_at, c.user_id,
--     pr.name::text, pr.avatar_url::text,
--     (SELECT count(*) FROM public.comment_votes cv WHERE cv.comment_id = c.id AND cv.vote_type =  1),
--     (SELECT count(*) FROM public.comment_votes cv WHERE cv.comment_id = c.id AND cv.vote_type = -1),
--     (SELECT vote_type FROM public.comment_votes cv WHERE cv.comment_id = c.id AND cv.user_id = viewer_id),
--     (SELECT p2.name::text FROM public.comments c2 JOIN public.profiles p2 ON c2.user_id = p2.id WHERE c2.id = c.parent_id)
--   FROM public.comments c
--   LEFT JOIN public.profiles pr ON c.user_id = pr.id
--   WHERE c.post_id = target_post_id
--   ORDER BY c.created_at ASC;
-- END;
-- $$;
--
-- -- ── C. execute_trade (Simulation) ────────────────────────────────────────────
-- CREATE OR REPLACE FUNCTION execute_trade(
--   p_user_id  uuid,
--   p_symbol   text,
--   p_type     text,
--   p_quantity numeric,
--   p_price    numeric
-- )
-- RETURNS void AS $$
-- DECLARE
--   v_total_cost       numeric := p_quantity * p_price;
--   v_current_balance  numeric;
-- BEGIN
--   IF p_type = 'buy' THEN
--     SELECT balance INTO v_current_balance
--     FROM   public.user_wallets WHERE user_id = p_user_id;
--
--     IF v_current_balance < v_total_cost THEN
--       RAISE EXCEPTION 'Insufficient balance';
--     END IF;
--
--     UPDATE public.user_wallets
--     SET    balance = balance - v_total_cost
--     WHERE  user_id = p_user_id;
--
--     INSERT INTO public.user_holdings (user_id, symbol, quantity, average_price)
--     VALUES (p_user_id, p_symbol, p_quantity, p_price)
--     ON CONFLICT (user_id, symbol) DO UPDATE SET
--       average_price = ((public.user_holdings.quantity * public.user_holdings.average_price) + v_total_cost)
--                       / (public.user_holdings.quantity + p_quantity),
--       quantity      = public.user_holdings.quantity + p_quantity,
--       updated_at    = now();
--
--   ELSIF p_type = 'sell' THEN
--     UPDATE public.user_holdings
--     SET    quantity   = quantity - p_quantity,
--            updated_at = now()
--     WHERE  user_id = p_user_id AND symbol = p_symbol AND quantity >= p_quantity;
--
--     IF NOT FOUND THEN
--       RAISE EXCEPTION 'Insufficient holdings to sell';
--     END IF;
--
--     UPDATE public.user_wallets
--     SET    balance = balance + v_total_cost
--     WHERE  user_id = p_user_id;
--   END IF;
--
--   INSERT INTO public.user_transactions (user_id, symbol, type, quantity, price, total_value)
--   VALUES (p_user_id, p_symbol, p_type, p_quantity, p_price, v_total_cost);
-- END;
-- $$ LANGUAGE plpgsql SECURITY DEFINER;
--
-- -- ── D. get_trending_stocks ────────────────────────────────────────────────────
-- -- Ranks stocks by a trending score:  70% volume spike  +  30% price move
-- CREATE OR REPLACE FUNCTION get_trending_stocks(row_limit INT)
-- RETURNS JSONB LANGUAGE plpgsql AS $$
-- DECLARE
--   stock_record    RECORD;
--   final_json      JSONB    := '[]'::JSONB;
--   latest_price    FLOAT4;
--   latest_vol      BIGINT;
--   avg_vol         FLOAT4;
--   calc_change     FLOAT4;
--   trending_score  FLOAT4;
--   spark_data      JSONB;
-- BEGIN
--   CREATE TEMP TABLE trending_results (
--     id        BIGINT, symbol TEXT, name_en TEXT, price FLOAT4,
--     change_pct FLOAT4, score FLOAT4, logo TEXT, spark JSONB
--   ) ON COMMIT DROP;
--
--   FOR stock_record IN (
--     SELECT * FROM stocks WHERE sector != 'Indices' AND candle_table_name != 'API'
--   )
--   LOOP
--     IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = stock_record.candle_table_name) THEN
--       EXECUTE format('SELECT close, volume FROM %I ORDER BY timestamp DESC LIMIT 1', stock_record.candle_table_name)
--         INTO latest_price, latest_vol;
--
--       EXECUTE format('SELECT AVG(volume) FROM (SELECT volume FROM %I ORDER BY timestamp DESC LIMIT 10) sub', stock_record.candle_table_name)
--         INTO avg_vol;
--
--       EXECUTE format('SELECT json_agg(c) FROM (SELECT close FROM %I ORDER BY timestamp DESC LIMIT 20) sub(c)', stock_record.candle_table_name)
--         INTO spark_data;
--
--       calc_change := CASE WHEN stock_record.prev_close > 0
--                      THEN ((latest_price - stock_record.prev_close) / stock_record.prev_close) * 100
--                      ELSE 0 END;
--
--       trending_score := (COALESCE(latest_vol / NULLIF(avg_vol, 0), 1) * 0.7)
--                       + (ABS(calc_change) * 0.3);
--
--       INSERT INTO trending_results VALUES (
--         stock_record.id, stock_record.symbol, stock_record.company_name_en,
--         latest_price, ROUND(calc_change::numeric, 2), trending_score,
--         stock_record.logo_url, COALESCE(spark_data, '[]'::JSONB)
--       );
--     END IF;
--   END LOOP;
--
--   SELECT jsonb_agg(to_jsonb(t) - 'score') INTO final_json
--   FROM   (SELECT * FROM trending_results ORDER BY score DESC LIMIT row_limit) t;
--
--   RETURN final_json;
-- END;
-- $$;
--
--
-- -- ==============================================================================
-- -- 8. ADDITIONAL CRYPTO STOCKS (INSERT)
-- -- ==============================================================================
-- -- Insert only if the stocks table exists (it should be created separately
-- -- by the stocks/candles migration). Uses ON CONFLICT DO NOTHING for safety.
--
-- INSERT INTO public.stocks (symbol, company_name_en, company_name_ar, sector, candle_table_name, logo_url, website, description, listing_date, total_shares, isin_code)
-- VALUES
--   ('SHIB', 'Shiba Inu',         'شيبا إينو',              'Crypto', 'API', 'https://cryptologos.cc/logos/shiba-inu-shib-logo.png',      'https://shibatoken.com',          'Shiba Inu is a meme coin that evolved into a vibrant ecosystem.',                                      '2020-08-01', 589000000000000,  'CRYPTO-SHIB'),
--   ('PEPE', 'Pepe',              'بيبي',                   'Crypto', 'API', 'https://cryptologos.cc/logos/pepe-pepe-logo.png',             'https://www.pepe.vip',            'Pepe is a deflationary meme coin launched on Ethereum.',                                               '2023-04-17', 420690000000000,  'CRYPTO-PEPE'),
--   ('MATIC','Polygon',           'بوليجون',                'Crypto', 'API', 'https://cryptologos.cc/logos/polygon-matic-logo.png',         'https://polygon.technology',      'Polygon is a protocol for building Ethereum-compatible blockchain networks.',                          '2017-10-01', 10000000000,      'CRYPTO-MATIC'),
--   ('LTC',  'Litecoin',          'لايت كوين',              'Crypto', 'API', 'https://cryptologos.cc/logos/litecoin-ltc-logo.png',          'https://litecoin.org',            'Litecoin is a peer-to-peer cryptocurrency (silver to Bitcoin''s gold).',                              '2011-10-07', 84000000,         'CRYPTO-LTC'),
--   ('UNI',  'Uniswap',           'يوني سواب',              'Crypto', 'API', 'https://cryptologos.cc/logos/uniswap-uni-logo.png',           'https://uniswap.org',             'Uniswap is a popular decentralized trading protocol.',                                                 '2020-09-17', 1000000000,       'CRYPTO-UNI'),
--   ('TRX',  'TRON',              'ترون',                   'Crypto', 'API', 'https://cryptologos.cc/logos/tron-trx-logo.png',              'https://tron.network',            'TRON is a blockchain-based operating system.',                                                         '2017-09-13', 89000000000,      'CRYPTO-TRX'),
--   ('ETC',  'Ethereum Classic',  'إيثيريوم كلاسيك',        'Crypto', 'API', 'https://cryptologos.cc/logos/ethereum-classic-etc-logo.png',  'https://ethereumclassic.org',     'Ethereum Classic is a decentralized computing platform that runs smart contracts.',                     '2016-07-20', 210700000,        'CRYPTO-ETC'),
--   ('FIL',  'Filecoin',          'فايل كوين',              'Crypto', 'API', 'https://cryptologos.cc/logos/filecoin-fil-logo.png',          'https://filecoin.io',             'Filecoin is a decentralized storage system.',                                                          '2020-10-15', 1960000000,       'CRYPTO-FIL'),
--   ('AAVE', 'Aave',              'آف',                     'Crypto', 'API', 'https://cryptologos.cc/logos/aave-aave-logo.png',             'https://aave.com',                'Aave is a decentralized finance protocol.',                                                            '2020-10-02', 16000000,         'CRYPTO-AAVE'),
--   ('NEAR', 'NEAR Protocol',     'نير بروتوكول',           'Crypto', 'API', 'https://cryptologos.cc/logos/near-protocol-near-logo.png',    'https://near.org',                'NEAR Protocol is a layer-one blockchain.',                                                             '2020-04-22', 1000000000,       'CRYPTO-NEAR'),
--   ('FET',  'Artificial Superintelligence', 'الذكاء الاصطناعي الفائق', 'Crypto', 'API', 'https://cryptologos.cc/logos/fetch-ai-fet-logo.png', 'https://fetch.ai', 'FET is the token powering the Artificial Superintelligence Alliance.',                               '2019-02-28', 2519000000,       'CRYPTO-FET'),
--   ('RNDR', 'Render',            'رندر',                   'Crypto', 'API', 'https://cryptologos.cc/logos/render-rndr-logo.png',           'https://render.x.io',             'Render Token is a distributed GPU rendering network.',                                                 '2020-06-15', 530000000,        'CRYPTO-RNDR'),
--   ('ARB',  'Arbitrum',          'أربيتراوم',              'Crypto', 'API', 'https://cryptologos.cc/logos/arbitrum-arb-logo.png',          'https://arbitrum.io',             'Arbitrum is a layer-2 scaling solution for Ethereum.',                                                 '2023-03-23', 10000000000,      'CRYPTO-ARB'),
--   ('APT',  'Aptos',             'أبتوس',                  'Crypto', 'API', 'https://cryptologos.cc/logos/aptos-apt-logo.png',             'https://aptoslabs.com',           'Aptos is a Layer 1 Proof-of-Stake blockchain.',                                                        '2022-10-12', 1000000000,       'CRYPTO-APT'),
--   ('ATOM', 'Cosmos',            'كوزموس',                 'Crypto', 'API', 'https://cryptologos.cc/logos/cosmos-atom-logo.png',           'https://cosmos.network',          'Cosmos is an ecosystem of networks and tools.',                                                        '2019-03-14', 390000000,        'CRYPTO-ATOM')
-- ON CONFLICT (symbol) DO NOTHING;
--
--
--
-- -- ==============================================================================
-- -- 9. STOCKS MASTER TABLE & CANDLE TABLES
-- -- ==============================================================================
--
-- -- Drop existing functions that reference stocks before rebuilding
-- DROP FUNCTION IF EXISTS get_stocks_with_sparklines(integer)  CASCADE;
-- DROP FUNCTION IF EXISTS get_indices_with_sparklines()        CASCADE;
-- DROP FUNCTION IF EXISTS get_watchlist_with_sparklines(UUID)  CASCADE;
-- DROP FUNCTION IF EXISTS get_chart_history(TEXT, TIMESTAMPTZ, INT) CASCADE;
-- DROP FUNCTION IF EXISTS get_gold_chart_data(INT)             CASCADE;
-- DROP FUNCTION IF EXISTS get_gold_chart_data(INT, VARCHAR)    CASCADE;
-- DROP FUNCTION IF EXISTS get_chart_data(TEXT, INT)            CASCADE;
--
-- -- ── Stocks Master Table ───────────────────────────────────────────────────────
-- DROP TABLE IF EXISTS stocks CASCADE;
--
-- CREATE TABLE stocks (
--     id                 BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
--     symbol             VARCHAR(10)  UNIQUE NOT NULL,
--     company_name_en    VARCHAR(255) NOT NULL,
--     company_name_ar    VARCHAR(255),
--     sector             VARCHAR(100),
--     description        TEXT,
--     total_shares       BIGINT,
--     prev_close         FLOAT4  DEFAULT 0.0,
--     isin_code          VARCHAR(50),
--     logo_url           TEXT,
--     listing_date       DATE,
--     website            VARCHAR(255),
--     candle_table_name  VARCHAR(50)  NOT NULL,
--     created_at         TIMESTAMPTZ  DEFAULT now()
-- );
--
-- -- ── EGX Stock Candle Tables ───────────────────────────────────────────────────
-- CREATE TABLE tmgh_candles   (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
-- CREATE TABLE comi_candles   (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
-- CREATE TABLE fwry_candles   (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
-- CREATE TABLE abuk_candles   (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
-- CREATE TABLE east_candles   (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
-- CREATE TABLE efih_candles   (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
-- CREATE TABLE emfd_candles   (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
-- CREATE TABLE etel_candles   (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
-- CREATE TABLE expa_candles   (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
-- CREATE TABLE hrho_candles   (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
-- CREATE TABLE iron_candles   (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
-- CREATE TABLE oras_candles   (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
-- CREATE TABLE swdy_candles   (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
--
-- -- ── Index Candle Tables ───────────────────────────────────────────────────────
-- CREATE TABLE egx30_candles    (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
-- CREATE TABLE egx70ewi_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
--
-- -- ── Commodities Candle Tables ─────────────────────────────────────────────────
-- CREATE TABLE gold_candles   (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
-- CREATE TABLE silver_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
--
-- -- Gold / Material prices snapshot table
-- CREATE TABLE material_prices (
--     id          BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
--     timestamp   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
--     price_24k   NUMERIC(10, 2),
--     price_21k   NUMERIC(10, 2),
--     price_18k   NUMERIC(10, 2)
-- );
--
--
-- -- ==============================================================================
-- -- 10. STOCKS DATA — EGX Stocks
-- -- ==============================================================================
--
-- INSERT INTO stocks (symbol, company_name_en, company_name_ar, sector, candle_table_name, isin_code, logo_url, listing_date, website, total_shares, description) VALUES
-- (
--     'TMGH', 'Talaat Moustafa Group', 'مجموعة طلعت مصطفى', 'Real Estate', 'tmgh_candles', 'EGS65001C013',
--     'https://drive.google.com/uc?export=view&id=1uUYqPlcZK4wmb-CO62mS-sYwYYNWmBoU',
--     '2007-11-01', 'https://www.tmg.com.eg', 2063562286,
--     'Talaat Moustafa Group Holding is one of the largest real estate developers in Egypt.'
-- ),
-- (
--     'COMI', 'Commercial International Bank', 'البنك التجاري الدولي', 'Banks', 'comi_candles', 'EGS60121C018',
--     'https://drive.google.com/uc?export=view&id=1yidPsldOPlXn6TRRX-bWJfFTliAXaK5Z',
--     '1995-01-02', 'https://www.cibeg.com', 3019080000,
--     'Commercial International Bank (CIB) is the leading private sector bank in Egypt.'
-- ),
-- (
--     'FWRY', 'Fawry', 'فوري لتكنولوجيا البنوك', 'Technology', 'fwry_candles', 'EGS745L1C014',
--     'https://drive.google.com/uc?export=view&id=1vmLYAgQ7uLJvJDKhje3Jj83b9mmXjgK9',
--     '2019-08-08', 'https://fawry.com', 1709625000,
--     'Fawry is the leading digital transformation and e-payments platform in Egypt.'
-- ),
-- (
--     'ABUK', 'Abu Qir Fertilizers', 'أبوقير للأسمدة', 'Basic Resources', 'abuk_candles', 'EGS38191C010',
--     'https://drive.google.com/uc?export=view&id=11aUTCcmxssUxs56faoeHGg8EZVLzFkCu',
--     '1994-09-27', 'https://abuqir.com', 1261875000,
--     'Abu Qir Fertilizers and Chemicals Industries is one of the largest producers of nitrogenous fertilizers.'
-- ),
-- (
--     'EAST', 'Eastern Company', 'ايسترن كومباني', 'Food, Beverage & Tobacco', 'east_candles', 'EGS30221C013',
--     'https://t3.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=http://easternegypt.com&size=256',
--     '1995-09-27', 'https://www.easternegypt.com', 2230000000,
--     'Eastern Company is the dominant manufacturer of tobacco products in Egypt.'
-- ),
-- (
--     'EFIH', 'e-finance', 'إي فاينانس', 'Non-bank Financial Services', 'efih_candles', 'EGS74051C018',
--     'https://drive.google.com/uc?export=view&id=1ZSuiEyPAiI5ZslIrDxkj1hTl7TlhU6r9',
--     '2021-10-20', 'https://efinanceinvestment.com', 1848888889,
--     'e-finance is a leading developer of digital payments infrastructures.'
-- ),
-- (
--     'EMFD', 'Emaar Misr', 'إعمار مصر', 'Real Estate', 'emfd_candles', 'EGS65901C018',
--     'https://drive.google.com/uc?export=view&id=1ngj6WCwdjORsJ0Nv6J7nIVytqRXz1SVC',
--     '2015-07-05', 'https://www.emaarmisr.com', 4800000000,
--     'Emaar Misr is a leading real estate developer known for its prestigious communities.'
-- ),
-- (
--     'ETEL', 'Telecom Egypt (WE)', 'المصرية للاتصالات', 'Telecommunications', 'etel_candles', 'EGS48031C016',
--     'https://drive.google.com/uc?export=view&id=1Yboxs11RmdHvN1bOCBUE_IVbegWsqtV4',
--     '2005-12-14', 'https://www.te.eg', 1707071600,
--     'Telecom Egypt is the primary telephone company in Egypt (WE).'
-- ),
-- (
--     'EXPA', 'EBank', 'البنك المصري لتنمية الصادرات', 'Banks', 'expa_candles', 'EGS60281C019',
--     'https://drive.google.com/uc?export=view&id=1z5QABqMt19GP2LUBftW7WissKJa40cUt',
--     '1984-02-01', 'https://ebank.com.eg', 527360000,
--     'EBank (Export Development Bank of Egypt) supports exporters.'
-- ),
-- (
--     'HRHO', 'EFG Holding', 'مجموعة إي إف جي القابضة', 'Non-bank Financial Services', 'hrho_candles', 'EGS69161C011',
--     'https://drive.google.com/uc?export=view&id=1VYhM7DyJfN5nQIqLyl4Og4hU3wwbOr0h',
--     '1999-02-17', 'https://www.efgholding.com', 1458537000,
--     'EFG Holding is a leading financial services corporation.'
-- ),
-- (
--     'IRON', 'Ezz Steel', 'حديد عز', 'Basic Resources', 'iron_candles', 'EGS3A221C013',
--     'https://drive.google.com/uc?export=view&id=1eCPaTzcY2c_RQktqtT2rp8ICQ1y4mE8t',
--     '1999-05-23', 'https://www.ezzsteel.com', 543265000,
--     'Ezz Steel is the largest independent steel producer in the Middle East.'
-- ),
-- (
--     'ORAS', 'Orascom Construction', 'أوراسكوم كونستراكشون', 'Construction & Materials', 'oras_candles', 'EGS95001C011',
--     'https://drive.google.com/uc?export=view&id=1eCPaTzcY2c_RQktqtT2rp8ICQ1y4mE8t',
--     '2015-03-11', 'https://www.orascom.com', 116761379,
--     'Orascom Construction is a leading global engineering and construction contractor.'
-- ),
-- (
--     'SWDY', 'Elsewedy Electric', 'السويدي إليكتريك', 'Industrial Goods', 'swdy_candles', 'EGS3G0Z1C014',
--     'https://drive.google.com/uc?export=view&id=1Rgb46jgX3l9pAt3VB-kFi3-zIdoumwxZ',
--     '2006-05-24', 'https://www.elsewedyelectric.com', 2184180000,
--     'Elsewedy Electric is a global leader in integrated energy solutions.'
-- )
-- ON CONFLICT (symbol) DO NOTHING;
--
--
-- -- ==============================================================================
-- -- 11. STOCKS DATA — Commodities (Gold & Silver)
-- -- ==============================================================================
--
-- INSERT INTO stocks (symbol, company_name_en, company_name_ar, sector, description, candle_table_name, isin_code, logo_url, listing_date, website)
-- VALUES
-- (
--     'GOLD', 'Gold Spot / Egyptian Market', 'الذهب - السوق المصري والعالمي', 'Materials',
--     'Live tracking of global and local gold prices.',
--     'gold_candles', 'XAU-EGP',
--     'https://drive.google.com/uc?export=view&id=1G3bTw96_-DN0CgMGBAQcIYRhrpioxeaV',
--     '2025-01-01', 'https://goldprice.org'
-- ),
-- (
--     'SILVER', 'Silver Local/Global', 'الفضة - محلي وعالمي', 'Materials',
--     'Live tracking of global and local silver prices (999 & 800 karat).',
--     'silver_candles', 'XAG-EGP',
--     'https://drive.google.com/uc?export=view&id=1Lz-f_E_tUjP4o7S0Y3qG7Q-U3X6jVvGz',
--     '2025-01-01', 'https://goldprice.org'
-- )
-- ON CONFLICT (symbol) DO NOTHING;
--
--
-- -- ==============================================================================
-- -- 12. STOCKS DATA — EGX Indices
-- -- ==============================================================================
--
-- INSERT INTO stocks (symbol, company_name_en, company_name_ar, sector, description, total_shares, prev_close, isin_code, logo_url, listing_date, website, candle_table_name)
-- VALUES
-- (
--     'EGX30', 'EGX 30 Index', 'مؤشر إي جي إكس 30', 'Indices',
--     'The main benchmark index of the Egyptian Exchange, tracking the top 30 companies by liquidity and market cap. --split-- COMI,TMGH,FWRY,ABUK,EAST,EFIH,EMFD,ETEL,EXPA,HRHO,IRON,ORAS,SWDY,EKHO,JUFO,MFOT,MNHD,OCDI,PHDC,HELI,ADIB,SKPC,ESRS,BTEL,CLHO,RMDA,MOIL,MICH,DSCW,MTIE',
--     0, 41102.8, 'INDEX-EGX30',
--     'https://drive.google.com/uc?export=view&id=1a7Ig_mpMm3MhFHy8KFdNXXdEECr3M-W9',
--     '1998-01-01', 'https://www.egx.com.eg', 'egx30_candles'
-- ),
-- (
--     'EGX70', 'EGX 70 EWI', 'مؤشر إي جي إكس 70', 'Indices',
--     'Tracking the performance of 70 small and medium-sized companies in the Egyptian market using equal weighting. --split-- AMOC,EGAL,NCGC,ISPH,PORT,CCAP,BINV,ACGC,AFMC,AJWA,ALCN,ALRE,AMIA,ARCC,ASPI,ATQA,BRAI,CANA,COPR,DAPH,DGTW,EDBM,EFTG,EGCH,EGSA,EITP,ELSH,ENGC,EPCO,EPHI,EQDP,ERAS,ESGI,GGCC,GTHE,GTUN,IFAP,KRDI,LCSW,MCQE,MEPA,MGED,MILS,MPRC,MTIE,NAHO,NEDA,ODIN,OLFI,PRDC,PRMH,RAYA,REAC,RKHT,SAUD,SDTI,SMPP,SPMD,UEGC,UNRE,UPMS,UTAD,VERT,WAPH,ZMID',
--     0, 0.0, 'INDEX-EGX70',
--     'https://drive.google.com/uc?export=view&id=1jlrG1Z8s9-pRT7NN9Uod61JSnIDT0jnW',
--     '2009-03-01', 'https://www.egx.com.eg', 'egx70ewi_candles'
-- )
-- ON CONFLICT (symbol) DO NOTHING;
--
--
-- -- ==============================================================================
-- -- 13. STOCKS DATA — Original Crypto (BTC, ETH, SOL, XRP, DOGE, BNB, ADA, AVAX, DOT, LINK)
-- -- ==============================================================================
--
-- INSERT INTO stocks (symbol, company_name_en, company_name_ar, sector, candle_table_name, logo_url, website, description, listing_date, total_shares, isin_code)
-- VALUES
-- (
--     'BTC', 'Bitcoin', 'بيتكوين', 'Crypto', 'API',
--     'https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Bitcoin.svg/1200px-Bitcoin.svg.png',
--     'https://bitcoin.org',
--     'Bitcoin is the first decentralized cryptocurrency, often referred to as "digital gold". It operates on a peer-to-peer network without any central authority, serving as a global store of value and a hedge against inflation.',
--     '2009-01-03', 21000000, 'CRYPTO-BTC'
-- ),
-- (
--     'ETH', 'Ethereum', 'إيثيريوم', 'Crypto', 'API',
--     'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Ethereum-icon-purple.svg/1200px-Ethereum-icon-purple.svg.png',
--     'https://ethereum.org',
--     'Ethereum is the leading programmable blockchain platform. It enables developers to build decentralized applications (dApps) and smart contracts, serving as the foundation for DeFi and NFTs.',
--     '2015-07-30', 120000000, 'CRYPTO-ETH'
-- ),
-- (
--     'SOL', 'Solana', 'سولانا', 'Crypto', 'API',
--     'https://cryptologos.cc/logos/solana-sol-logo.png',
--     'https://solana.com',
--     'Solana is a high-performance blockchain known for incredibly fast transaction speeds and extremely low fees compared to Ethereum.',
--     '2020-03-16', 570000000, 'CRYPTO-SOL'
-- ),
-- (
--     'XRP', 'Ripple', 'ريبل', 'Crypto', 'API',
--     'https://cryptologos.cc/logos/xrp-xrp-logo.png',
--     'https://ripple.com',
--     'XRP is a digital asset built for global payments. It offers financial institutions a fast, reliable, and cost-effective option for cross-border transactions.',
--     '2012-06-02', 100000000000, 'CRYPTO-XRP'
-- ),
-- (
--     'DOGE', 'Dogecoin', 'دوج كوين', 'Crypto', 'API',
--     'https://cryptologos.cc/logos/dogecoin-doge-logo.png',
--     'https://dogecoin.com',
--     'Dogecoin is an open-source peer-to-peer digital currency. Originally created as a meme, it has evolved into a popular cryptocurrency used for micro-transactions and tipping.',
--     '2013-12-06', 140000000000, 'CRYPTO-DOGE'
-- ),
-- (
--     'BNB', 'Binance Coin', 'باينانس كوين', 'Crypto', 'API',
--     'https://cryptologos.cc/logos/bnb-bnb-logo.png',
--     'https://www.binance.com',
--     'BNB is the native utility token of the Binance ecosystem, used to pay for transaction fees on the Binance exchange and various decentralized applications.',
--     '2017-07-08', 145000000, 'CRYPTO-BNB'
-- ),
-- (
--     'ADA', 'Cardano', 'كاردانو', 'Crypto', 'API',
--     'https://cryptologos.cc/logos/cardano-ada-logo.png',
--     'https://cardano.org',
--     'Cardano is a proof-of-stake blockchain platform founded on peer-reviewed research, aiming to provide a more secure and scalable infrastructure.',
--     '2017-09-23', 45000000000, 'CRYPTO-ADA'
-- ),
-- (
--     'AVAX', 'Avalanche', 'أفالانش', 'Crypto', 'API',
--     'https://cryptologos.cc/logos/avalanche-avax-logo.png',
--     'https://www.avax.network',
--     'Avalanche is a future-proof blockchain built to scale, offering near-instant transaction finality.',
--     '2020-09-21', 720000000, 'CRYPTO-AVAX'
-- ),
-- (
--     'DOT', 'Polkadot', 'بولكادوت', 'Crypto', 'API',
--     'https://cryptologos.cc/logos/polkadot-new-dot-logo.png',
--     'https://polkadot.network',
--     'Polkadot is a multichain protocol that connects and secures a network of specialized blockchains, facilitating the cross-chain transfer of any data or asset types.',
--     '2020-05-26', 1300000000, 'CRYPTO-DOT'
-- ),
-- (
--     'LINK', 'Chainlink', 'تشين لينك', 'Crypto', 'API',
--     'https://cryptologos.cc/logos/chainlink-link-logo.png',
--     'https://chain.link',
--     'Chainlink is a decentralized oracle network enabling smart contracts to securely connect to real-world data, events, and payments.',
--     '2017-09-19', 1000000000, 'CRYPTO-LINK'
-- )
-- ON CONFLICT (symbol) DO NOTHING;
--
--
-- -- ==============================================================================
-- -- 14. RLS FOR STOCKS & CANDLE TABLES
-- -- ==============================================================================
--
-- ALTER TABLE stocks           ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE material_prices  ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE tmgh_candles     ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE comi_candles     ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE fwry_candles     ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE abuk_candles     ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE east_candles     ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE efih_candles     ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE emfd_candles     ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE etel_candles     ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE expa_candles     ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE hrho_candles     ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE iron_candles     ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE oras_candles     ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE swdy_candles     ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE egx30_candles    ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE egx70ewi_candles ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE gold_candles     ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE silver_candles   ENABLE ROW LEVEL SECURITY;
--
-- CREATE POLICY "Public Read Stocks"          ON stocks           FOR SELECT USING (true);
-- CREATE POLICY "Public Read Material Prices" ON material_prices  FOR SELECT USING (true);
-- CREATE POLICY "Public Read TMGH"            ON tmgh_candles     FOR SELECT USING (true);
-- CREATE POLICY "Public Read COMI"            ON comi_candles     FOR SELECT USING (true);
-- CREATE POLICY "Public Read FWRY"            ON fwry_candles     FOR SELECT USING (true);
-- CREATE POLICY "Public Read ABUK"            ON abuk_candles     FOR SELECT USING (true);
-- CREATE POLICY "Public Read EAST"            ON east_candles     FOR SELECT USING (true);
-- CREATE POLICY "Public Read EFIH"            ON efih_candles     FOR SELECT USING (true);
-- CREATE POLICY "Public Read EMFD"            ON emfd_candles     FOR SELECT USING (true);
-- CREATE POLICY "Public Read ETEL"            ON etel_candles     FOR SELECT USING (true);
-- CREATE POLICY "Public Read EXPA"            ON expa_candles     FOR SELECT USING (true);
-- CREATE POLICY "Public Read HRHO"            ON hrho_candles     FOR SELECT USING (true);
-- CREATE POLICY "Public Read IRON"            ON iron_candles     FOR SELECT USING (true);
-- CREATE POLICY "Public Read ORAS"            ON oras_candles     FOR SELECT USING (true);
-- CREATE POLICY "Public Read SWDY"            ON swdy_candles     FOR SELECT USING (true);
-- CREATE POLICY "Public Read EGX30"           ON egx30_candles    FOR SELECT USING (true);
-- CREATE POLICY "Public Read EGX70"           ON egx70ewi_candles FOR SELECT USING (true);
-- CREATE POLICY "Public Read Gold"            ON gold_candles     FOR SELECT USING (true);
-- CREATE POLICY "Public Read Silver"          ON silver_candles   FOR SELECT USING (true);
--
-- -- Disable RLS on candle tables for Python data-ingestion scripts
-- -- (Re-enable once you switch to Service Role Key in your Python uploader)
-- ALTER TABLE tmgh_candles     DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE comi_candles     DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE fwry_candles     DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE abuk_candles     DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE east_candles     DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE efih_candles     DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE emfd_candles     DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE etel_candles     DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE expa_candles     DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE hrho_candles     DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE iron_candles     DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE oras_candles     DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE swdy_candles     DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE egx30_candles    DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE egx70ewi_candles DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE gold_candles     DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE silver_candles   DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE stocks           DISABLE ROW LEVEL SECURITY;
-- ALTER TABLE material_prices  DISABLE ROW LEVEL SECURITY;
--
--
-- -- ==============================================================================
-- -- 15. CHART RPC FUNCTIONS
-- -- ==============================================================================
--
-- -- ── A. get_chart_history — universal candle fetcher by symbol ─────────────────
-- CREATE OR REPLACE FUNCTION get_chart_history(
--     target_symbol TEXT,
--     before_date   TIMESTAMPTZ DEFAULT NULL,
--     limit_count   INT         DEFAULT 100
-- )
-- RETURNS TABLE (
--     candle_time TIMESTAMPTZ,
--     open        FLOAT4,
--     high        FLOAT4,
--     low         FLOAT4,
--     close       FLOAT4,
--     volume      BIGINT,
--     res         VARCHAR(5)
-- ) LANGUAGE plpgsql AS $$
-- DECLARE
--     target_table TEXT;
--     query_date   TIMESTAMPTZ;
-- BEGIN
--     SELECT candle_table_name INTO target_table
--     FROM   stocks WHERE symbol = target_symbol;
--
--     IF target_table IS NULL THEN RETURN; END IF;
--
--     query_date := COALESCE(before_date, NOW() + INTERVAL '100 years');
--
--     RETURN QUERY EXECUTE format('
--         WITH latest_data AS (
--             SELECT timestamp, open, high, low, close, volume, timeframe
--             FROM %I
--             WHERE timestamp < %L
--             ORDER BY timestamp DESC
--             LIMIT %s
--         )
--         SELECT timestamp AS candle_time, open, high, low, close, volume, timeframe AS res
--         FROM latest_data
--         ORDER BY timestamp ASC;
--     ', target_table, query_date, limit_count);
-- END;
-- $$;
--
-- -- ── B. get_gold_chart_data — gold/silver candle fetcher ───────────────────────
-- CREATE OR REPLACE FUNCTION get_gold_chart_data(
--     days_limit  INT     DEFAULT 1,
--     res_filter  VARCHAR DEFAULT '1d'
-- )
-- RETURNS TABLE (
--     candle_time TIMESTAMPTZ,
--     open        NUMERIC,
--     high        NUMERIC,
--     low         NUMERIC,
--     close       NUMERIC,
--     vol         NUMERIC
-- ) LANGUAGE plpgsql AS $$
-- BEGIN
--     RETURN QUERY
--     SELECT
--         timestamp AS candle_time,
--         open, high, low, close,
--         0::numeric AS vol
--     FROM gold_candles
--     WHERE timestamp >= NOW() - (days_limit || ' days')::INTERVAL
--       AND timeframe = res_filter
--     ORDER BY timestamp ASC;
-- END;
-- $$;
--
-- -- ── C. get_stocks_with_sparklines — trending stocks for home feed ─────────────
-- CREATE OR REPLACE FUNCTION get_stocks_with_sparklines(row_limit INT)
-- RETURNS JSONB LANGUAGE plpgsql AS $$
-- DECLARE
--     stock_record  RECORD;
--     final_json    JSONB  := '[]'::JSONB;
--     latest_price  FLOAT4;
--     calc_change   FLOAT4;
--     spark_data    JSONB;
-- BEGIN
--     FOR stock_record IN (
--         SELECT * FROM stocks WHERE sector != 'Indices' AND candle_table_name != 'API' LIMIT row_limit
--     )
--     LOOP
--         IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = stock_record.candle_table_name) THEN
--             EXECUTE format('SELECT close FROM %I ORDER BY timestamp DESC LIMIT 1', stock_record.candle_table_name)
--                 INTO latest_price;
--
--             EXECUTE format('SELECT json_agg(c) FROM (SELECT close FROM %I ORDER BY timestamp DESC LIMIT 20) sub(c)', stock_record.candle_table_name)
--                 INTO spark_data;
--
--             calc_change := CASE WHEN stock_record.prev_close > 0
--                            THEN ((latest_price - stock_record.prev_close) / stock_record.prev_close) * 100
--                            ELSE 0 END;
--
--             final_json := final_json || jsonb_build_object(
--                 'id',              stock_record.id,
--                 'symbol',          stock_record.symbol,
--                 'company_name_en', stock_record.company_name_en,
--                 'current_price',   latest_price,
--                 'change_percent',  ROUND(calc_change::numeric, 2),
--                 'logo_url',        stock_record.logo_url,
--                 'sparkline_data',  COALESCE(spark_data, '[]'::JSONB)
--             );
--         END IF;
--     END LOOP;
--     RETURN final_json;
-- END;
-- $$;
--
-- -- ── D. get_indices_with_sparklines — EGX30 & EGX70 overview ──────────────────
-- CREATE OR REPLACE FUNCTION get_indices_with_sparklines()
-- RETURNS JSONB LANGUAGE plpgsql AS $$
-- DECLARE
--     index_record  RECORD;
--     final_json    JSONB  := '[]'::JSONB;
--     latest_price  FLOAT4;
--     calc_change   FLOAT4;
--     spark_data    JSONB;
-- BEGIN
--     FOR index_record IN (SELECT * FROM stocks WHERE sector = 'Indices' LIMIT 2)
--     LOOP
--         IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = index_record.candle_table_name) THEN
--             EXECUTE format('SELECT close FROM %I ORDER BY timestamp DESC LIMIT 1', index_record.candle_table_name)
--                 INTO latest_price;
--
--             EXECUTE format('SELECT json_agg(c) FROM (SELECT close FROM %I ORDER BY timestamp DESC LIMIT 20) sub(c)', index_record.candle_table_name)
--                 INTO spark_data;
--
--             calc_change := CASE WHEN index_record.prev_close > 0
--                            THEN ((latest_price - index_record.prev_close) / index_record.prev_close) * 100
--                            ELSE 0 END;
--
--             final_json := final_json || jsonb_build_object(
--                 'id',             index_record.id,
--                 'symbol',         index_record.symbol,
--                 'current_price',  latest_price,
--                 'change_percent', ROUND(calc_change::numeric, 2),
--                 'logo_url',       index_record.logo_url,
--                 'sparkline_data', COALESCE(spark_data, '[]'::JSONB)
--             );
--         END IF;
--     END LOOP;
--     RETURN final_json;
-- END;
-- $$;
--
-- -- ── E. get_watchlist_with_sparklines — user watchlist with live prices ─────────
-- CREATE OR REPLACE FUNCTION get_watchlist_with_sparklines(viewer_id UUID)
-- RETURNS JSONB LANGUAGE plpgsql AS $$
-- DECLARE
--     stock_record  RECORD;
--     final_json    JSONB  := '[]'::JSONB;
--     latest_price  FLOAT4;
--     calc_change   FLOAT4;
--     spark_data    JSONB;
-- BEGIN
--     FOR stock_record IN (
--         SELECT s.* FROM stocks s
--         JOIN user_watchlist uw ON s.symbol = uw.stock_symbol
--         WHERE uw.user_id = viewer_id
--     )
--     LOOP
--         IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = stock_record.candle_table_name) THEN
--             EXECUTE format('SELECT close FROM %I ORDER BY timestamp DESC LIMIT 1', stock_record.candle_table_name)
--                 INTO latest_price;
--
--             EXECUTE format('SELECT json_agg(c) FROM (SELECT close FROM %I ORDER BY timestamp DESC LIMIT 20) sub(c)', stock_record.candle_table_name)
--                 INTO spark_data;
--
--             calc_change := CASE WHEN stock_record.prev_close > 0
--                            THEN ((latest_price - stock_record.prev_close) / stock_record.prev_close) * 100
--                            ELSE 0 END;
--
--             final_json := final_json || jsonb_build_object(
--                 'id',              stock_record.id,
--                 'symbol',          stock_record.symbol,
--                 'company_name_en', stock_record.company_name_en,
--                 'current_price',   latest_price,
--                 'change_percent',  ROUND(calc_change::numeric, 2),
--                 'logo_url',        stock_record.logo_url,
--                 'sparkline_data',  COALESCE(spark_data, '[]'::JSONB)
--             );
--         END IF;
--     END LOOP;
--     RETURN final_json;
-- END;
-- $$;
--
--
-- -- ==============================================================================
-- -- END OF SCHEMA
-- -- ==============================================================================



-- ==============================================================================

-- 1. SETUP & CLEANUP (تنظيف كامل)

-- ==============================================================================


-- Backup Watchlist Data

CREATE TABLE IF NOT EXISTS temp_watchlist_backup AS SELECT * FROM public.user_watchlist;


-- Drop Triggers

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

DROP TRIGGER IF EXISTS on_comment_created ON public.comments;

DROP TRIGGER IF EXISTS on_post_like ON public.post_votes; -- New Trigger Drop


-- Drop Functions

DROP FUNCTION IF EXISTS get_posts_with_status CASCADE;

DROP FUNCTION IF EXISTS get_comments_with_status CASCADE;

DROP FUNCTION IF EXISTS handle_new_user CASCADE;

DROP FUNCTION IF EXISTS handle_new_comment_notification CASCADE;

DROP FUNCTION IF EXISTS handle_new_like_notification CASCADE; -- New Function Drop


-- Drop Tables (Order matters)

DROP TABLE IF EXISTS public.notifications CASCADE;

DROP TABLE IF EXISTS public.comment_votes CASCADE;

DROP TABLE IF EXISTS public.post_votes CASCADE;

DROP TABLE IF EXISTS public.bookmarks CASCADE;

DROP TABLE IF EXISTS public.follows CASCADE;

DROP TABLE IF EXISTS public.comments CASCADE;

DROP TABLE IF EXISTS public.user_watchlist CASCADE;

DROP TABLE IF EXISTS public.posts CASCADE;

DROP TABLE IF EXISTS public.profiles CASCADE;


-- ==============================================================================

-- 2. CREATE TABLES (إنشاء الجداول)

-- ==============================================================================


-- A. Profiles

CREATE TABLE public.profiles (

    id uuid REFERENCES auth.users ON DELETE CASCADE NOT NULL PRIMARY KEY,

    email varchar(255) UNIQUE NOT NULL,

    name varchar(255),

    avatar_url text,

    bio text,

    fcm_token text,

    last_active_at timestamptz,

    created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,

    updated_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL

);


-- B. User Watchlist

CREATE TABLE public.user_watchlist (

    user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,

    stock_symbol text NOT NULL,

    created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,

    PRIMARY KEY (user_id, stock_symbol)

);


-- C. Follows

CREATE TABLE public.follows (

    follower_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,

    following_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,

    created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,

    PRIMARY KEY (follower_id, following_id),

    CONSTRAINT cant_follow_self CHECK (follower_id != following_id)

);


-- D. Posts

CREATE TABLE public.posts (

    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,

    user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,

    content text,

    image_url text,

    sentiment varchar(10) CHECK (sentiment in ('bullish', 'bearish')),

    cashtags text[],

    created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL

);


-- E. Post Votes (Likes/Dislikes)

CREATE TABLE public.post_votes (

    user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,

    post_id bigint REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,

    vote_type int NOT NULL CHECK (vote_type in (1, -1)),

    created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,

    PRIMARY KEY (user_id, post_id)

);


-- F. Bookmarks

CREATE TABLE public.bookmarks (

    user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,

    post_id bigint REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,

    created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,

    PRIMARY KEY (user_id, post_id)

);


-- G. Comments

CREATE TABLE public.comments (

    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,

    user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,

    post_id bigint REFERENCES public.posts(id) ON DELETE CASCADE NOT NULL,

    parent_id bigint REFERENCES public.comments(id) ON DELETE CASCADE, -- NULL = Root Comment

    content text NOT NULL,

    created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL

);


-- H. Comment Votes

CREATE TABLE public.comment_votes (

    user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,

    comment_id bigint REFERENCES public.comments(id) ON DELETE CASCADE NOT NULL,

    vote_type int NOT NULL CHECK (vote_type in (1, -1)),

    created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL,

    PRIMARY KEY (user_id, comment_id)

);


-- I. Notifications (Updated to support 'like')

CREATE TABLE public.notifications (

    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,

    recipient_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,

    sender_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,

    resource_id bigint NOT NULL,

    type text NOT NULL CHECK (type IN ('comment', 'reply', 'like', 'follow')),

    title text,

    body text,

    is_read boolean DEFAULT false,

    created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL

);


-- ==============================================================================

-- 3. DATA RESTORATION & INDEXES (استرجاع البيانات وتحسين الأداء)

-- ==============================================================================


-- Restore Profiles

INSERT INTO public.profiles (id, email, name, avatar_url, created_at, updated_at)

SELECT

    id,

    email,

    COALESCE(raw_user_meta_data->>'name', raw_user_meta_data->>'full_name', split_part(email, '@', 1)),

    COALESCE(raw_user_meta_data->>'avatar_url', raw_user_meta_data->>'picture'),

    created_at,

    COALESCE(updated_at, created_at)

FROM auth.users

ON CONFLICT (id) DO NOTHING;


-- Restore Watchlist

INSERT INTO public.user_watchlist (user_id, stock_symbol, created_at)

SELECT t.user_id, t.stock_symbol, t.created_at

FROM temp_watchlist_backup t

JOIN public.profiles p ON t.user_id = p.id

ON CONFLICT DO NOTHING;


DROP TABLE IF EXISTS temp_watchlist_backup;


-- 🚀 Indexes for Performance (New Addition)

CREATE INDEX idx_posts_cashtags ON public.posts USING GIN (cashtags); -- Fast stock search

CREATE INDEX idx_comments_post_id ON public.comments (post_id);

CREATE INDEX idx_notifications_recipient_id ON public.notifications (recipient_id);

CREATE INDEX idx_post_votes_post_id ON public.post_votes (post_id);


-- ==============================================================================

-- 4. TRIGGERS (المحرك الآلي للإشعارات والبروفايل)

-- ==============================================================================


-- A. Auto-Create Profile

CREATE OR REPLACE FUNCTION public.handle_new_user()

RETURNS TRIGGER AS $$

BEGIN

  INSERT INTO public.profiles (id, email, name, avatar_url)

  VALUES (

    new.id,

    new.email,

    COALESCE(new.raw_user_meta_data->>'name', new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),

    COALESCE(new.raw_user_meta_data->>'avatar_url', new.raw_user_meta_data->>'picture')

  )

  ON CONFLICT (id) DO UPDATE

  SET

    name = EXCLUDED.name,

    avatar_url = COALESCE(EXCLUDED.avatar_url, public.profiles.avatar_url);

  RETURN new;

END;

$$ LANGUAGE plpgsql SECURITY DEFINER;


CREATE TRIGGER on_auth_user_created

  AFTER INSERT ON auth.users

  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();


-- B. Auto-Notification: Comments & Replies

CREATE OR REPLACE FUNCTION public.handle_new_comment_notification()

RETURNS TRIGGER AS $$

DECLARE

    post_owner_id uuid;

    parent_comment_owner_id uuid;

    sender_name text;

    post_title text; -- Optional, if you want to include post context

BEGIN

    SELECT name INTO sender_name FROM public.profiles WHERE id = new.user_id;



    -- IF REPLY

    IF new.parent_id IS NOT NULL THEN

        SELECT user_id INTO parent_comment_owner_id FROM public.comments WHERE id = new.parent_id;

        IF parent_comment_owner_id != new.user_id THEN

            INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body)

            VALUES (parent_comment_owner_id, new.user_id, new.post_id, 'reply', 'New Reply', sender_name || ' replied to you');

        END IF;

    -- IF ROOT COMMENT

    ELSE

        SELECT user_id INTO post_owner_id FROM public.posts WHERE id = new.post_id;

        IF post_owner_id != new.user_id THEN

            INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body)

            VALUES (post_owner_id, new.user_id, new.post_id, 'comment', 'New Comment', sender_name || ' commented on your post');

        END IF;

    END IF;

    RETURN new;

END;

$$ LANGUAGE plpgsql SECURITY DEFINER;


CREATE TRIGGER on_comment_created

  AFTER INSERT ON public.comments

  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_comment_notification();


-- C. Auto-Notification: Likes (New Addition)

CREATE OR REPLACE FUNCTION public.handle_new_like_notification()

RETURNS TRIGGER AS $$

DECLARE

    post_owner_id uuid;

    sender_name text;

    content_snippet text;

BEGIN

    SELECT name INTO sender_name FROM public.profiles WHERE id = new.user_id;

    SELECT user_id, left(content, 20) INTO post_owner_id, content_snippet FROM public.posts WHERE id = new.post_id;


    IF post_owner_id != new.user_id THEN

        INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body)

        VALUES (

            post_owner_id,

            new.user_id,

            new.post_id,

            'like',

            'New Like',

            sender_name || ' liked your post: ' || content_snippet || '...'

        );

    END IF;

    RETURN new;

END;

$$ LANGUAGE plpgsql SECURITY DEFINER;


CREATE TRIGGER on_post_like

  AFTER INSERT ON public.post_votes

  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_like_notification();



-- ==============================================================================

-- 5. RPC FUNCTIONS (APIs for Flutter)

-- ==============================================================================


-- A. Get Posts Feed

CREATE OR REPLACE FUNCTION get_posts_with_status(

  viewer_id uuid,

  target_user_id uuid,

  limit_val int,

  offset_val int,

  category_filter text DEFAULT NULL

)

RETURNS TABLE (

  id bigint, user_id uuid, content text, image_url text, sentiment text, cashtags text[],

  created_at timestamptz, user_name text, user_avatar text,

  likes_count bigint, dislikes_count bigint, comments_count bigint,

  is_liked boolean, is_bookmarked boolean

)

LANGUAGE plpgsql AS $$

BEGIN

  RETURN QUERY

  SELECT

    p.id, p.user_id, p.content, p.image_url, p.sentiment::text, p.cashtags, p.created_at,

    pr.name::text, pr.avatar_url::text,

    (SELECT count(*) FROM public.post_votes v WHERE v.post_id = p.id AND v.vote_type = 1),

    (SELECT count(*) FROM public.post_votes v WHERE v.post_id = p.id AND v.vote_type = -1),

    (SELECT count(*) FROM public.comments c WHERE c.post_id = p.id),

    EXISTS(SELECT 1 FROM public.post_votes v WHERE v.post_id = p.id AND v.user_id = viewer_id AND v.vote_type = 1),

    EXISTS(SELECT 1 FROM public.bookmarks b WHERE b.post_id = p.id AND b.user_id = viewer_id)

  FROM public.posts p

  LEFT JOIN public.profiles pr ON p.user_id = pr.id

  WHERE

    (target_user_id IS NULL OR p.user_id = target_user_id)

    AND

    (

      category_filter IS NULL

      OR

      EXISTS (

        SELECT 1

        FROM unnest(p.cashtags) AS tag

        WHERE tag ILIKE '%' || category_filter || '%'

      )

    )

  ORDER BY p.created_at DESC

  LIMIT limit_val OFFSET offset_val;

END;

$$;


-- B. Get Comments

CREATE OR REPLACE FUNCTION get_comments_with_status(viewer_id uuid, target_post_id bigint)

RETURNS TABLE (

  id bigint, post_id bigint, parent_id bigint, content text, created_at timestamptz,

  user_id uuid, user_name text, user_avatar text,

  likes_count bigint, dislikes_count bigint,

  user_vote_type int, parent_username text

)

LANGUAGE plpgsql AS $$

BEGIN

  RETURN QUERY

  SELECT

    c.id, c.post_id, c.parent_id, c.content, c.created_at, c.user_id,

    pr.name::text, pr.avatar_url::text,

    (SELECT count(*) FROM public.comment_votes cv WHERE cv.comment_id = c.id AND cv.vote_type = 1),

    (SELECT count(*) FROM public.comment_votes cv WHERE cv.comment_id = c.id AND cv.vote_type = -1),

    (SELECT vote_type FROM public.comment_votes cv WHERE cv.comment_id = c.id AND cv.user_id = viewer_id),

    (SELECT p2.name::text FROM public.comments c2 JOIN public.profiles p2 ON c2.user_id = p2.id WHERE c2.id = c.parent_id)

  FROM public.comments c

  LEFT JOIN public.profiles pr ON c.user_id = pr.id

  WHERE c.post_id = target_post_id

  ORDER BY c.created_at ASC;

END;

$$;-- -- ==============================================================================

-- -- 1. تنظيف شامل (Drop All) - تم التعديل لحل مشكلة التريجر

-- -- ==============================================================================


-- -- أولاً: نحذف التريجر المرتبط بجدول auth.users لتفكيك الارتباط

-- DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;


-- -- ثانياً: نحذف الدوال مع استخدام CASCADE لضمان حذف أي تبعيات متبقية

-- DROP FUNCTION IF EXISTS get_posts_with_status CASCADE;

-- DROP FUNCTION IF EXISTS get_comments_with_status CASCADE;

-- DROP FUNCTION IF EXISTS handle_new_user CASCADE;


-- -- ثالثاً: حذف الـ Views

-- DROP VIEW IF EXISTS posts_view;

-- DROP VIEW IF EXISTS comments_full_view;


-- -- رابعاً: حذف الجداول (بالترتيب من الابن للأب لتجنب مشاكل الـ Foreign Keys)

-- DROP TABLE IF EXISTS bookmarks;

-- DROP TABLE IF EXISTS user_watchlist;

-- DROP TABLE IF EXISTS comment_votes;

-- DROP TABLE IF EXISTS comments;

-- DROP TABLE IF EXISTS post_votes;

-- DROP TABLE IF EXISTS follows;

-- DROP TABLE IF EXISTS posts;

-- -- DROP TABLE IF EXISTS profiles; -- (متروك حسب رغبتك، لو عايز تمسح كله شيل الكومنت)



-- -- ==============================================================================

-- -- 2. إنشاء الجداول (Tables Structure)

-- -- ==============================================================================


-- -- A. Profiles

-- create table if not exists public.profiles (

--   id uuid references auth.users on delete cascade not null primary key,

--   email varchar(255) unique not null,

--   name varchar(255),

--   avatar_url varchar(255),

--   created_at timestamp with time zone default timezone('utc'::text, now()) not null,

--   updated_at timestamp with time zone default timezone('utc'::text, now()) not null

-- );


-- -- B. Follows

-- create table public.follows (

--   follower_id uuid references public.profiles(id) on delete cascade not null,

--   following_id uuid references public.profiles(id) on delete cascade not null,

--   created_at timestamp with time zone default timezone('utc'::text, now()) not null,

--   primary key (follower_id, following_id),

--   constraint cant_follow_self check (follower_id != following_id)

-- );


-- -- C. Watchlist (Stocks)

-- create table public.user_watchlist (

--   user_id uuid references public.profiles(id) on delete cascade not null,

--   stock_symbol text not null,

--   created_at timestamp with time zone default timezone('utc'::text, now()) not null,

--   primary key (user_id, stock_symbol)

-- );


-- -- D. Posts (شامل Sentiment & Cashtags)

-- create table public.posts (

--   id bigint generated by default as identity primary key,

--   user_id uuid references public.profiles(id) on delete cascade not null,

--   content text,

--   image_url text,

--   sentiment varchar(10) check (sentiment in ('bullish', 'bearish')),

--   cashtags text[],

--   created_at timestamp with time zone default timezone('utc'::text, now()) not null

-- );


-- -- E. Post Votes (Likes)

-- create table public.post_votes (

--   user_id uuid references public.profiles(id) on delete cascade not null,

--   post_id bigint references public.posts(id) on delete cascade not null,

--   vote_type int not null check (vote_type in (1, -1)),

--   created_at timestamp with time zone default timezone('utc'::text, now()) not null,

--   primary key (user_id, post_id)

-- );


-- -- F. Bookmarks (Saved Posts)

-- create table public.bookmarks (

--   user_id uuid references public.profiles(id) on delete cascade not null,

--   post_id bigint references public.posts(id) on delete cascade not null,

--   created_at timestamp with time zone default timezone('utc'::text, now()) not null,

--   primary key (user_id, post_id)

-- );


-- -- G. Comments (تدعم الردود parent_id)

-- create table public.comments (

--   id bigint generated by default as identity primary key,

--   user_id uuid references public.profiles(id) on delete cascade not null,

--   post_id bigint references public.posts(id) on delete cascade not null,

--   parent_id bigint references public.comments(id) on delete cascade,

--   content text not null,

--   created_at timestamp with time zone default timezone('utc'::text, now()) not null

-- );


-- -- H. Comment Votes (Likes on Comments)

-- create table public.comment_votes (

--   user_id uuid references public.profiles(id) on delete cascade not null,

--   comment_id bigint references public.comments(id) on delete cascade not null,

--   vote_type int not null check (vote_type in (1, -1)),

--   created_at timestamp with time zone default timezone('utc'::text, now()) not null,

--   primary key (user_id, comment_id)

-- );



-- -- ==============================================================================

-- -- 3. إنشاء الـ Views (للعرض العام)

-- -- ==============================================================================


-- create or replace view posts_view as

-- select

--   p.id, p.user_id, p.content, p.image_url, p.created_at, p.sentiment, p.cashtags,

--   pr.name as user_name, pr.avatar_url as user_avatar,

--   (select count(*) from public.post_votes v where v.post_id = p.id and v.vote_type = 1) as likes_count,

--   (select count(*) from public.post_votes v where v.post_id = p.id and v.vote_type = -1) as dislikes_count,

--   (select count(*) from public.comments c where c.post_id = p.id) as comments_count

-- from public.posts p

-- left join public.profiles pr on p.user_id = pr.id;


-- create or replace view comments_full_view as

-- select

--   c.id, c.post_id, c.parent_id, c.content, c.created_at, c.user_id,

--   pr.name as user_name, pr.avatar_url as user_avatar,

--   (select count(*) from public.comment_votes cv where cv.comment_id = c.id and cv.vote_type = 1) as likes_count,

--   (select count(*) from public.comment_votes cv where cv.comment_id = c.id and cv.vote_type = -1) as dislikes_count

-- from public.comments c

-- left join public.profiles pr on c.user_id = pr.id

-- order by c.created_at asc;



-- -- ==============================================================================

-- -- 4. سياسات الحماية (RLS Policies)

-- -- ==============================================================================


-- -- تفعيل RLS

-- alter table public.profiles enable row level security;

-- alter table public.posts enable row level security;

-- alter table public.comments enable row level security;

-- alter table public.follows enable row level security;

-- alter table public.post_votes enable row level security;

-- alter table public.comment_votes enable row level security;

-- alter table public.bookmarks enable row level security;

-- alter table public.user_watchlist enable row level security;


-- -- حذف السياسات القديمة (Safe Cleaning)

-- do $$ begin

--   drop policy if exists "Public profiles viewable" on profiles;

--   drop policy if exists "Users update own" on profiles;

--   drop policy if exists "Public posts viewable" on posts;

--   drop policy if exists "Users insert own posts" on posts;

--   drop policy if exists "Users delete own posts" on posts;

--   drop policy if exists "Public comments viewable" on comments;

--   drop policy if exists "Users insert own comments" on comments;

--   drop policy if exists "Users delete own comments" on comments;

--   drop policy if exists "Public votes viewable" on post_votes;

--   drop policy if exists "Users vote posts" on post_votes;

--   drop policy if exists "Users unvote posts" on post_votes;

--   drop policy if exists "Public comment votes viewable" on comment_votes;

--   drop policy if exists "Users vote comments" on comment_votes;

--   drop policy if exists "Users unvote comments" on comment_votes;

--   drop policy if exists "Public follows viewable" on follows;

--   drop policy if exists "Users follow" on follows;

--   drop policy if exists "Users unfollow" on follows;

--   drop policy if exists "Users view own bookmarks" on bookmarks;

--   drop policy if exists "Users bookmark posts" on bookmarks;

--   drop policy if exists "Users remove bookmark" on bookmarks;

--   drop policy if exists "Users view own watchlist" on user_watchlist;

--   drop policy if exists "Users add to watchlist" on user_watchlist;

--   drop policy if exists "Users remove from watchlist" on user_watchlist;

-- end $$;


-- -- إعادة إنشاء السياسات

-- create policy "Public profiles viewable" on profiles for select using (true);

-- create policy "Users update own" on profiles for update using (auth.uid() = id);


-- create policy "Public posts viewable" on posts for select using (true);

-- create policy "Users insert own posts" on posts for insert with check (auth.uid() = user_id);

-- create policy "Users delete own posts" on posts for delete using (auth.uid() = user_id);


-- create policy "Public comments viewable" on comments for select using (true);

-- create policy "Users insert own comments" on comments for insert with check (auth.uid() = user_id);

-- create policy "Users delete own comments" on comments for delete using (auth.uid() = user_id);


-- create policy "Public votes viewable" on post_votes for select using (true);

-- create policy "Users vote posts" on post_votes for insert with check (auth.uid() = user_id);

-- create policy "Users unvote posts" on post_votes for delete using (auth.uid() = user_id);


-- create policy "Public comment votes viewable" on comment_votes for select using (true);

-- create policy "Users vote comments" on comment_votes for insert with check (auth.uid() = user_id);

-- create policy "Users unvote comments" on comment_votes for delete using (auth.uid() = user_id);


-- create policy "Public follows viewable" on follows for select using (true);

-- create policy "Users follow" on follows for insert with check (auth.uid() = follower_id);

-- create policy "Users unfollow" on follows for delete using (auth.uid() = follower_id);


-- create policy "Users view own bookmarks" on bookmarks for select using (auth.uid() = user_id);

-- create policy "Users bookmark posts" on bookmarks for insert with check (auth.uid() = user_id);

-- create policy "Users remove bookmark" on bookmarks for delete using (auth.uid() = user_id);


-- create policy "Users view own watchlist" on user_watchlist for select using (auth.uid() = user_id);

-- create policy "Users add to watchlist" on user_watchlist for insert with check (auth.uid() = user_id);

-- create policy "Users remove from watchlist" on user_watchlist for delete using (auth.uid() = user_id);



-- -- ==============================================================================

-- -- 5. الدوال الذكية (RPC Functions) - الأهم للتطبيق

-- -- ==============================================================================


--                                     DROP FUNCTION IF EXISTS get_posts_with_status;


-- CREATE OR REPLACE FUNCTION get_posts_with_status(

--   viewer_id uuid,

--   target_user_id uuid,

--   limit_val int,

--   offset_val int,

--   category_filter text DEFAULT NULL

-- )

-- RETURNS TABLE (

--   id bigint, user_id uuid, content text, image_url text, sentiment text, cashtags text[],

--   created_at timestamptz, user_name text, user_avatar text,

--   likes_count bigint, dislikes_count bigint, comments_count bigint,

--   is_liked boolean, is_bookmarked boolean

-- )

-- LANGUAGE plpgsql AS $$

-- BEGIN

--   RETURN QUERY

--   SELECT

--     p.id, p.user_id, p.content, p.image_url, p.sentiment::text, p.cashtags, p.created_at,

--     pr.name::text, pr.avatar_url::text,

--     (SELECT count(*) FROM public.post_votes v WHERE v.post_id = p.id AND v.vote_type = 1),

--     (SELECT count(*) FROM public.post_votes v WHERE v.post_id = p.id AND v.vote_type = -1),

--     (SELECT count(*) FROM public.comments c WHERE c.post_id = p.id),

--     EXISTS(SELECT 1 FROM public.post_votes v WHERE v.post_id = p.id AND v.user_id = viewer_id AND v.vote_type = 1),

--     EXISTS(SELECT 1 FROM public.bookmarks b WHERE b.post_id = p.id AND b.user_id = viewer_id)

--   FROM public.posts p

--   LEFT JOIN public.profiles pr ON p.user_id = pr.id

--   WHERE

--     (target_user_id IS NULL OR p.user_id = target_user_id)

--     AND

--     (

--       category_filter IS NULL

--       OR

--       EXISTS (

--         SELECT 1

--         FROM unnest(p.cashtags) AS tag

--         WHERE tag ILIKE '%' || category_filter || '%'

--       )

--     )

--   ORDER BY p.created_at DESC

--   LIMIT limit_val OFFSET offset_val;

-- END;

-- $$;


-- -- B. جلب الكومنتات مع حالة اللايك واسم الشخص المردود عليه (لصفحة التفاصيل)

-- create or replace function get_comments_with_status(viewer_id uuid, target_post_id bigint)

-- returns table (

--   id bigint, post_id bigint, parent_id bigint, content text, created_at timestamptz,

--   user_id uuid, user_name text, user_avatar text,

--   likes_count bigint, dislikes_count bigint,

--   user_vote_type int, parent_username text

-- )

-- language plpgsql as $$

-- begin

--   return query

--   select

--     c.id, c.post_id, c.parent_id, c.content, c.created_at, c.user_id,

--     pr.name::text, pr.avatar_url::text,

--     (select count(*) from public.comment_votes cv where cv.comment_id = c.id and cv.vote_type = 1),

--     (select count(*) from public.comment_votes cv where cv.comment_id = c.id and cv.vote_type = -1),

--     (select vote_type from public.comment_votes cv where cv.comment_id = c.id and cv.user_id = viewer_id),

--     (select p2.name::text from public.comments c2 join public.profiles p2 on c2.user_id = p2.id where c2.id = c.parent_id)

--   from public.comments c

--   left join public.profiles pr on c.user_id = pr.id

--   where c.post_id = target_post_id

--   order by c.created_at asc;

-- end;

-- $$;


-- -- C. تريجر إنشاء البروفايل (لليوزرات الجدد)

-- create or replace function public.handle_new_user()

-- returns trigger as $$

-- begin

--   insert into public.profiles (id, email, name)

--   values (new.id, new.email, new.raw_user_meta_data->>'name');

--   return new;

-- end;

-- $$ language plpgsql security definer;


-- -- إعادة إنشاء التريجر

-- drop trigger if exists on_auth_user_created on auth.users;

-- create trigger on_auth_user_created

--   after insert on auth.users

--   for each row execute procedure public.handle_new_user();



-- -- ==============================================================================

-- -- 5-C. تعديل تريجر إنشاء البروفايل (لحل مشكلة الصورة)

-- -- ==============================================================================


-- create or replace function public.handle_new_user()

-- returns trigger as $$

-- begin

--   insert into public.profiles (id, email, name, avatar_url)

--   values (

--     new.id,

--     new.email,

--     -- محاولة جلب الاسم (لو ملقاش name يدور على full_name)

--     coalesce(new.raw_user_meta_data->>'name', new.raw_user_meta_data->>'full_name', new.email),

--     -- هنا التعديل: جلب الصورة من avatar_url أو picture

--     coalesce(new.raw_user_meta_data->>'avatar_url', new.raw_user_meta_data->>'picture')

--   );

--   return new;

-- end;

-- $$ language plpgsql security definer;


-- -- التأكد من إن التريجر شغال

-- drop trigger if exists on_auth_user_created on auth.users;

-- create trigger on_auth_user_created

--   after insert on auth.users

--   for each row execute procedure public.handle_new_user();








-- 1. التأكد من وجود القيم الافتراضية في الجدول

ALTER TABLE public.profiles

ALTER COLUMN created_at SET DEFAULT now(),

ALTER COLUMN updated_at SET DEFAULT now();


-- 2. تحديث دالة الـ Trigger لتكون أكثر أماناً

CREATE OR REPLACE FUNCTION public.handle_new_user()

RETURNS trigger AS $$

BEGIN

  INSERT INTO public.profiles (id, email, name, avatar_url, created_at, updated_at)

  VALUES (

    new.id,

    new.email,

    COALESCE(new.raw_user_meta_data->>'name', new.raw_user_meta_data->>'full_name', new.email),

    COALESCE(new.raw_user_meta_data->>'avatar_url', new.raw_user_meta_data->>'picture'),

    now(),

    now()

  )

  ON CONFLICT (id) DO NOTHING; -- لمنع خطأ الـ Duplicate لو السجل موجود

  RETURN new;

END;

$$ LANGUAGE plpgsql SECURITY DEFINER;-- -- -- -- -- -- ==========================================

-- -- -- -- -- -- 1. تنظيف شامل (Fresh Start) 🧹

-- -- -- -- -- -- ==========================================

-- -- -- -- -- -- حذف الدوال القديمة لتجنب التعارض

-- -- -- -- -- DROP FUNCTION IF EXISTS get_chart_history(TEXT, TIMESTAMPTZ, INT);

-- -- -- -- -- DROP FUNCTION IF EXISTS get_gold_chart_data(INT);

-- -- -- -- -- DROP FUNCTION IF EXISTS get_gold_chart_data(INT, VARCHAR);

-- -- -- -- -- DROP FUNCTION IF EXISTS get_chart_data(TEXT, INT);



-- -- -- -- -- -- حذف الجداول

-- -- -- -- -- DROP TABLE IF EXISTS stock_messages CASCADE;

-- -- -- -- -- DROP TABLE IF EXISTS stock_news CASCADE;

-- -- -- -- -- DROP TABLE IF EXISTS gold_candles CASCADE;

-- -- -- -- -- DROP TABLE IF EXISTS gold_prices CASCADE;


-- -- -- -- -- -- حذف جداول الشموع للشركات (لاحظ tmgh_candles)

-- -- -- -- -- DROP TABLE IF EXISTS

-- -- -- -- --     tmgh_candles, comi_candles, fwry_candles, abuk_candles,

-- -- -- -- --     east_candles, efih_candles, emfd_candles, etel_candles,

-- -- -- -- --     expa_candles, hrho_candles, iron_candles, oras_candles, swdy_candles CASCADE;


-- -- -- -- -- DROP TABLE IF EXISTS stocks CASCADE;


-- -- -- -- -- -- ==========================================

-- -- -- -- -- -- 2. جدول الأسهم الرئيسي (Master Table) 🏗️

-- -- -- -- -- -- ==========================================

-- -- -- -- -- CREATE TABLE stocks (

-- -- -- -- --     id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

-- -- -- -- --     symbol VARCHAR(10) UNIQUE NOT NULL,

-- -- -- -- --     company_name_en VARCHAR(255) NOT NULL,

-- -- -- -- --     company_name_ar VARCHAR(255),

-- -- -- -- --     sector VARCHAR(100),

-- -- -- -- --     description TEXT,

-- -- -- -- --     total_shares BIGINT,

-- -- -- -- --     prev_close FLOAT4 DEFAULT 0.0,

-- -- -- -- --     isin_code VARCHAR(50),

-- -- -- -- --     logo_url TEXT,

-- -- -- -- --     listing_date DATE,

-- -- -- -- --     website VARCHAR(255),

-- -- -- -- --     candle_table_name VARCHAR(50) NOT NULL,

-- -- -- -- --     created_at TIMESTAMPTZ DEFAULT now()

-- -- -- -- -- );


-- -- -- -- -- -- ==========================================

-- -- -- -- -- -- 3. جداول الشموع (Stock Candles) 🕯️

-- -- -- -- -- -- ==========================================

-- -- -- -- -- -- تم توحيد اسم جدول طلعت مصطفى إلى tmgh_candles


-- -- -- -- -- CREATE TABLE tmgh_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));

-- -- -- -- -- CREATE TABLE comi_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));

-- -- -- -- -- CREATE TABLE fwry_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));

-- -- -- -- -- CREATE TABLE abuk_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));

-- -- -- -- -- CREATE TABLE east_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));

-- -- -- -- -- CREATE TABLE efih_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));

-- -- -- -- -- CREATE TABLE emfd_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));

-- -- -- -- -- CREATE TABLE etel_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));

-- -- -- -- -- CREATE TABLE expa_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));

-- -- -- -- -- CREATE TABLE hrho_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));

-- -- -- -- -- CREATE TABLE iron_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));

-- -- -- -- -- CREATE TABLE oras_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));

-- -- -- -- -- CREATE TABLE swdy_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));


-- -- -- -- -- -- ==========================================

-- -- -- -- -- -- 4. جداول الذهب (Gold Tables) 🏆

-- -- -- -- -- -- ==========================================

-- -- -- -- -- CREATE TABLE gold_candles (

-- -- -- -- --     timestamp TIMESTAMPTZ NOT NULL,

-- -- -- -- --     open NUMERIC(12,2) NOT NULL,

-- -- -- -- --     high NUMERIC(12,2) NOT NULL,

-- -- -- -- --     low NUMERIC(12,2) NOT NULL,

-- -- -- -- --     close NUMERIC(12,2) NOT NULL,

-- -- -- -- --     gold_usd NUMERIC(12,2) NOT NULL,

-- -- -- -- --     usd_egp NUMERIC(12,4) NOT NULL,

-- -- -- -- --     timeframe VARCHAR(5) NOT NULL DEFAULT '1d',

-- -- -- -- --     created_at TIMESTAMPTZ DEFAULT now(),

-- -- -- -- --     PRIMARY KEY (timestamp, timeframe)

-- -- -- -- -- );


-- -- -- -- -- CREATE TABLE gold_prices (

-- -- -- -- --     id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

-- -- -- -- --     timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),

-- -- -- -- --     price_24k NUMERIC(10, 2),

-- -- -- -- --     price_21k NUMERIC(10, 2),

-- -- -- -- --     price_18k NUMERIC(10, 2)

-- -- -- -- -- );


-- -- -- -- -- -- ==========================================

-- -- -- -- -- -- 5. جداول التواصل والأخبار (Social) 💬

-- -- -- -- -- -- ==========================================

-- -- -- -- -- CREATE TABLE stock_news (

-- -- -- -- --     id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

-- -- -- -- --     stock_id BIGINT REFERENCES stocks(id) ON DELETE CASCADE,

-- -- -- -- --     title TEXT NOT NULL,

-- -- -- -- --     description TEXT,

-- -- -- -- --     content TEXT,

-- -- -- -- --     url TEXT UNIQUE,

-- -- -- -- --     source VARCHAR(100),

-- -- -- -- --     published_at TIMESTAMPTZ,

-- -- -- -- --     created_at TIMESTAMPTZ DEFAULT now()

-- -- -- -- -- );


-- -- -- -- -- CREATE TABLE stock_messages (

-- -- -- -- --     id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

-- -- -- -- --     stock_id BIGINT REFERENCES stocks(id) ON DELETE CASCADE,

-- -- -- -- --     user_id UUID DEFAULT auth.uid(),

-- -- -- -- --     username VARCHAR(100),

-- -- -- -- --     content TEXT NOT NULL,

-- -- -- -- --     created_at TIMESTAMPTZ DEFAULT now()

-- -- -- -- -- );


-- -- -- -- -- -- ==========================================

-- -- -- -- -- -- 6. إدخال بيانات الشركات (Data Insert) 📥

-- -- -- -- -- -- ==========================================

-- -- -- -- -- -- تم التأكد من اسم الجدول tmgh_candles

-- -- -- -- -- INSERT INTO stocks (symbol, company_name_en, company_name_ar, sector, candle_table_name, isin_code, logo_url, listing_date, website, total_shares, description) VALUES

-- -- -- -- -- (

-- -- -- -- --     'TMGH', 'Talaat Moustafa Group', 'مجموعة طلعت مصطفى', 'Real Estate', 'tmgh_candles', 'EGS65001C013',

-- -- -- -- --     'https://drive.google.com/uc?export=view&id=1uUYqPlcZK4wmb-CO62mS-sYwYYNWmBoU',

-- -- -- -- --     '2007-11-01', 'https://www.tmg.com.eg', 2063562286,

-- -- -- -- --     'Talaat Moustafa Group Holding is one of the largest real estate developers in Egypt.'

-- -- -- -- -- ),

-- -- -- -- -- (

-- -- -- -- --     'COMI', 'Commercial International Bank', 'البنك التجاري الدولي', 'Banks', 'comi_candles', 'EGS60121C018',

-- -- -- -- --     'https://drive.google.com/uc?export=view&id=1yidPsldOPlXn6TRRX-bWJfFTliAXaK5Z',

-- -- -- -- --     '1995-01-02', 'https://www.cibeg.com', 3019080000,

-- -- -- -- --     'Commercial International Bank (CIB) is the leading private sector bank in Egypt.'

-- -- -- -- -- ),

-- -- -- -- -- (

-- -- -- -- --     'FWRY', 'Fawry', 'فوري لتكنولوجيا البنوك', 'Technology', 'fwry_candles', 'EGS745L1C014',

-- -- -- -- --     'https://drive.google.com/uc?export=view&id=1vmLYAgQ7uLJvJDKhje3Jj83b9mmXjgK9',

-- -- -- -- --     '2019-08-08', 'https://fawry.com', 1709625000,

-- -- -- -- --     'Fawry is the leading digital transformation and e-payments platform in Egypt.'

-- -- -- -- -- ),

-- -- -- -- -- (

-- -- -- -- --     'ABUK', 'Abu Qir Fertilizers', 'أبوقير للأسمدة', 'Basic Resources', 'abuk_candles', 'EGS38191C010',

-- -- -- -- --     'https://drive.google.com/uc?export=view&id=11aUTCcmxssUxs56faoeHGg8EZVLzFkCu',

-- -- -- -- --     '1994-09-27', 'https://abuqir.com', 1261875000,

-- -- -- -- --     'Abu Qir Fertilizers and Chemicals Industries is one of the largest producers of nitrogenous fertilizers.'

-- -- -- -- -- ),

-- -- -- -- -- (

-- -- -- -- --     'EAST', 'Eastern Company', 'ايسترن كومباني', 'Food, Beverage & Tobacco', 'east_candles', 'EGS30221C013',

-- -- -- -- --     'https://t3.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=http://easternegypt.com&size=256',

-- -- -- -- --     '1995-09-27', 'https://www.easternegypt.com', 2230000000,

-- -- -- -- --     'Eastern Company is the dominant manufacturer of tobacco products in Egypt.'

-- -- -- -- -- ),

-- -- -- -- -- (

-- -- -- -- --     'EFIH', 'e-finance', 'إي فاينانس', 'Non-bank Financial Services', 'efih_candles', 'EGS74051C018',

-- -- -- -- --     'https://drive.google.com/uc?export=view&id=1ZSuiEyPAiI5ZslIrDxkj1hTl7TlhU6r9',

-- -- -- -- --     '2021-10-20', 'https://efinanceinvestment.com', 1848888889,

-- -- -- -- --     'e-finance is a leading developer of digital payments infrastructures.'

-- -- -- -- -- ),

-- -- -- -- -- (

-- -- -- -- --     'EMFD', 'Emaar Misr', 'إعمار مصر', 'Real Estate', 'emfd_candles', 'EGS65901C018',

-- -- -- -- --     'https://drive.google.com/uc?export=view&id=1ngj6WCwdjORsJ0Nv6J7nIVytqRXz1SVC',

-- -- -- -- --     '2015-07-05', 'https://www.emaarmisr.com', 4800000000,

-- -- -- -- --     'Emaar Misr is a leading real estate developer known for its prestigious communities.'

-- -- -- -- -- ),

-- -- -- -- -- (

-- -- -- -- --     'ETEL', 'Telecom Egypt (WE)', 'المصرية للاتصالات', 'Telecommunications', 'etel_candles', 'EGS48031C016',

-- -- -- -- --     'https://drive.google.com/uc?export=view&id=1Yboxs11RmdHvN1bOCBUE_IVbegWsqtV4',

-- -- -- -- --     '2005-12-14', 'https://www.te.eg', 1707071600,

-- -- -- -- --     'Telecom Egypt is the primary telephone company in Egypt (WE).'

-- -- -- -- -- ),

-- -- -- -- -- (

-- -- -- -- --     'EXPA', 'EBank', 'البنك المصري لتنمية الصادرات', 'Banks', 'expa_candles', 'EGS60281C019',

-- -- -- -- --     'https://drive.google.com/uc?export=view&id=1z5QABqMt19GP2LUBftW7WissKJa40cUt',

-- -- -- -- --     '1984-02-01', 'https://ebank.com.eg', 527360000,

-- -- -- -- --     'EBank (Export Development Bank of Egypt) supports exporters.'

-- -- -- -- -- ),

-- -- -- -- -- (

-- -- -- -- --     'HRHO', 'EFG Holding', 'مجموعة إي إف جي القابضة', 'Non-bank Financial Services', 'hrho_candles', 'EGS69161C011',

-- -- -- -- --     'https://drive.google.com/uc?export=view&id=1VYhM7DyJfN5nQIqLyl4Og4hU3wwbOr0h',

-- -- -- -- --     '1999-02-17', 'https://www.efgholding.com', 1458537000,

-- -- -- -- --     'EFG Holding is a leading financial services corporation.'

-- -- -- -- -- ),

-- -- -- -- -- (

-- -- -- -- --     'IRON', 'Ezz Steel', 'حديد عز', 'Basic Resources', 'iron_candles', 'EGS3A221C013',

-- -- -- -- --     'https://drive.google.com/uc?export=view&id=1eCPaTzcY2c_RQktqtT2rp8ICQ1y4mE8t',

-- -- -- -- --     '1999-05-23', 'https://www.ezzsteel.com', 543265000,

-- -- -- -- --     'Ezz Steel is the largest independent steel producer in the Middle East.'

-- -- -- -- -- ),

-- -- -- -- -- (

-- -- -- -- --     'ORAS', 'Orascom Construction', 'أوراسكوم كونستراكشون', 'Construction & Materials', 'oras_candles', 'EGS95001C011',

-- -- -- -- --     'https://drive.google.com/uc?export=view&id=1eCPaTzcY2c_RQktqtT2rp8ICQ1y4mE8t',

-- -- -- -- --     '2015-03-11', 'https://www.orascom.com', 116761379,

-- -- -- -- --     'Orascom Construction is a leading global engineering and construction contractor.'

-- -- -- -- -- ),

-- -- -- -- -- (

-- -- -- -- --     'SWDY', 'Elsewedy Electric', 'السويدي إليكتريك', 'Industrial Goods', 'swdy_candles', 'EGS3G0Z1C014',

-- -- -- -- --     'https://drive.google.com/uc?export=view&id=1Rgb46jgX3l9pAt3VB-kFi3-zIdoumwxZ',

-- -- -- -- --     '2006-05-24', 'https://www.elsewedyelectric.com', 2184180000,

-- -- -- -- --     'Elsewedy Electric is a global leader in integrated energy solutions.'

-- -- -- -- -- );


-- -- -- -- -- INSERT INTO stocks (

-- -- -- -- --     symbol, company_name_en, company_name_ar, sector, description, total_shares, prev_close, isin_code, logo_url, listing_date, website, candle_table_name

-- -- -- -- -- ) VALUES (

-- -- -- -- --     'GOLD', 'Gold Spot / Egyptian Market', 'الذهب - السوق المصري والعالمي', 'Commodities',

-- -- -- -- --     'تتبع حي لأسعار الذهب العالمية والمحلية.', 0, 0, 'XAU-EGP',

-- -- -- -- --     'https://drive.google.com/uc?export=view&id=1G3bTw96_-DN0CgMGBAQcIYRhrpioxeaV',

-- -- -- -- --     '2025-01-01', 'https://goldprice.org', 'gold_candles'

-- -- -- -- -- );


-- -- -- -- -- -- ==========================================

-- -- -- -- -- -- 7. الدوال (Smart Functions / RPCs) 🧠

-- -- -- -- -- -- ==========================================

-- -- -- -- -- CREATE OR REPLACE FUNCTION get_chart_history(

-- -- -- -- --     target_symbol TEXT,

-- -- -- -- --     before_date TIMESTAMPTZ DEFAULT NULL,

-- -- -- -- --     limit_count INT DEFAULT 100

-- -- -- -- -- )

-- -- -- -- -- RETURNS TABLE (

-- -- -- -- --     candle_time TIMESTAMPTZ,

-- -- -- -- --     open FLOAT4,

-- -- -- -- --     high FLOAT4,

-- -- -- -- --     low FLOAT4,

-- -- -- -- --     close FLOAT4,

-- -- -- -- --     volume BIGINT,

-- -- -- -- --     res VARCHAR(5)

-- -- -- -- -- ) LANGUAGE plpgsql AS $$

-- -- -- -- -- DECLARE

-- -- -- -- --     target_table TEXT;

-- -- -- -- --     query_date TIMESTAMPTZ;

-- -- -- -- -- BEGIN

-- -- -- -- --     SELECT candle_table_name INTO target_table

-- -- -- -- --     FROM stocks

-- -- -- -- --     WHERE symbol = target_symbol;


-- -- -- -- --     IF target_table IS NULL THEN

-- -- -- -- --         RETURN;

-- -- -- -- --     END IF;


-- -- -- -- --     IF before_date IS NULL THEN

-- -- -- -- --         query_date := NOW() + INTERVAL '100 years';

-- -- -- -- --     ELSE

-- -- -- -- --         query_date := before_date;

-- -- -- -- --     END IF;


-- -- -- -- --     RETURN QUERY EXECUTE format('

-- -- -- -- --         WITH latest_data AS (

-- -- -- -- --             SELECT timestamp, open, high, low, close, volume, timeframe

-- -- -- -- --             FROM %I

-- -- -- -- --             WHERE timestamp < %L

-- -- -- -- --             ORDER BY timestamp DESC

-- -- -- -- --             LIMIT %s

-- -- -- -- --         )

-- -- -- -- --         SELECT timestamp AS candle_time, open, high, low, close, volume, timeframe AS res

-- -- -- -- --         FROM latest_data

-- -- -- -- --         ORDER BY timestamp ASC;

-- -- -- -- --     ', target_table, query_date, limit_count);

-- -- -- -- -- END;

-- -- -- -- -- $$;


-- -- -- -- -- CREATE OR REPLACE FUNCTION get_gold_chart_data(

-- -- -- -- --     days_limit INT DEFAULT 1,

-- -- -- -- --     res_filter VARCHAR DEFAULT '1d'

-- -- -- -- -- )

-- -- -- -- -- RETURNS TABLE (

-- -- -- -- --     candle_time TIMESTAMPTZ,

-- -- -- -- --     open NUMERIC,

-- -- -- -- --     high NUMERIC,

-- -- -- -- --     low NUMERIC,

-- -- -- -- --     close NUMERIC,

-- -- -- -- --     vol NUMERIC

-- -- -- -- -- ) LANGUAGE plpgsql AS $$

-- -- -- -- -- BEGIN

-- -- -- -- --     RETURN QUERY

-- -- -- -- --     SELECT

-- -- -- -- --         timestamp AS candle_time,

-- -- -- -- --         open, high, low, close,

-- -- -- -- --         0::numeric AS vol

-- -- -- -- --     FROM gold_candles

-- -- -- -- --     WHERE timestamp >= NOW() - (days_limit || ' days')::INTERVAL

-- -- -- -- --     AND timeframe = res_filter

-- -- -- -- --     ORDER BY timestamp ASC;

-- -- -- -- -- END;

-- -- -- -- -- $$;


-- -- -- -- -- -- ==========================================

-- -- -- -- -- -- 8. تفعيل الأمان (RLS Security) 🔒

-- -- -- -- -- -- ==========================================

-- -- -- -- -- ALTER TABLE stocks ENABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE stock_news ENABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE stock_messages ENABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE gold_prices ENABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE gold_candles ENABLE ROW LEVEL SECURITY;


-- -- -- -- -- ALTER TABLE tmgh_candles ENABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE comi_candles ENABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE fwry_candles ENABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE abuk_candles ENABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE east_candles ENABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE efih_candles ENABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE emfd_candles ENABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE etel_candles ENABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE expa_candles ENABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE hrho_candles ENABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE iron_candles ENABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE oras_candles ENABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE swdy_candles ENABLE ROW LEVEL SECURITY;


-- -- -- -- -- CREATE POLICY "Public Read Stocks" ON stocks FOR SELECT USING (true);

-- -- -- -- -- CREATE POLICY "Public Read News" ON stock_news FOR SELECT USING (true);

-- -- -- -- -- CREATE POLICY "Public Read Messages" ON stock_messages FOR SELECT USING (true);

-- -- -- -- -- CREATE POLICY "Public Read Gold" ON gold_prices FOR SELECT USING (true);

-- -- -- -- -- CREATE POLICY "Public Read Gold Candles" ON gold_candles FOR SELECT USING (true);


-- -- -- -- -- CREATE POLICY "Public Read TMGH" ON tmgh_candles FOR SELECT USING (true);

-- -- -- -- -- CREATE POLICY "Public Read COMI" ON comi_candles FOR SELECT USING (true);

-- -- -- -- -- CREATE POLICY "Public Read FWRY" ON fwry_candles FOR SELECT USING (true);

-- -- -- -- -- CREATE POLICY "Public Read ABUK" ON abuk_candles FOR SELECT USING (true);

-- -- -- -- -- CREATE POLICY "Public Read EAST" ON east_candles FOR SELECT USING (true);

-- -- -- -- -- CREATE POLICY "Public Read EFIH" ON efih_candles FOR SELECT USING (true);

-- -- -- -- -- CREATE POLICY "Public Read EMFD" ON emfd_candles FOR SELECT USING (true);

-- -- -- -- -- CREATE POLICY "Public Read ETEL" ON etel_candles FOR SELECT USING (true);

-- -- -- -- -- CREATE POLICY "Public Read EXPA" ON expa_candles FOR SELECT USING (true);

-- -- -- -- -- CREATE POLICY "Public Read HRHO" ON hrho_candles FOR SELECT USING (true);

-- -- -- -- -- CREATE POLICY "Public Read IRON" ON iron_candles FOR SELECT USING (true);

-- -- -- -- -- CREATE POLICY "Public Read ORAS" ON oras_candles FOR SELECT USING (true);

-- -- -- -- -- CREATE POLICY "Public Read SWDY" ON swdy_candles FOR SELECT USING (true);


-- -- -- -- -- CREATE POLICY "Auth Insert Messages" ON stock_messages FOR INSERT TO authenticated WITH CHECK (true);


-- -- -- -- -- -- ==========================================

-- -- -- -- -- -- 9. تعطيل RLS للرفع (مؤقت) 🔓

-- -- -- -- -- -- ==========================================

-- -- -- -- -- -- هذا الجزء ضروري عشان كود البايثون يقدر يرفع من غير مفتاح Service Role لو لسه مستخدم Anon

-- -- -- -- -- -- (الأفضل تستخدم Service Role Key في بايثون وتسيب السطور دي ممسوحة، بس هسيبها لك للأمان)

-- -- -- -- -- ALTER TABLE tmgh_candles DISABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE comi_candles DISABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE fwry_candles DISABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE abuk_candles DISABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE east_candles DISABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE efih_candles DISABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE emfd_candles DISABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE etel_candles DISABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE expa_candles DISABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE hrho_candles DISABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE iron_candles DISABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE oras_candles DISABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE swdy_candles DISABLE ROW LEVEL SECURITY;

-- -- -- -- -- ALTER TABLE gold_candles DISABLE ROW LEVEL SECURITY;


-- -- -- -- -- -- تعطيل الحماية عن جدول الأخبار عشان السكربت يقدر يكتب فيه

-- -- -- -- -- ALTER TABLE stock_news DISABLE ROW LEVEL SECURITY;


-- -- -- -- -- ALTER TABLE gold_prices DISABLE ROW LEVEL SECURITY;

-- -- -- -- ALTER TABLE stocks DISABLE ROW LEVEL SECURITY;


-- -- -- -- 1. حذف الكريبتو القديم لتجنب التكرار

-- -- -- DELETE FROM stocks WHERE sector = 'Crypto';


-- -- -- -- 2. إضافة الـ 10 عملات بالوصف الإنجليزي المفصل

-- -- -- INSERT INTO stocks (

-- -- --     symbol, company_name_en, company_name_ar, sector, candle_table_name,

-- -- --     logo_url, website, description,

-- -- --     listing_date, total_shares, isin_code

-- -- -- ) VALUES

-- -- -- (

-- -- --     'BTC', 'Bitcoin', 'بيتكوين', 'Crypto', 'API',

-- -- --     'https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Bitcoin.svg/1200px-Bitcoin.svg.png',

-- -- --     'https://bitcoin.org',

-- -- --     'Bitcoin is the first decentralized cryptocurrency, often referred to as "digital gold". It operates on a peer-to-peer network without any central authority, serving as a global store of value and a hedge against inflation.',

-- -- --     '2009-01-03', 21000000, 'CRYPTO-BTC'

-- -- -- ),

-- -- -- (

-- -- --     'ETH', 'Ethereum', 'إيثيريوم', 'Crypto', 'API',

-- -- --     'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Ethereum-icon-purple.svg/1200px-Ethereum-icon-purple.svg.png',

-- -- --     'https://ethereum.org',

-- -- --     'Ethereum is the leading programmable blockchain platform. It enables developers to build decentralized applications (dApps) and smart contracts, serving as the foundation for Decentralized Finance (DeFi) and NFTs.',

-- -- --     '2015-07-30', 120000000, 'CRYPTO-ETH'

-- -- -- ),

-- -- -- (

-- -- --     'SOL', 'Solana', 'سولانا', 'Crypto', 'API',

-- -- --     'https://cryptologos.cc/logos/solana-sol-logo.png',

-- -- --     'https://solana.com',

-- -- --     'Solana is a high-performance blockchain supporting builders around the world to create crypto apps that scale today. It is known for its incredibly fast transaction speeds and extremely low fees compared to Ethereum.',

-- -- --     '2020-03-16', 570000000, 'CRYPTO-SOL'

-- -- -- ),

-- -- -- (

-- -- --     'XRP', 'Ripple', 'ريبل', 'Crypto', 'API',

-- -- --     'https://cryptologos.cc/logos/xrp-xrp-logo.png',

-- -- --     'https://ripple.com',

-- -- --     'XRP is a digital asset built for global payments. It offers financial institutions a fast, reliable, and cost-effective option for cross-border transactions, bridging the gap between traditional finance and crypto.',

-- -- --     '2012-06-02', 100000000000, 'CRYPTO-XRP'

-- -- -- ),

-- -- -- (

-- -- --     'DOGE', 'Dogecoin', 'دوج كوين', 'Crypto', 'API',

-- -- --     'https://cryptologos.cc/logos/dogecoin-doge-logo.png',

-- -- --     'https://dogecoin.com',

-- -- --     'Dogecoin is an open-source peer-to-peer digital currency. Originally created as a meme, it has evolved into a popular cryptocurrency used for micro-transactions, tipping, and supported by a vibrant community.',

-- -- --     '2013-12-06', 140000000000, 'CRYPTO-DOGE'

-- -- -- ),

-- -- -- (

-- -- --     'BNB', 'Binance Coin', 'باينانس كوين', 'Crypto', 'API',

-- -- --     'https://cryptologos.cc/logos/bnb-bnb-logo.png',

-- -- --     'https://www.binance.com',

-- -- --     'BNB is the native utility token of the Binance ecosystem. It powers the Binance Smart Chain and is used to pay for transaction fees on the Binance exchange and various decentralized applications.',

-- -- --     '2017-07-08', 145000000, 'CRYPTO-BNB'

-- -- -- ),

-- -- -- (

-- -- --     'ADA', 'Cardano', 'كاردانو', 'Crypto', 'API',

-- -- --     'https://cryptologos.cc/logos/cardano-ada-logo.png',

-- -- --     'https://cardano.org',

-- -- --     'Cardano is a proof-of-stake blockchain platform: the first to be founded on peer-reviewed research and developed through evidence-based methods. It aims to provide a more secure and scalable infrastructure.',

-- -- --     '2017-09-23', 45000000000, 'CRYPTO-ADA'

-- -- -- ),

-- -- -- (

-- -- --     'AVAX', 'Avalanche', 'أفالانش', 'Crypto', 'API',

-- -- --     'https://cryptologos.cc/logos/avalanche-avax-logo.png',

-- -- --     'https://www.avax.network',

-- -- --     'Avalanche is a future-proof blockchain built to scale. It is an open, programmable smart contracts platform for decentralized applications, offering near-instant transaction finality.',

-- -- --     '2020-09-21', 720000000, 'CRYPTO-AVAX'

-- -- -- ),

-- -- -- (

-- -- --     'DOT', 'Polkadot', 'بولكادوت', 'Crypto', 'API',

-- -- --     'https://cryptologos.cc/logos/polkadot-new-dot-logo.png',

-- -- --     'https://polkadot.network',

-- -- --     'Polkadot is a multichain protocol that connects and secures a network of specialized blockchains, facilitating the cross-chain transfer of any data or asset types, not just tokens.',

-- -- --     '2020-05-26', 1300000000, 'CRYPTO-DOT'

-- -- -- ),

-- -- -- (

-- -- --     'LINK', 'Chainlink', 'تشين لينك', 'Crypto', 'API',

-- -- --     'https://cryptologos.cc/logos/chainlink-link-logo.png',

-- -- --     'https://chain.link',

-- -- --     'Chainlink is a decentralized oracle network. It enables smart contracts on any blockchain to securely connect to real-world data, events, and payments, expanding the capabilities of blockchain technology.',

-- -- --     '2017-09-19', 1000000000, 'CRYPTO-LINK'

-- -- -- );



-- -- -- -- إضافة البيانات الكاملة والحقيقية للمؤشرات المصرية (EGX30 & EGX70) مع روابط الصور الجديدة

-- -- -- INSERT INTO stocks (

-- -- --     symbol,

-- -- --     company_name_en,

-- -- --     company_name_ar,

-- -- --     sector,

-- -- --     description,

-- -- --     total_shares,

-- -- --     prev_close,

-- -- --     isin_code,

-- -- --     logo_url,

-- -- --     listing_date,

-- -- --     website,

-- -- --     candle_table_name

-- -- -- ) VALUES

-- -- -- (

-- -- --     'EGX30',

-- -- --     'EGX 30 Index',

-- -- --     'مؤشر إي جي إكس 30',

-- -- --     'Indices',

-- -- --     'The main benchmark index of the Egyptian Exchange, tracking the top 30 companies by liquidity and market cap. --split-- COMI,TMGH,FWRY,ABUK,EAST,EFIH,EMFD,ETEL,EXPA,HRHO,IRON,ORAS,SWDY,EKHO,JUFO,MFOT,MNHD,OCDI,PHDC,HELI,ADIB,SKPC,ESRS,BTEL,CLHO,RMDA,MOIL,MICH,DSCW,MTIE',

-- -- --     0,

-- -- --     41102.8,

-- -- --     'INDEX-EGX30',

-- -- --     'https://drive.google.com/uc?export=view&id=1a7Ig_mpMm3MhFHy8KFdNXXdEECr3M-W9', -- رابط الصورة الأول المحدث

-- -- --     '1998-01-01',

-- -- --     'https://www.egx.com.eg',

-- -- --     'egx30_candles'

-- -- -- ),

-- -- -- (

-- -- --     'EGX70',

-- -- --     'EGX 70 EWI',

-- -- --     'مؤشر إي جي إكس 70',

-- -- --     'Indices',

-- -- --     'Tracking the performance of 70 small and medium-sized companies in the Egyptian market using equal weighting. --split-- AMOC,EGAL,NCGC,ISPH,PORT,CCAP,BINV,ACGC,AFMC,AJWA,ALCN,ALRE,AMIA,ARCC,ASPI,ATQA,BRAI,CANA,COPR,DAPH,DGTW,EDBM,EFTG,EGCH,EGSA,EITP,ELSH,ENGC,EPCO,EPHI,EQDP,ERAS,ESGI,GGCC,GTHE,GTUN,IFAP,KRDI,LCSW,MCQE,MEPA,MGED,MILS,MPRC,MTIE,NAHO,NEDA,ODIN,OLFI,PRDC,PRMH,RAYA,REAC,RKHT,SAUD,SDTI,SMPP,SPMD,UEGC,UNRE,UPMS,UTAD,VERT,WAPH,ZMID',

-- -- --     0,

-- -- --     0.0,

-- -- --     'INDEX-EGX70',

-- -- --     'https://drive.google.com/uc?export=view&id=1jlrG1Z8s9-pRT7NN9Uod61JSnIDT0jnW', -- رابط الصورة الثاني المحدث

-- -- --     '2009-03-01',

-- -- --     'https://www.egx.com.eg',

-- -- --     'egx70_candles'

-- -- -- );


-- -- -- -- 1. جدول بيانات مؤشر EGX30

-- -- -- CREATE TABLE egx30_candles (

-- -- --     timestamp TIMESTAMPTZ NOT NULL,

-- -- --     open FLOAT4,

-- -- --     high FLOAT4,

-- -- --     low FLOAT4,

-- -- --     close FLOAT4, -- هنا يتم تخزين "نقاط المؤشر" بدل السعر

-- -- --     volume BIGINT,

-- -- --     timeframe VARCHAR(5) NOT NULL,

-- -- --     created_at TIMESTAMPTZ DEFAULT now(),

-- -- --     PRIMARY KEY (timestamp, timeframe)

-- -- -- );


-- -- -- -- 2. جدول بيانات مؤشر EGX70

-- -- -- CREATE TABLE egx70_candles (

-- -- --     timestamp TIMESTAMPTZ NOT NULL,

-- -- --     open FLOAT4,

-- -- --     high FLOAT4,

-- -- --     low FLOAT4,

-- -- --     close FLOAT4,

-- -- --     volume BIGINT,

-- -- --     timeframe VARCHAR(5) NOT NULL,

-- -- --     created_at TIMESTAMPTZ DEFAULT now(),

-- -- --     PRIMARY KEY (timestamp, timeframe)

-- -- -- );


-- -- -- ALTER TABLE egx30_candles DISABLE ROW LEVEL SECURITY;

-- -- -- ALTER TABLE egx70_candles DISABLE ROW LEVEL SECURITY;

-- -- -- تغيير اسم الجدول من القديم للجديد

-- -- -- ALTER TABLE egx70_candles RENAME TO egx70ewi_candles;


-- -- -- إضافة الأعمدة الجديدة لجدول stocks



-- -- -- 1. مسح الدوال القديمة لضمان نظافة التحديث

-- -- DROP FUNCTION IF EXISTS get_stocks_with_sparklines(integer);

-- -- DROP FUNCTION IF EXISTS get_indices_with_sparklines();

-- -- DROP FUNCTION IF EXISTS get_watchlist_with_sparklines(UUID);

-- -- -- 1. دالة جلب الأسهم (Trending) مع الحساب اللحظي

-- -- CREATE OR REPLACE FUNCTION get_stocks_with_sparklines(row_limit INT)

-- -- RETURNS JSONB LANGUAGE plpgsql AS $$

-- -- DECLARE

-- --     stock_record RECORD;

-- --     final_json JSONB := '[]'::JSONB;

-- --     latest_price FLOAT4;

-- --     calc_change FLOAT4;

-- --     spark_data JSONB;

-- -- BEGIN

-- --     FOR stock_record IN (

-- --         SELECT * FROM stocks WHERE sector != 'Indices' AND candle_table_name != 'API' LIMIT row_limit

-- --     )

-- --     LOOP

-- --         IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = stock_record.candle_table_name) THEN

-- --             -- جلب آخر سعر من جدول الشموع

-- --             EXECUTE format('SELECT close FROM %I ORDER BY timestamp DESC LIMIT 1', stock_record.candle_table_name) INTO latest_price;



-- --             -- جلب بيانات الشارت

-- --             EXECUTE format('SELECT json_agg(c) FROM (SELECT close FROM %I ORDER BY timestamp DESC LIMIT 20) sub(c)', stock_record.candle_table_name) INTO spark_data;


-- --             -- الحسبة اللحظية

-- --             calc_change := CASE WHEN stock_record.prev_close > 0

-- --                            THEN ((latest_price - stock_record.prev_close) / stock_record.prev_close) * 100

-- --                            ELSE 0 END;


-- --             final_json := final_json || jsonb_build_object(

-- --                 'id', stock_record.id, 'symbol', stock_record.symbol,

-- --                 'company_name_en', stock_record.company_name_en,

-- --                 'current_price', latest_price,

-- --                 'change_percent', ROUND(calc_change::numeric, 2),

-- --                 'logo_url', stock_record.logo_url,

-- --                 'sparkline_data', COALESCE(spark_data, '[]'::JSONB)

-- --             );

-- --         END IF;

-- --     END LOOP;

-- --     RETURN final_json;

-- -- END;

-- -- $$;


-- -- -- 2. دالة جلب المؤشرات (Market Overview) بنفس المنطق

-- -- CREATE OR REPLACE FUNCTION get_indices_with_sparklines()

-- -- RETURNS JSONB LANGUAGE plpgsql AS $$

-- -- DECLARE

-- --     index_record RECORD;

-- --     final_json JSONB := '[]'::JSONB;

-- --     latest_price FLOAT4;

-- --     calc_change FLOAT4;

-- --     spark_data JSONB;

-- -- BEGIN

-- --     FOR index_record IN (SELECT * FROM stocks WHERE sector = 'Indices' LIMIT 2)

-- --     LOOP

-- --         IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = index_record.candle_table_name) THEN

-- --             EXECUTE format('SELECT close FROM %I ORDER BY timestamp DESC LIMIT 1', index_record.candle_table_name) INTO latest_price;

-- --             EXECUTE format('SELECT json_agg(c) FROM (SELECT close FROM %I ORDER BY timestamp DESC LIMIT 20) sub(c)', index_record.candle_table_name) INTO spark_data;



-- --             calc_change := CASE WHEN index_record.prev_close > 0

-- --                            THEN ((latest_price - index_record.prev_close) / index_record.prev_close) * 100

-- --                            ELSE 0 END;


-- --             final_json := final_json || jsonb_build_object(

-- --                 'id', index_record.id, 'symbol', index_record.symbol,

-- --                 'current_price', latest_price,

-- --                 'change_percent', ROUND(calc_change::numeric, 2),

-- --                 'logo_url', index_record.logo_url,

-- --                 'sparkline_data', COALESCE(spark_data, '[]'::JSONB)

-- --             );

-- --         END IF;

-- --     END LOOP;

-- --     RETURN final_json;

-- -- END;

-- -- $$;


-- -- -- 3. دالة جلب الـ Watchlist (تستخدم نفس الحسبة اللحظية)

-- -- CREATE OR REPLACE FUNCTION get_watchlist_with_sparklines(viewer_id UUID)

-- -- RETURNS JSONB LANGUAGE plpgsql AS $$

-- -- DECLARE

-- --     stock_record RECORD;

-- --     final_json JSONB := '[]'::JSONB;

-- --     latest_price FLOAT4;

-- --     calc_change FLOAT4;

-- --     spark_data JSONB;

-- -- BEGIN

-- --     FOR stock_record IN (

-- --         SELECT s.* FROM stocks s JOIN user_watchlist uw ON s.symbol = uw.stock_symbol WHERE uw.user_id = viewer_id

-- --     )

-- --     LOOP

-- --         IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = stock_record.candle_table_name) THEN

-- --             EXECUTE format('SELECT close FROM %I ORDER BY timestamp DESC LIMIT 1', stock_record.candle_table_name) INTO latest_price;

-- --             EXECUTE format('SELECT json_agg(c) FROM (SELECT close FROM %I ORDER BY timestamp DESC LIMIT 20) sub(c)', stock_record.candle_table_name) INTO spark_data;


-- --             calc_change := CASE WHEN stock_record.prev_close > 0

-- --                            THEN ((latest_price - stock_record.prev_close) / stock_record.prev_close) * 100

-- --                            ELSE 0 END;


-- --             final_json := final_json || jsonb_build_object(

-- --                 'id', stock_record.id, 'symbol', stock_record.symbol,

-- --                 'company_name_en', stock_record.company_name_en,

-- --                 'current_price', latest_price,

-- --                 'change_percent', ROUND(calc_change::numeric, 2),

-- --                 'logo_url', stock_record.logo_url,

-- --                 'sparkline_data', COALESCE(spark_data, '[]'::JSONB)

-- --             );

-- --         END IF;

-- --     END LOOP;

-- --     RETURN final_json;

-- -- END;

-- -- $$;



-- CREATE OR REPLACE FUNCTION get_trending_stocks(row_limit INT)

-- RETURNS JSONB LANGUAGE plpgsql AS $$

-- DECLARE

--     stock_record RECORD;

--     final_json JSONB := '[]'::JSONB;

--     latest_price FLOAT4;

--     latest_vol BIGINT;

--     avg_vol FLOAT4;

--     calc_change FLOAT4;

--     trending_score FLOAT4;

--     spark_data JSONB;

-- BEGIN

--     -- 1. جدول مؤقت لحساب الـ Scores

--     CREATE TEMP TABLE trending_results (

--         id BIGINT, symbol TEXT, name_en TEXT, price FLOAT4,

--         change_pct FLOAT4, score FLOAT4, logo TEXT, spark JSONB

--     ) ON COMMIT DROP;


--     FOR stock_record IN (SELECT * FROM stocks WHERE sector != 'Indices' AND candle_table_name != 'API')

--     LOOP

--         IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = stock_record.candle_table_name) THEN

--             -- جلب السعر الحالي وحجم التداول الأخير

--             EXECUTE format('SELECT close, volume FROM %I ORDER BY timestamp DESC LIMIT 1', stock_record.candle_table_name)

--             INTO latest_price, latest_vol;



--             -- حساب متوسط السيولة (مثلاً آخر 10 أيام) لمقارنتها بالسيولة الحالية

--             EXECUTE format('SELECT AVG(volume) FROM (SELECT volume FROM %I ORDER BY timestamp DESC LIMIT 10) sub', stock_record.candle_table_name)

--             INTO avg_vol;


--             -- جلب بيانات الشارت

--             EXECUTE format('SELECT json_agg(c) FROM (SELECT close FROM %I ORDER BY timestamp DESC LIMIT 20) sub(c)', stock_record.candle_table_name)

--             INTO spark_data;


--             -- الحسبة اللحظية للنسبة المئوية

--             calc_change := CASE WHEN stock_record.prev_close > 0

--                            THEN ((latest_price - stock_record.prev_close) / stock_record.prev_close) * 100

--                            ELSE 0 END;


--             -- 🔥 معادلة التريند الاحترافية

--             -- بنعطي وزن 70% لطفرة السيولة و 30% لقوة حركة السعر

--             trending_score := (COALESCE(latest_vol / NULLIF(avg_vol, 0), 1) * 0.7) + (ABS(calc_change) * 0.3);


--             INSERT INTO trending_results VALUES (

--                 stock_record.id, stock_record.symbol, stock_record.company_name_en,

--                 latest_price, ROUND(calc_change::numeric, 2), trending_score,

--                 stock_record.logo_url, COALESCE(spark_data, '[]'::JSONB)

--             );

--         END IF;

--     END LOOP;


--     -- 2. تحويل النتائج لـ JSON مرتبة حسب الـ Score تنازلياً

--     SELECT jsonb_agg(to_jsonb(t) - 'score') INTO final_json

--     FROM (SELECT * FROM trending_results ORDER BY score DESC LIMIT row_limit) t;


--     RETURN final_json;

-- END;

-- $$;


ALTER TABLE stock_news

ADD COLUMN sentiment_label VARCHAR(50);-- -- -- -- -- -- -- -- UPDATE egx30_candles SET timeframe = '1d' WHERE timeframe = '1D';


-- -- -- -- -- -- -- -- -- تحديث جدول EGX70

-- -- -- -- -- -- -- -- UPDATE egx70_candles SET timeframe = '1d' WHERE timeframe = '1D';


-- -- -- -- -- -- -- SELECT

-- -- -- -- -- -- --     MIN(timestamp) AS first_daily_candle,

-- -- -- -- -- -- --     MAX(timestamp) AS last_daily_candle,

-- -- -- -- -- -- --     COUNT(*) AS total_daily_candles

-- -- -- -- -- -- -- FROM fwry_candles

-- -- -- -- -- -- -- WHERE timeframe = '1d';


-- -- -- -- -- -- -- ALTER TABLE public.gold_candles

-- -- -- -- -- -- -- ADD COLUMN volume BIGINT;  -- أو INTEGER حسب الداتا


-- -- -- -- -- -- -- ALTER TABLE public.gold_candles

-- -- -- -- -- -- -- ADD COLUMN res TEXT;


-- -- -- -- -- -- -- DROP TABLE IF EXISTS gold_candles CASCADE;


-- -- -- -- -- -- -- CREATE TABLE gold_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));

-- -- -- -- -- -- --

-- -- -- -- -- -- CREATE TABLE silver_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));



-- -- -- -- -- ALTER TABLE IF EXISTS gold_prices RENAME TO material_prices;


-- -- -- -- -- INSERT INTO stocks (

-- -- -- -- --     symbol, company_name_en, company_name_ar, sector,

-- -- -- -- --     description, candle_table_name, isin_code,

-- -- -- -- --     logo_url, listing_date, website

-- -- -- -- -- ) VALUES (

-- -- -- -- --     'SILVER',

-- -- -- -- --     'Silver Local/Global',

-- -- -- -- --     'الفضة - محلي وعالمي',

-- -- -- -- --     'Materials',

-- -- -- -- --     'تتبع أسعار الفضة عيار 999 و 800 في السوق المصري مع السعر العالمي.',

-- -- -- -- --     'silver_candles',

-- -- -- -- --     'XAG-EGP',

-- -- -- -- --     'https://drive.google.com/uc?export=view&id=1Lz-f_E_tUjP4o7S0Y3qG7Q-U3X6jVvGz',

-- -- -- -- --     now(),

-- -- -- -- --     'https://goldprice.org'

-- -- -- -- -- )

-- -- -- -- -- ON CONFLICT (symbol) DO UPDATE

-- -- -- -- -- SET sector = 'Materials';




-- -- -- -- -- UPDATE stocks

-- -- -- -- -- SET sector = 'Materials'

-- -- -- -- -- WHERE symbol = 'GOLD';


-- -- -- -- SELECT MAX(timestamp) AS last_update

-- -- -- -- FROM abuk_candles where timeframe ='1d' ;


-- -- -- ALTER TABLE public.notifications

-- -- -- ADD COLUMN IF NOT EXISTS metadata jsonb DEFAULT '{}'::jsonb;



-- -- -- -- الدالة المسؤولة عن إشعار المتابعة

-- -- -- CREATE OR REPLACE FUNCTION public.handle_new_follow_notification()

-- -- -- RETURNS TRIGGER AS $$

-- -- -- DECLARE

-- -- --     sender_name text;

-- -- -- BEGIN

-- -- --     -- جلب اسم الشخص اللي عمل متابعة

-- -- --     SELECT name INTO sender_name FROM public.profiles WHERE id = new.follower_id;


-- -- --     -- إضافة الإشعار في الجدول

-- -- --     INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body, metadata)

-- -- --     VALUES (

-- -- --         new.following_id, -- الشخص اللي جاله متابعة

-- -- --         new.follower_id,   -- الشخص اللي عمل المتابعة

-- -- --         0,                 -- لا يوجد ID لمورد معين هنا، ممكن تضع 0

-- -- --         'follow',

-- -- --         'New Follower',

-- -- --         sender_name || ' started following you',

-- -- --         jsonb_build_object('follower_id', new.follower_id)

-- -- --     );



-- -- --     RETURN new;

-- -- -- END;

-- -- -- $$ LANGUAGE plpgsql SECURITY DEFINER;


-- -- -- -- ربط الدالة بالتريجر على جدول الـ follows

-- -- -- CREATE TRIGGER on_follow_created

-- -- --   AFTER INSERT ON public.follows

-- -- --   FOR EACH ROW EXECUTE PROCEDURE public.handle_new_follow_notification();





-- -- -- -- الدالة المسؤولة عن إشعار لايك التعليق

-- -- -- CREATE OR REPLACE FUNCTION public.handle_comment_like_notification()

-- -- -- RETURNS TRIGGER AS $$

-- -- -- DECLARE

-- -- --     comment_owner_id uuid;

-- -- --     sender_name text;

-- -- --     comment_snippet text;

-- -- -- BEGIN

-- -- --     -- جلب اسم الشخص اللي عمل لايك

-- -- --     SELECT name INTO sender_name FROM public.profiles WHERE id = new.user_id;

-- -- --     -- جلب صاحب التعليق وجزء من نص التعليق

-- -- --     SELECT user_id, left(content, 20) INTO comment_owner_id, comment_snippet FROM public.comments WHERE id = new.comment_id;


-- -- --     -- نرسل الإشعار فقط لو كان اللي عمل لايك مش هو صاحب التعليق

-- -- --     IF comment_owner_id != new.user_id THEN

-- -- --         INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body, metadata)

-- -- --         VALUES (

-- -- --             comment_owner_id,

-- -- --             new.user_id,

-- -- --             new.comment_id,

-- -- --             'like',

-- -- --             'Comment Liked',

-- -- --             sender_name || ' liked your comment: "' || comment_snippet || '..."',

-- -- --             jsonb_build_object('comment_id', new.comment_id)

-- -- --         );

-- -- --     END IF;

-- -- --     RETURN new;

-- -- -- END;

-- -- -- $$ LANGUAGE plpgsql SECURITY DEFINER;


-- -- -- -- ربط الدالة بالتريجر على جدول الـ comment_votes

-- -- -- CREATE TRIGGER on_comment_like

-- -- --   AFTER INSERT ON public.comment_votes

-- -- --   FOR EACH ROW EXECUTE PROCEDURE public.handle_comment_like_notification();



-- -- -- ==============================================================================

-- -- -- 1. تنظيف شامل (Cleanup) لتجنب أي تعارض

-- -- -- ==============================================================================

-- -- DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;

-- -- DROP TRIGGER IF EXISTS on_comment_created ON public.comments;

-- -- DROP TRIGGER IF EXISTS on_post_like ON public.post_votes;

-- -- DROP TRIGGER IF EXISTS on_follow_created ON public.follows;

-- -- DROP TRIGGER IF EXISTS on_comment_like ON public.comment_votes;


-- -- DROP FUNCTION IF EXISTS public.handle_new_user CASCADE;

-- -- DROP FUNCTION IF EXISTS public.handle_new_comment_notification CASCADE;

-- -- DROP FUNCTION IF EXISTS public.handle_new_like_notification CASCADE;

-- -- DROP FUNCTION IF EXISTS public.handle_new_follow_notification CASCADE;

-- -- DROP FUNCTION IF EXISTS public.handle_comment_like_notification CASCADE;


-- -- -- ==============================================================================

-- -- -- 2. تحديث هيكل الجداول (Tables Structure)

-- -- -- ==============================================================================


-- -- -- التأكد من وجود عمود الـ FCM في البروفايل

-- -- ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS fcm_token text;


-- -- -- إعادة إنشاء جدول الإشعارات بشكل متطور

-- -- CREATE TABLE IF NOT EXISTS public.notifications (

-- --     id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,

-- --     recipient_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,

-- --     sender_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,

-- --     resource_id bigint NOT NULL, -- ID البوست أو الكومنت

-- --     type text NOT NULL CHECK (type IN ('comment', 'reply', 'like', 'follow')),

-- --     title text,

-- --     body text,

-- --     metadata jsonb DEFAULT '{}'::jsonb, -- بيانات إضافية للـ Deep Linking في فلاتر

-- --     is_read boolean DEFAULT false,

-- --     created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL

-- -- );


-- -- -- تفعيل RLS لجدول الإشعارات

-- -- ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- -- CREATE POLICY "Users can view own notifications" ON public.notifications FOR SELECT USING (auth.uid() = recipient_id);

-- -- CREATE POLICY "Users can update own notifications" ON public.notifications FOR UPDATE USING (auth.uid() = recipient_id);


-- -- -- ==============================================================================

-- -- -- 3. الدوال (Functions) - المنطق البرمجي لكل إشعار

-- -- -- ==============================================================================


-- -- -- A. إنشاء البروفايل تلقائياً

-- -- CREATE OR REPLACE FUNCTION public.handle_new_user()

-- -- RETURNS TRIGGER AS $$

-- -- BEGIN

-- --   INSERT INTO public.profiles (id, email, name, avatar_url)

-- --   VALUES (

-- --     new.id,

-- --     new.email,

-- --     COALESCE(new.raw_user_meta_data->>'name', new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),

-- --     COALESCE(new.raw_user_meta_data->>'avatar_url', new.raw_user_meta_data->>'picture')

-- --   ) ON CONFLICT (id) DO NOTHING;

-- --   RETURN new;

-- -- END;

-- -- $$ LANGUAGE plpgsql SECURITY DEFINER;


-- -- -- B. إشعارات التعليقات والردود

-- -- CREATE OR REPLACE FUNCTION public.handle_new_comment_notification()

-- -- RETURNS TRIGGER AS $$

-- -- DECLARE

-- --     post_owner_id uuid;

-- --     parent_owner_id uuid;

-- --     sender_name text;

-- -- BEGIN

-- --     SELECT name INTO sender_name FROM public.profiles WHERE id = new.user_id;



-- --     -- حالة الرد على كومنت

-- --     IF new.parent_id IS NOT NULL THEN

-- --         SELECT user_id INTO parent_owner_id FROM public.comments WHERE id = new.parent_id;

-- --         IF parent_owner_id != new.user_id THEN

-- --             INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body, metadata)

-- --             VALUES (parent_owner_id, new.user_id, new.post_id, 'reply', 'New Reply', sender_name || ' replied to your comment', jsonb_build_object('post_id', new.post_id, 'comment_id', new.id));

-- --         END IF;

-- --     -- حالة التعليق على بوست

-- --     ELSE

-- --         SELECT user_id INTO post_owner_id FROM public.posts WHERE id = new.post_id;

-- --         IF post_owner_id != new.user_id THEN

-- --             INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body, metadata)

-- --             VALUES (post_owner_id, new.user_id, new.post_id, 'comment', 'New Comment', sender_name || ' commented on your post', jsonb_build_object('post_id', new.post_id));

-- --         END IF;

-- --     END IF;

-- --     RETURN new;

-- -- END;

-- -- $$ LANGUAGE plpgsql SECURITY DEFINER;


-- -- -- C. إشعارات اللايك (بوستات)

-- -- CREATE OR REPLACE FUNCTION public.handle_new_like_notification()

-- -- RETURNS TRIGGER AS $$

-- -- DECLARE

-- --     post_owner_id uuid;

-- --     sender_name text;

-- -- BEGIN

-- --     SELECT name INTO sender_name FROM public.profiles WHERE id = new.user_id;

-- --     SELECT user_id INTO post_owner_id FROM public.posts WHERE id = new.post_id;


-- --     IF post_owner_id != new.user_id THEN

-- --         INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body, metadata)

-- --         VALUES (post_owner_id, new.user_id, new.post_id, 'like', 'New Like', sender_name || ' liked your post', jsonb_build_object('post_id', new.post_id));

-- --     END IF;

-- --     RETURN new;

-- -- END;

-- -- $$ LANGUAGE plpgsql SECURITY DEFINER;


-- -- -- D. إشعارات المتابعة (Follow)

-- -- CREATE OR REPLACE FUNCTION public.handle_new_follow_notification()

-- -- RETURNS TRIGGER AS $$

-- -- DECLARE

-- --     sender_name text;

-- -- BEGIN

-- --     SELECT name INTO sender_name FROM public.profiles WHERE id = new.follower_id;


-- --     INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body, metadata)

-- --     VALUES (new.following_id, new.follower_id, 0, 'follow', 'New Follower', sender_name || ' started following you', jsonb_build_object('follower_id', new.follower_id));

-- --     RETURN new;

-- -- END;

-- -- $$ LANGUAGE plpgsql SECURITY DEFINER;


-- -- -- E. إشعارات لايك الكومنت

-- -- CREATE OR REPLACE FUNCTION public.handle_comment_like_notification()

-- -- RETURNS TRIGGER AS $$

-- -- DECLARE

-- --     comment_owner_id uuid;

-- --     sender_name text;

-- --     post_id_val bigint;

-- -- BEGIN

-- --     SELECT name INTO sender_name FROM public.profiles WHERE id = new.user_id;

-- --     SELECT user_id, post_id INTO comment_owner_id, post_id_val FROM public.comments WHERE id = new.comment_id;


-- --     IF comment_owner_id != new.user_id THEN

-- --         INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body, metadata)

-- --         VALUES (comment_owner_id, new.user_id, new.comment_id, 'like', 'Comment Liked', sender_name || ' liked your comment', jsonb_build_object('post_id', post_id_val, 'comment_id', new.comment_id));

-- --     END IF;

-- --     RETURN new;

-- -- END;

-- -- $$ LANGUAGE plpgsql SECURITY DEFINER;


-- -- -- ==============================================================================

-- -- -- 4. تفعيل التريجرز (Triggers Activation)

-- -- -- ==============================================================================


-- -- CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- -- CREATE TRIGGER on_comment_created AFTER INSERT ON public.comments FOR EACH ROW EXECUTE PROCEDURE public.handle_new_comment_notification();

-- -- CREATE TRIGGER on_post_like AFTER INSERT ON public.post_votes FOR EACH ROW EXECUTE PROCEDURE public.handle_new_like_notification();

-- -- CREATE TRIGGER on_follow_created AFTER INSERT ON public.follows FOR EACH ROW EXECUTE PROCEDURE public.handle_new_follow_notification();

-- -- CREATE TRIGGER on_comment_like AFTER INSERT ON public.comment_votes FOR EACH ROW EXECUTE PROCEDURE public.handle_comment_like_notification();


-- -- -- ==============================================================================

-- -- -- 5. الفهارس (Indexes) لسرعة استعلام الإشعارات

-- -- -- ==============================================================================

-- -- CREATE INDEX IF NOT EXISTS idx_notifications_recipient_is_read ON public.notifications (recipient_id, is_read);



-- -- ==============================================================================

-- -- Notification System Fix - Populate Metadata with post_id

-- -- ==============================================================================

-- -- This migration ensures that database triggers properly populate the metadata

-- -- field with post_id for navigation purposes in the Flutter app.


-- -- ==============================================================================

-- -- 1. Cleanup - Drop existing triggers and functions

-- -- ==============================================================================

-- DROP TRIGGER IF EXISTS on_comment_created ON public.comments;

-- DROP TRIGGER IF EXISTS on_post_like ON public.post_votes;

-- DROP TRIGGER IF EXISTS on_follow_created ON public.follows;

-- DROP TRIGGER IF EXISTS on_comment_like ON public.comment_votes;


-- DROP FUNCTION IF EXISTS public.handle_new_comment_notification CASCADE;

-- DROP FUNCTION IF EXISTS public.handle_new_like_notification CASCADE;

-- DROP FUNCTION IF EXISTS public.handle_new_follow_notification CASCADE;

-- DROP FUNCTION IF EXISTS public.handle_comment_like_notification CASCADE;


-- -- ==============================================================================

-- -- 2. Update Table Structure

-- -- ==============================================================================


-- -- Add FCM token to profiles

-- ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS fcm_token text;


-- -- Create or update notifications table

-- CREATE TABLE IF NOT EXISTS public.notifications (

--     id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,

--     recipient_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,

--     sender_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,

--     resource_id bigint NOT NULL, -- post_id or comment_id

--     type text NOT NULL CHECK (type IN ('comment', 'reply', 'like', 'follow')),

--     title text,

--     body text,

--     metadata jsonb DEFAULT '{}'::jsonb, -- CRITICAL: stores post_id for navigation

--     is_read boolean DEFAULT false,

--     created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL

-- );


-- -- Add metadata column if it doesn't exist (for existing tables)

-- ALTER TABLE public.notifications ADD COLUMN IF NOT EXISTS metadata jsonb DEFAULT '{}'::jsonb;


-- -- ==============================================================================

-- -- 3. Enable RLS and Create Policies

-- -- ==============================================================================

-- ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;


-- -- Drop existing policies to avoid conflicts

-- DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;

-- DROP POLICY IF EXISTS "Users can update own notifications" ON public.notifications;


-- -- Recreate policies

-- CREATE POLICY "Users can view own notifications"

--     ON public.notifications FOR SELECT

--     USING (auth.uid() = recipient_id);


-- CREATE POLICY "Users can update own notifications"

--     ON public.notifications FOR UPDATE

--     USING (auth.uid() = recipient_id);


-- -- ==============================================================================

-- -- 4. Trigger Functions - The Core Logic

-- -- ==============================================================================


-- -- A. Comment & Reply Notifications

-- CREATE OR REPLACE FUNCTION public.handle_new_comment_notification()

-- RETURNS TRIGGER AS $$

-- DECLARE

--     post_owner_id uuid;

--     parent_owner_id uuid;

--     sender_name text;

-- BEGIN

--     -- Get sender name

--     SELECT name INTO sender_name FROM public.profiles WHERE id = new.user_id;



--     -- Case 1: Reply to a comment

--     IF new.parent_id IS NOT NULL THEN

--         SELECT user_id INTO parent_owner_id FROM public.comments WHERE id = new.parent_id;



--         -- Don't notify yourself

--         IF parent_owner_id != new.user_id THEN

--             INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body, metadata)

--             VALUES (

--                 parent_owner_id,

--                 new.user_id,

--                 new.post_id,

--                 'reply',

--                 'New Reply',

--                 sender_name || ' replied to your comment',

--                 jsonb_build_object('post_id', new.post_id, 'comment_id', new.id)

--             );

--         END IF;



--     -- Case 2: Comment on a post

-- ELSE

--         SELECT user_id INTO post_owner_id FROM public.posts WHERE id = new.post_id;



--         -- Don't notify yourself

--         IF post_owner_id != new.user_id THEN

--             INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body, metadata)

--             VALUES (

--                 post_owner_id,

--                 new.user_id,

--                 new.post_id,

--                 'comment',

--                 'New Comment',

--                 sender_name || ' commented on your post',

--                 jsonb_build_object('post_id', new.post_id)

--             );

--         END IF;

--     END IF;



--     RETURN new;

-- END;

-- $$ LANGUAGE plpgsql SECURITY DEFINER;


-- -- B. Post Like Notifications

-- CREATE OR REPLACE FUNCTION public.handle_new_like_notification()

-- RETURNS TRIGGER AS $$

-- DECLARE

--     post_owner_id uuid;

--     sender_name text;

-- BEGIN

--     -- Only create notification for likes (vote_type = 1), not dislikes

--     IF new.vote_type = 1 THEN

--         SELECT name INTO sender_name FROM public.profiles WHERE id = new.user_id;

--         SELECT user_id INTO post_owner_id FROM public.posts WHERE id = new.post_id;


--         -- Don't notify yourself

--         IF post_owner_id != new.user_id THEN

--             INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body, metadata)

--             VALUES (

--                 post_owner_id,

--                 new.user_id,

--                 new.post_id,

--                 'like',

--                 'New Like',

--                 sender_name || ' liked your post',

--                 jsonb_build_object('post_id', new.post_id)

--             );

--         END IF;

--     END IF;



--     RETURN new;

-- END;

-- $$ LANGUAGE plpgsql SECURITY DEFINER;


-- -- C. Comment Like Notifications

-- CREATE OR REPLACE FUNCTION public.handle_comment_like_notification()

-- RETURNS TRIGGER AS $$

-- DECLARE

--     comment_owner_id uuid;

--     sender_name text;

--     post_id_val bigint;

-- BEGIN

--     -- Only create notification for likes (vote_type = 1), not dislikes

--     IF new.vote_type = 1 THEN

--         SELECT name INTO sender_name FROM public.profiles WHERE id = new.user_id;

--         SELECT user_id, post_id INTO comment_owner_id, post_id_val

--         FROM public.comments WHERE id = new.comment_id;


--         -- Don't notify yourself

--         IF comment_owner_id != new.user_id THEN

--             INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body, metadata)

--             VALUES (

--                 comment_owner_id,

--                 new.user_id,

--                 new.comment_id,

--                 'like',

--                 'Comment Liked',

--                 sender_name || ' liked your comment',

--                 jsonb_build_object('post_id', post_id_val, 'comment_id', new.comment_id)

--             );

--         END IF;

--     END IF;



--     RETURN new;

-- END;

-- $$ LANGUAGE plpgsql SECURITY DEFINER;


-- -- D. Follow Notifications

-- CREATE OR REPLACE FUNCTION public.handle_new_follow_notification()

-- RETURNS TRIGGER AS $$

-- DECLARE

--     sender_name text;

-- BEGIN

--     SELECT name INTO sender_name FROM public.profiles WHERE id = new.follower_id;


--     INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body, metadata)

--     VALUES (

--         new.following_id,

--         new.follower_id,

--         0, -- No resource_id for follows

--         'follow',

--         'New Follower',

--         sender_name || ' started following you',

--         jsonb_build_object('follower_id', new.follower_id)

--     );



--     RETURN new;

-- END;

-- $$ LANGUAGE plpgsql SECURITY DEFINER;


-- -- ==============================================================================

-- -- 5. Activate Triggers

-- -- ==============================================================================


-- CREATE TRIGGER on_comment_created

--     AFTER INSERT ON public.comments

--     FOR EACH ROW EXECUTE PROCEDURE public.handle_new_comment_notification();


-- CREATE TRIGGER on_post_like

--     AFTER INSERT ON public.post_votes

--     FOR EACH ROW EXECUTE PROCEDURE public.handle_new_like_notification();


-- CREATE TRIGGER on_comment_like

--     AFTER INSERT ON public.comment_votes

--     FOR EACH ROW EXECUTE PROCEDURE public.handle_comment_like_notification();


-- CREATE TRIGGER on_follow_created

--     AFTER INSERT ON public.follows

--     FOR EACH ROW EXECUTE PROCEDURE public.handle_new_follow_notification();


-- -- ==============================================================================

-- -- 6. Performance Indexes

-- -- ==============================================================================

-- CREATE INDEX IF NOT EXISTS idx_notifications_recipient_is_read

--     ON public.notifications (recipient_id, is_read);


-- CREATE INDEX IF NOT EXISTS idx_notifications_created_at

--     ON public.notifications (created_at DESC);

DROP TABLE IF EXISTS materials_prices;


CREATE TABLE materials_prices (

    id SERIAL PRIMARY KEY,

    timestamp TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,

    -- جرامات الذهب (بيع وشراء)

    p24_buy NUMERIC(10, 2), p24_sell NUMERIC(10, 2),

    p21_buy NUMERIC(10, 2), p21_sell NUMERIC(10, 2),

    p18_buy NUMERIC(10, 2), p18_sell NUMERIC(10, 2),

    -- الوحدات الكبيرة

    ounce_buy NUMERIC(12, 2), ounce_sell NUMERIC(12, 2),

    gold_pound_buy NUMERIC(12, 2), gold_pound_sell NUMERIC(12, 2),

    -- السبايك

    bar_50g_buy NUMERIC(12, 2), bar_50g_sell NUMERIC(12, 2),

    bar_100g_buy NUMERIC(12, 2), bar_100g_sell NUMERIC(12, 2),

    bar_250g_buy NUMERIC(15, 2), bar_250g_sell NUMERIC(15, 2)

);-- -- -- -- INSERT INTO public.follows (follower_id, following_id)

-- -- -- -- VALUES

-- -- -- -- ('ca6f31e8-4715-42d2-96e2-1fb95df03147','56589116-515d-4283-80c8-0492ea7df74e');


-- -- -- -- دالة إشعار البوست الجديد للمتابعين

-- -- -- CREATE OR REPLACE FUNCTION public.handle_new_post_notification()

-- -- -- RETURNS TRIGGER AS $$

-- -- -- DECLARE

-- -- --     follower_record RECORD;

-- -- --     sender_name text;

-- -- -- BEGIN

-- -- --     -- جلب اسم الشخص اللي نزل البوست

-- -- --     SELECT name INTO sender_name FROM public.profiles WHERE id = new.user_id;


-- -- --     -- نلف على كل واحد عامل فولو لليوزر ده ونبعتله إشعار

-- -- --     FOR follower_record IN

-- -- --         SELECT follower_id FROM public.follows WHERE following_id = new.user_id

-- -- --     LOOP

-- -- --         INSERT INTO public.notifications (recipient_id, sender_id, resource_id, type, title, body, metadata)

-- -- --         VALUES (

-- -- --             follower_record.follower_id,

-- -- --             new.user_id,

-- -- --             new.id,

-- -- --             'comment', -- أو ممكن تسميه 'post' وتضيفه في الـ CHECK constraint بتاع الجدول

-- -- --             'New Post',

-- -- --             sender_name || ' shared a new post: ' || left(new.content, 30) || '...',

-- -- --             jsonb_build_object('post_id', new.id)

-- -- --         );

-- -- --     END LOOP;

-- -- --     RETURN new;

-- -- -- END;

-- -- -- $$ LANGUAGE plpgsql SECURITY DEFINER;


-- -- -- -- تفعيل التريجر على جدول الـ posts

-- -- -- DROP TRIGGER IF EXISTS on_post_created ON public.posts;

-- -- -- CREATE TRIGGER on_post_created

-- -- --   AFTER INSERT ON public.posts

-- -- --   FOR EACH ROW EXECUTE PROCEDURE public.handle_new_post_notification();


-- -- INSERT INTO public.posts (user_id, content, sentiment)

-- -- VALUES ('ca6f31e8-4715-42d2-96e2-1fb95df03147', 'أنا لسه منزل بوست جديد عن سهم طلعت مصطفى! 🚀', 'bullish');



-- -- 1. التأكد من تفعيل الـ RLS على الجدول

-- ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;


-- -- 2. حذف أي سياسة قديمة عشان نبدأ على نظافة

-- DROP POLICY IF EXISTS "Users can only see their own notifications" ON public.notifications;

-- DROP POLICY IF EXISTS "Users can view own notifications" ON public.notifications;

-- DROP POLICY IF EXISTS "Public notifications viewable" ON public.notifications;ش



-- السياسة الصحيحة: المستلم فقط هو من يرى إشعاراته

CREATE POLICY "notifications_owner_select"

ON public.notifications

FOR SELECT

USING (auth.uid() = recipient_id);


-- سياسة التحديث: المستلم فقط هو من يحولها لـ "مقروءة"

CREATE POLICY "notifications_owner_update"

ON public.notifications

FOR UPDATE

USING (auth.uid() = recipient_id)

WITH CHECK (auth.uid() = recipient_id);-- -- 1. جدول رصيد المستخدم (الكاش الوهمي)

-- CREATE TABLE public.user_wallets (

--     user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL PRIMARY KEY,

--     balance numeric DEFAULT 100000.00, -- بنبدأ بـ 100 ألف جنيه وهمي مثلاً

--     initial_balance numeric DEFAULT 100000.00,

--     created_at timestamptz DEFAULT now()

-- );


-- -- 2. جدول الأسهم المملوكة (Holdings)

-- CREATE TABLE public.user_holdings (

--     user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,

--     symbol text NOT NULL, -- مثل TMGH أو GOLD أو BTC

--     quantity numeric NOT NULL DEFAULT 0,

--     average_price numeric NOT NULL DEFAULT 0, -- متوسط سعر الشراء

--     updated_at timestamptz DEFAULT now(),

--     PRIMARY KEY (user_id, symbol)

-- );


-- -- 3. سجل العمليات (Transactions History)

-- CREATE TABLE public.user_transactions (

--     id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,

--     user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,

--     symbol text NOT NULL,

--     type text CHECK (type IN ('buy', 'sell')),

--     quantity numeric NOT NULL,

--     price numeric NOT NULL,

--     total_value numeric NOT NULL,

--     created_at timestamptz DEFAULT now()

-- );


-- CREATE OR REPLACE FUNCTION execute_trade(

--     p_user_id uuid,

--     p_symbol text,

--     p_type text,

--     p_quantity numeric,

--     p_price numeric

-- ) RETURNS void AS $$

-- DECLARE

--     v_total_cost numeric := p_quantity * p_price;

--     v_current_balance numeric;

-- BEGIN

--     -- 1. التحقق من الرصيد لو العملية شراء

--     IF p_type = 'buy' THEN

--         SELECT balance INTO v_current_balance FROM public.user_wallets WHERE user_id = p_user_id;

--         IF v_current_balance < v_total_cost THEN

--             RAISE EXCEPTION 'رصيدك غير كافٍ لإتمام العملية';

--         END IF;


--         -- خصم الفلوس

--         UPDATE public.user_wallets SET balance = balance - v_total_cost WHERE user_id = p_user_id;


--         -- تحديث المحفظة (إضافة السهم أو تحديث المتوسط)

--         INSERT INTO public.user_holdings (user_id, symbol, quantity, average_price)

--         VALUES (p_user_id, p_symbol, p_quantity, p_price)

--         ON CONFLICT (user_id, symbol) DO UPDATE SET

--             average_price = ((public.user_holdings.quantity * public.user_holdings.average_price) + v_total_cost) / (public.user_holdings.quantity + p_quantity),

--             quantity = public.user_holdings.quantity + p_quantity;


--     -- 2. التحقق من الأسهم لو العملية بيع

--     ELSIF p_type = 'sell' THEN

--         -- منطق البيع (تأكد من وجود كمية كافية قبل الخصم)

--         UPDATE public.user_holdings SET quantity = quantity - p_quantity

--         WHERE user_id = p_user_id AND symbol = p_symbol AND quantity >= p_quantity;



--         IF NOT FOUND THEN RAISE EXCEPTION 'لا تملك كمية كافية للبيع'; END IF;


--         -- إضافة الفلوس للرصيد

--         UPDATE public.user_wallets SET balance = balance + v_total_cost WHERE user_id = p_user_id;

--     END IF;


--     -- 3. تسجيل العملية في التاريخ

--     INSERT INTO public.user_transactions (user_id, symbol, type, quantity, price, total_value)

--     VALUES (p_user_id, p_symbol, p_type, p_quantity, p_price, v_total_cost);

-- END;

-- $$ LANGUAGE plpgsql SECURITY DEFINER;


-- ضيف ده جوه الـ Function handle_new_user


-- CREATE OR REPLACE FUNCTION public.handle_new_user()

-- RETURNS TRIGGER AS $$

-- BEGIN

--   -- 1. إنشاء البروفايل (موجود عندك فعلاً)

--   INSERT INTO public.profiles (id, email, name, avatar_url)

--   VALUES (

--     new.id,

--     new.email,

--     COALESCE(new.raw_user_meta_data->>'name', new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),

--     COALESCE(new.raw_user_meta_data->>'avatar_url', new.raw_user_meta_data->>'picture')

--   )

--   ON CONFLICT (id) DO NOTHING;


--   -- 2. إنشاء المحفظة الوهمية فوراً (الإضافة الجديدة)

--   -- بنستخدم NEW.id عشان نربط المحفظة باليوزر اللي لسه مسجل

--   INSERT INTO public.user_wallets (user_id, balance)

--   VALUES (new.id, 100000.00) -- الرصيد الافتراضي 100 ألف

--   ON CONFLICT (user_id) DO NOTHING;


--   RETURN new;

-- END;

-- $$ LANGUAGE plpgsql SECURITY DEFINER;DROP TABLE IF EXISTS market_history;


CREATE TABLE market_history (

    id BIGINT GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,

    trade_date DATE NOT NULL,          -- تاريخ اليوم (للمقارنة)

    market_cap TEXT,                   -- رأس المال السوقي

    value_traded TEXT,                 -- قيمة التداول

    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now())

);


-- بنعمل Index عشان البحث بالتاريخ يبقى سريع جداً

CREATE INDEX idx_trade_date ON market_history(trade_date);


-- CREATE OR REPLACE FUNCTION public.handle_new_user()

-- RETURNS TRIGGER AS $$

-- BEGIN

--   INSERT INTO public.profiles (id, email, name, avatar_url)

--   VALUES (

--     new.id,

--     new.email,

--     COALESCE(new.raw_user_meta_data->>'name', new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),

--     COALESCE(new.raw_user_meta_data->>'avatar_url', new.raw_user_meta_data->>'picture')

--   )

--   -- الحل السحري هنا: لو لقيت الـ ID موجود، متطلعش Error، اعمل Update للبيانات الجديدة

--   ON CONFLICT (id) DO UPDATE SET

--     email = EXCLUDED.email,

--     name = COALESCE(EXCLUDED.name, public.profiles.name),

--     avatar_url = COALESCE(EXCLUDED.avatar_url, public.profiles.avatar_url),

--     updated_at = now();


--   -- تأكد من إنشاء المحفظة الوهمية برضه بدون أخطاء

--   INSERT INTO public.user_wallets (user_id, balance)

--   VALUES (new.id, 100000.00)

--   ON CONFLICT (user_id) DO NOTHING;


--   RETURN new;

-- END;

-- $$ LANGUAGE plpgsql SECURITY DEFINER;  INSERT INTO "public"."stocks" ("symbol", "company_name_en", "company_name_ar", "sector", "description", "total_shares", "prev_close", "isin_code", "logo_url", "listing_date", "website", "candle_table_name", "created_at") VALUES

('SHIB', 'Shiba Inu', 'شيبا إينو', 'Crypto', 'Shiba Inu is a meme coin that evolved into a vibrant ecosystem.', 589000000000000, 0, 'CRYPTO-SHIB', 'https://cryptologos.cc/logos/shiba-inu-shib-logo.png', '2020-08-01', 'https://shibatoken.com', 'API', NOW()),

('PEPE', 'Pepe', 'بيبي', 'Crypto', 'Pepe is a deflationary meme coin launched on Ethereum.', 420690000000000, 0, 'CRYPTO-PEPE', 'https://cryptologos.cc/logos/pepe-pepe-logo.png', '2023-04-17', 'https://www.pepe.vip', 'API', NOW()),

('MATIC', 'Polygon', 'بوليجون', 'Crypto', 'Polygon is a protocol and a framework for building and connecting Ethereum-compatible blockchain networks.', 10000000000, 0, 'CRYPTO-MATIC', 'https://cryptologos.cc/logos/polygon-matic-logo.png', '2017-10-01', 'https://polygon.technology', 'API', NOW()),

('LTC', 'Litecoin', 'لايت كوين', 'Crypto', 'Litecoin is a peer-to-peer cryptocurrency often considered the silver to Bitcoins gold.', 84000000, 0, 'CRYPTO-LTC', 'https://cryptologos.cc/logos/litecoin-ltc-logo.png', '2011-10-07', 'https://litecoin.org', 'API', NOW()),

('UNI', 'Uniswap', 'يوني سواب', 'Crypto', 'Uniswap is a popular decentralized trading protocol.', 1000000000, 0, 'CRYPTO-UNI', 'https://cryptologos.cc/logos/uniswap-uni-logo.png', '2020-09-17', 'https://uniswap.org', 'API', NOW()),

('TRX', 'TRON', 'ترون', 'Crypto', 'TRON is a blockchain-based operating system.', 89000000000, 0, 'CRYPTO-TRX', 'https://cryptologos.cc/logos/tron-trx-logo.png', '2017-09-13', 'https://tron.network', 'API', NOW()),

('ETC', 'Ethereum Classic', 'إيثيريوم كلاسيك', 'Crypto', 'Ethereum Classic is a decentralized computing platform that runs smart contracts.', 210700000, 0, 'CRYPTO-ETC', 'https://cryptologos.cc/logos/ethereum-classic-etc-logo.png', '2016-07-20', 'https://ethereumclassic.org', 'API', NOW()),

('FIL', 'Filecoin', 'فايل كوين', 'Crypto', 'Filecoin is a decentralized storage system.', 1960000000, 0, 'CRYPTO-FIL', 'https://cryptologos.cc/logos/filecoin-fil-logo.png', '2020-10-15', 'https://filecoin.io', 'API', NOW()),

('AAVE', 'Aave', 'آف', 'Crypto', 'Aave is a decentralized finance protocol.', 16000000, 0, 'CRYPTO-AAVE', 'https://cryptologos.cc/logos/aave-aave-logo.png', '2020-10-02', 'https://aave.com', 'API', NOW()),

('NEAR', 'NEAR Protocol', 'نير بروتوكول', 'Crypto', 'NEAR Protocol is a layer-one blockchain.', 1000000000, 0, 'CRYPTO-NEAR', 'https://cryptologos.cc/logos/near-protocol-near-logo.png', '2020-04-22', 'https://near.org', 'API', NOW()),

('FET', 'Artificial Superintelligence', 'الذكاء الاصطناعي الفائق', 'Crypto', 'FET is the token powering the Artificial Superintelligence Alliance.', 2519000000, 0, 'CRYPTO-FET', 'https://cryptologos.cc/logos/fetch-ai-fet-logo.png', '2019-02-28', 'https://fetch.ai', 'API', NOW()),

('RNDR', 'Render', 'رندر', 'Crypto', 'Render Token is a distributed GPU rendering network.', 530000000, 0, 'CRYPTO-RNDR', 'https://cryptologos.cc/logos/render-rndr-logo.png', '2020-06-15', 'https://render.x.io', 'API', NOW()),

('ARB', 'Arbitrum', 'أربيتراوم', 'Crypto', 'Arbitrum is a layer-2 scaling solution for Ethereum.', 10000000000, 0, 'CRYPTO-ARB', 'https://cryptologos.cc/logos/arbitrum-arb-logo.png', '2023-03-23', 'https://arbitrum.io', 'API', NOW()),

('APT', 'Aptos', 'أبتوس', 'Crypto', 'Aptos is a Layer 1 Proof-of-Stake blockchain.', 1000000000, 0, 'CRYPTO-APT', 'https://cryptologos.cc/logos/aptos-apt-logo.png', '2022-10-12', 'https://aptoslabs.com', 'API', NOW()),

('ATOM', 'Cosmos', 'كوزموس', 'Crypto', 'Cosmos is an ecosystem of networks and tools.', 390000000, 0, 'CRYPTO-ATOM', 'https://cryptologos.cc/logos/cosmos-atom-logo.png', '2019-03-14', 'https://cosmos.network', 'API', NOW());-- 1. مسح الجدول القديم لو موجود عشان ننشئه بالهيكل الجديد

DROP TABLE IF EXISTS public.user_protection_rules;


CREATE TABLE public.user_protection_rules (

    id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,

    user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,

    symbol text NOT NULL,



    -- النسب (Thresholds)

    alert_percentage numeric DEFAULT 5.0,           -- نسبة التنبيه

    liquidation_percentage numeric DEFAULT 10.0,     -- نسبة البيع التلقائي



    -- زراير التحكم (The Switches) - الافتراضي false عشان اليوزر يفعلها بنفسه

    is_alert_enabled boolean DEFAULT false,         -- زرار "نبهني"

    is_sell_enabled boolean DEFAULT false,          -- زرار "بيع مكاني"



    last_alert_sent_at timestamptz,                 -- وقت آخر تنبيه (للـ Cooldown)

    created_at timestamptz DEFAULT now(),



    UNIQUE(user_id, symbol)                         -- قاعدة واحدة لكل سهم لكل مستخدم

);


-- 2. تفعيل الحماية (RLS)

ALTER TABLE public.user_protection_rules ENABLE ROW LEVEL SECURITY;


CREATE POLICY "Users can manage their own rules"

ON public.user_protection_rules

FOR ALL USING (auth.uid() = user_id);


-- 3. تحديث جدول العمليات (لو لسه معملتوش)

ALTER TABLE public.user_transactions

ADD COLUMN IF NOT EXISTS execution_type text DEFAULT 'manual'

CHECK (execution_type IN ('manual', 'auto_protection'));    -- 1. مسح الجدول لو كان موجود قبل كده (عشان نبدأ على نظافة)

    DROP TABLE IF EXISTS public.ai_predictions CASCADE;


    -- 2. إنشاء جدول التوقعات

    CREATE TABLE public.ai_predictions (

        id bigint GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,

        -- ربط الرمز بجدول الأسهم (عشان نضمن إن السهم موجود فعلاً)

        symbol varchar(10) REFERENCES public.stocks(symbol) ON DELETE CASCADE NOT NULL,

        close_price numeric NOT NULL,

        probability numeric NOT NULL, -- الرقم الخام اللي هيترسم بيه المؤشر (مثلاً 0.0535)

        created_at timestamptz DEFAULT timezone('utc'::text, now()) NOT NULL

    );


    -- 3. عمل Indexes عشان التطبيق (Flutter) يسحب الداتا بسرعة الصاروخ

    CREATE INDEX idx_ai_predictions_symbol ON public.ai_predictions (symbol);

    CREATE INDEX idx_ai_predictions_created_at ON public.ai_predictions (created_at DESC);


    -- 4. تفعيل حماية البيانات (RLS) والسماح للتطبيق بقراءتها

    ALTER TABLE public.ai_predictions ENABLE ROW LEVEL SECURITY;

    CREATE POLICY "Public Read AI Predictions" ON public.ai_predictions FOR SELECT USING (true);

    -- السماح بإدخال بيانات جديدة في جدول التوقعات

    CREATE POLICY "Allow AI Inserts" ON public.ai_predictions FOR INSERT WITH CHECK (true);

    -- السماح لأي حد (حتى الـ Anon Key) إنه يرفع توقعات للجدول ده

    CREATE POLICY "Allow Public Insert" ON public.ai_predictions FOR INSERT WITH CHECK (true);



