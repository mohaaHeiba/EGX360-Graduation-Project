-- ==============================================================================
-- 5. INDEXES & ROW LEVEL SECURITY (RLS)
-- ==============================================================================

-- Indexes
CREATE INDEX idx_posts_cashtags             ON public.posts          USING GIN (cashtags);
CREATE INDEX idx_posts_user_id              ON public.posts          (user_id);
CREATE INDEX idx_comments_post_id           ON public.comments       (post_id);
CREATE INDEX idx_notifications_recipient    ON public.notifications  (recipient_id);
CREATE INDEX idx_notifications_recip_read   ON public.notifications  (recipient_id, is_read);
CREATE INDEX idx_notifications_created_at   ON public.notifications  (created_at DESC);
CREATE INDEX idx_post_votes_post_id         ON public.post_votes     (post_id);
CREATE INDEX idx_market_history_date        ON public.market_history (trade_date);
CREATE INDEX idx_ai_predictions_symbol      ON public.ai_predictions (symbol);
CREATE INDEX idx_ai_predictions_created_at  ON public.ai_predictions (created_at DESC);

-- Enable/Disable RLS
ALTER TABLE public.profiles             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.follows              ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_watchlist       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts                ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_votes           ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bookmarks            ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments             ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comment_votes        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_wallets         ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_holdings        ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_transactions    ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_protection_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_risk_profiles   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_predictions       ENABLE ROW LEVEL SECURITY;

ALTER TABLE public.stocks               DISABLE ROW LEVEL SECURITY;  -- public read
ALTER TABLE public.stock_news           DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.materials_prices     DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.market_history       DISABLE ROW LEVEL SECURITY;

-- Profiles
CREATE POLICY "profiles_public_select"  ON public.profiles FOR SELECT USING (true);
CREATE POLICY "profiles_owner_update"   ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Posts
CREATE POLICY "posts_public_select"     ON public.posts FOR SELECT USING (true);
CREATE POLICY "posts_owner_insert"      ON public.posts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "posts_owner_delete"      ON public.posts FOR DELETE USING (auth.uid() = user_id);

-- Comments
CREATE POLICY "comments_public_select"  ON public.comments FOR SELECT USING (true);
CREATE POLICY "comments_owner_insert"   ON public.comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "comments_owner_delete"   ON public.comments FOR DELETE USING (auth.uid() = user_id);

-- Post votes
CREATE POLICY "post_votes_public_select" ON public.post_votes FOR SELECT USING (true);
CREATE POLICY "post_votes_owner_insert"  ON public.post_votes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "post_votes_owner_delete"  ON public.post_votes FOR DELETE USING (auth.uid() = user_id);

-- Comment votes
CREATE POLICY "comment_votes_public_select" ON public.comment_votes FOR SELECT USING (true);
CREATE POLICY "comment_votes_owner_insert"  ON public.comment_votes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "comment_votes_owner_delete"  ON public.comment_votes FOR DELETE USING (auth.uid() = user_id);

-- Follows
CREATE POLICY "follows_public_select"   ON public.follows FOR SELECT USING (true);
CREATE POLICY "follows_owner_insert"    ON public.follows FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "follows_owner_delete"    ON public.follows FOR DELETE USING (auth.uid() = follower_id);

-- Bookmarks
CREATE POLICY "bookmarks_owner_select"  ON public.bookmarks FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "bookmarks_owner_insert"  ON public.bookmarks FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "bookmarks_owner_delete"  ON public.bookmarks FOR DELETE USING (auth.uid() = user_id);

-- Watchlist
CREATE POLICY "watchlist_owner_select"  ON public.user_watchlist FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "watchlist_owner_insert"  ON public.user_watchlist FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "watchlist_owner_delete"  ON public.user_watchlist FOR DELETE USING (auth.uid() = user_id);

-- Notifications
CREATE POLICY "notifications_owner_select" ON public.notifications FOR SELECT USING (auth.uid() = recipient_id);
CREATE POLICY "notifications_owner_update" ON public.notifications FOR UPDATE USING (auth.uid() = recipient_id) WITH CHECK (auth.uid() = recipient_id);

-- Portfolio tables (owner only)
CREATE POLICY "wallets_owner_all"       ON public.user_wallets         FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "holdings_owner_all"      ON public.user_holdings         FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "transactions_owner_all"  ON public.user_transactions      FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "protection_owner_all"    ON public.user_protection_rules  FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "risk_profile_owner_all"  ON public.user_risk_profiles     FOR ALL USING (auth.uid() = user_id);

-- AI predictions (public read, open insert for Python scripts)
CREATE POLICY "ai_pred_public_select"   ON public.ai_predictions FOR SELECT USING (true);
CREATE POLICY "ai_pred_public_insert"   ON public.ai_predictions FOR INSERT WITH CHECK (true);


-- Stocks_Messages (public read, open insert for Python scripts)
CREATE INDEX idx_stock_messages_stock_id ON public.stock_messages(stock_id);
CREATE INDEX idx_stock_messages_created_at ON public.stock_messages(created_at DESC);

ALTER TABLE public.stock_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "stock_messages_public_select" ON public.stock_messages FOR SELECT USING (true);
CREATE POLICY "stock_messages_owner_insert"  ON public.stock_messages FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "stock_messages_owner_delete"  ON public.stock_messages FOR DELETE USING (auth.uid() = user_id);