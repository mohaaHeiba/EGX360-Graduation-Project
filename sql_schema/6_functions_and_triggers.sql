-- ==============================================================================
-- 6. TRIGGERS, FUNCTIONS & RPCs
-- ==============================================================================

-- A. Auto-create profile + wallet on new user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, email, name, avatar_url, created_at, updated_at)
    VALUES (
        new.id,
        new.email,
        COALESCE(new.raw_user_meta_data->>'name',
                 new.raw_user_meta_data->>'full_name',
                 split_part(new.email, '@', 1)),
        COALESCE(new.raw_user_meta_data->>'avatar_url',
                 new.raw_user_meta_data->>'picture'),
        now(), now()
    )
    ON CONFLICT (id) DO UPDATE SET
        email      = EXCLUDED.email,
        name       = COALESCE(EXCLUDED.name, public.profiles.name),
        avatar_url = COALESCE(EXCLUDED.avatar_url, public.profiles.avatar_url),
        updated_at = now();

    INSERT INTO public.user_wallets (user_id, balance, initial_balance)
    VALUES (new.id, 100000.00, 100000.00)
    ON CONFLICT (user_id) DO NOTHING;

    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();

-- B. Notifications: comment & reply
CREATE OR REPLACE FUNCTION public.handle_new_comment_notification()
RETURNS TRIGGER AS $$
DECLARE
    post_owner_id   uuid;
    parent_owner_id uuid;
    sender_name     text;
BEGIN
    SELECT name INTO sender_name FROM public.profiles WHERE id = new.user_id;

    IF new.parent_id IS NOT NULL THEN
        SELECT user_id INTO parent_owner_id FROM public.comments WHERE id = new.parent_id;
        IF parent_owner_id != new.user_id THEN
            INSERT INTO public.notifications
                (recipient_id, sender_id, resource_id, type, title, body, metadata)
            VALUES (
                parent_owner_id, new.user_id, new.post_id, 'reply',
                'New Reply', sender_name || ' replied to your comment',
                jsonb_build_object('post_id', new.post_id, 'comment_id', new.id)
            );
        END IF;
    ELSE
        SELECT user_id INTO post_owner_id FROM public.posts WHERE id = new.post_id;
        IF post_owner_id != new.user_id THEN
            INSERT INTO public.notifications
                (recipient_id, sender_id, resource_id, type, title, body, metadata)
            VALUES (
                post_owner_id, new.user_id, new.post_id, 'comment',
                'New Comment', sender_name || ' commented on your post',
                jsonb_build_object('post_id', new.post_id)
            );
        END IF;
    END IF;
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_comment_created
    AFTER INSERT ON public.comments
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_comment_notification();

-- C. Notifications: post like (vote_type = 1 only)
CREATE OR REPLACE FUNCTION public.handle_new_like_notification()
RETURNS TRIGGER AS $$
DECLARE
    post_owner_id uuid;
    sender_name   text;
BEGIN
    IF new.vote_type = 1 THEN
        SELECT name INTO sender_name FROM public.profiles WHERE id = new.user_id;
        SELECT user_id INTO post_owner_id FROM public.posts WHERE id = new.post_id;
        IF post_owner_id != new.user_id THEN
            INSERT INTO public.notifications
                (recipient_id, sender_id, resource_id, type, title, body, metadata)
            VALUES (
                post_owner_id, new.user_id, new.post_id, 'like',
                'New Like', sender_name || ' liked your post',
                jsonb_build_object('post_id', new.post_id)
            );
        END IF;
    END IF;
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_post_like
    AFTER INSERT ON public.post_votes
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_like_notification();

-- D. Notifications: comment like (vote_type = 1 only)
CREATE OR REPLACE FUNCTION public.handle_comment_like_notification()
RETURNS TRIGGER AS $$
DECLARE
    comment_owner_id uuid;
    sender_name      text;
    post_id_val      bigint;
BEGIN
    IF new.vote_type = 1 THEN
        SELECT name INTO sender_name FROM public.profiles WHERE id = new.user_id;
        SELECT user_id, post_id INTO comment_owner_id, post_id_val
        FROM public.comments WHERE id = new.comment_id;
        IF comment_owner_id != new.user_id THEN
            INSERT INTO public.notifications
                (recipient_id, sender_id, resource_id, type, title, body, metadata)
            VALUES (
                comment_owner_id, new.user_id, new.comment_id, 'like',
                'Comment Liked', sender_name || ' liked your comment',
                jsonb_build_object('post_id', post_id_val, 'comment_id', new.comment_id)
            );
        END IF;
    END IF;
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_comment_like
    AFTER INSERT ON public.comment_votes
    FOR EACH ROW EXECUTE PROCEDURE public.handle_comment_like_notification();

-- E. Notifications: follow
CREATE OR REPLACE FUNCTION public.handle_new_follow_notification()
RETURNS TRIGGER AS $$
DECLARE
    sender_name text;
BEGIN
    SELECT name INTO sender_name FROM public.profiles WHERE id = new.follower_id;
    INSERT INTO public.notifications
        (recipient_id, sender_id, resource_id, type, title, body, metadata)
    VALUES (
        new.following_id, new.follower_id, 0, 'follow',
        'New Follower', sender_name || ' started following you',
        jsonb_build_object('follower_id', new.follower_id)
    );
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_follow_created
    AFTER INSERT ON public.follows
    FOR EACH ROW EXECUTE PROCEDURE public.handle_new_follow_notification();

-- F. RPC: Posts feed
CREATE OR REPLACE FUNCTION get_posts_with_status(
    viewer_id       uuid,
    target_user_id  uuid,
    limit_val       int,
    offset_val      int,
    category_filter text DEFAULT NULL
)
RETURNS TABLE (
    id             bigint,
    user_id        uuid,
    content        text,
    image_url      text,
    sentiment      text,
    cashtags       text[],
    created_at     timestamptz,
    user_name      text,
    user_avatar    text,
    likes_count    bigint,
    dislikes_count bigint,
    comments_count bigint,
    is_liked       boolean,
    is_bookmarked  boolean
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id, p.user_id, p.content, p.image_url,
        p.sentiment::text, p.cashtags, p.created_at,
        pr.name::text, pr.avatar_url::text,
        (SELECT count(*) FROM public.post_votes v WHERE v.post_id = p.id AND v.vote_type =  1),
        (SELECT count(*) FROM public.post_votes v WHERE v.post_id = p.id AND v.vote_type = -1),
        (SELECT count(*) FROM public.comments   c WHERE c.post_id = p.id),
        EXISTS(SELECT 1 FROM public.post_votes v WHERE v.post_id = p.id AND v.user_id = viewer_id AND v.vote_type = 1),
        EXISTS(SELECT 1 FROM public.bookmarks   b WHERE b.post_id = p.id AND b.user_id = viewer_id)
    FROM public.posts p
    LEFT JOIN public.profiles pr ON p.user_id = pr.id
    WHERE
        (target_user_id IS NULL OR p.user_id = target_user_id)
        AND (
            category_filter IS NULL
            OR EXISTS (
                SELECT 1 FROM unnest(p.cashtags) AS tag
                WHERE tag ILIKE '%' || category_filter || '%'
            )
        )
    ORDER BY p.created_at DESC
    LIMIT limit_val OFFSET offset_val;
END;
$$;

-- G. RPC: Comments
CREATE OR REPLACE FUNCTION get_comments_with_status(
    viewer_id      uuid,
    target_post_id bigint
)
RETURNS TABLE (
    id             bigint,
    post_id        bigint,
    parent_id      bigint,
    content        text,
    created_at     timestamptz,
    user_id        uuid,
    user_name      text,
    user_avatar    text,
    likes_count    bigint,
    dislikes_count bigint,
    user_vote_type int,
    parent_username text
)
LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.id, c.post_id, c.parent_id, c.content, c.created_at, c.user_id,
        pr.name::text, pr.avatar_url::text,
        (SELECT count(*) FROM public.comment_votes cv WHERE cv.comment_id = c.id AND cv.vote_type =  1),
        (SELECT count(*) FROM public.comment_votes cv WHERE cv.comment_id = c.id AND cv.vote_type = -1),
        (SELECT vote_type FROM public.comment_votes cv WHERE cv.comment_id = c.id AND cv.user_id = viewer_id),
        (SELECT p2.name::text FROM public.comments c2 JOIN public.profiles p2 ON c2.user_id = p2.id WHERE c2.id = c.parent_id)
    FROM public.comments c
    LEFT JOIN public.profiles pr ON c.user_id = pr.id
    WHERE c.post_id = target_post_id
    ORDER BY c.created_at ASC;
END;
$$;

-- H. RPC: Chart history
CREATE OR REPLACE FUNCTION get_chart_history(
    target_symbol TEXT,
    before_date   TIMESTAMPTZ DEFAULT NULL,
    limit_count   INT         DEFAULT 100
)
RETURNS TABLE (
    candle_time TIMESTAMPTZ,
    open        FLOAT4,
    high        FLOAT4,
    low         FLOAT4,
    close       FLOAT4,
    volume      BIGINT,
    res         VARCHAR(5)
)
LANGUAGE plpgsql AS $$
DECLARE
    target_table TEXT;
    query_date   TIMESTAMPTZ;
BEGIN
    SELECT candle_table_name INTO target_table FROM public.stocks WHERE symbol = target_symbol;
    IF target_table IS NULL OR target_table = 'API' THEN RETURN; END IF;

    query_date := COALESCE(before_date, now() + INTERVAL '100 years');

    RETURN QUERY EXECUTE format('
        WITH latest AS (
            SELECT timestamp, open, high, low, close, volume, timeframe
            FROM %I WHERE timestamp < %L ORDER BY timestamp DESC LIMIT %s
        )
        SELECT timestamp, open, high, low, close, volume, timeframe FROM latest ORDER BY timestamp ASC;
    ', target_table, query_date, limit_count);
END;
$$;

-- I. RPC: Trending stocks
CREATE OR REPLACE FUNCTION get_trending_stocks(row_limit INT)
RETURNS JSONB LANGUAGE plpgsql AS $$
DECLARE
    stock_record    RECORD;
    final_json      JSONB    := '[]'::JSONB;
    latest_price    FLOAT4;
    latest_vol      BIGINT;
    avg_vol         FLOAT4;
    calc_change     FLOAT4;
    trending_score  FLOAT4;
    spark_data      JSONB;
BEGIN
    CREATE TEMP TABLE trending_results (
        id          BIGINT, symbol TEXT, name_en TEXT,
        price       FLOAT4, change_pct FLOAT4, score FLOAT4,
        logo        TEXT,   spark JSONB
    ) ON COMMIT DROP;

    FOR stock_record IN (
        SELECT * FROM public.stocks WHERE sector != 'Indices' AND candle_table_name != 'API'
    ) LOOP
        IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = stock_record.candle_table_name) THEN
            EXECUTE format('SELECT close, volume FROM %I ORDER BY timestamp DESC LIMIT 1', stock_record.candle_table_name)
            INTO latest_price, latest_vol;

            EXECUTE format('SELECT AVG(volume) FROM (SELECT volume FROM %I ORDER BY timestamp DESC LIMIT 10) sub', stock_record.candle_table_name)
            INTO avg_vol;

            EXECUTE format('SELECT json_agg(c) FROM (SELECT close FROM %I ORDER BY timestamp DESC LIMIT 20) sub(c)', stock_record.candle_table_name)
            INTO spark_data;

            calc_change := CASE WHEN stock_record.prev_close > 0
                           THEN ((latest_price - stock_record.prev_close) / stock_record.prev_close) * 100
                           ELSE 0 END;

            trending_score := (COALESCE(latest_vol / NULLIF(avg_vol, 0), 1) * 0.7) + (ABS(calc_change) * 0.3);

            INSERT INTO trending_results VALUES (
                stock_record.id, stock_record.symbol, stock_record.company_name_en,
                latest_price, ROUND(calc_change::numeric, 2), trending_score,
                stock_record.logo_url, COALESCE(spark_data, '[]'::JSONB)
            );
        END IF;
    END LOOP;

    SELECT jsonb_agg(to_jsonb(t) - 'score') INTO final_json
    FROM (SELECT * FROM trending_results ORDER BY score DESC LIMIT row_limit) t;

    RETURN final_json;
END;
$$;

-- J. RPC: Watchlist
CREATE OR REPLACE FUNCTION get_watchlist_with_sparklines(viewer_id UUID)
RETURNS JSONB LANGUAGE plpgsql AS $$
DECLARE
    stock_record RECORD;
    final_json   JSONB    := '[]'::JSONB;
    latest_price FLOAT4;
    calc_change  FLOAT4;
    spark_data   JSONB;
BEGIN
    FOR stock_record IN (
        SELECT s.* FROM public.stocks s
        JOIN public.user_watchlist uw ON s.symbol = uw.stock_symbol
        WHERE uw.user_id = viewer_id
    ) LOOP
        IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = stock_record.candle_table_name)
           AND stock_record.candle_table_name != 'API' THEN

            EXECUTE format('SELECT close FROM %I ORDER BY timestamp DESC LIMIT 1', stock_record.candle_table_name) INTO latest_price;
            EXECUTE format('SELECT json_agg(c) FROM (SELECT close FROM %I ORDER BY timestamp DESC LIMIT 20) sub(c)', stock_record.candle_table_name) INTO spark_data;

            calc_change := CASE WHEN stock_record.prev_close > 0
                           THEN ((latest_price - stock_record.prev_close) / stock_record.prev_close) * 100
                           ELSE 0 END;

            final_json := final_json || jsonb_build_object(
                'id', stock_record.id,
                'symbol', stock_record.symbol,
                'company_name_en', stock_record.company_name_en,
                'current_price', latest_price,
                'change_percent', ROUND(calc_change::numeric, 2),
                'logo_url', stock_record.logo_url,
                'sparkline_data', COALESCE(spark_data, '[]'::JSONB)
            );
        END IF;
    END LOOP;
    RETURN final_json;
END;
$$;

-- K. RPC: Setup Portfolio
CREATE OR REPLACE FUNCTION setup_user_portfolio(
    p_user_id    uuid,
    p_experience text,
    p_goal       text,
    p_sectors    text[]
)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE v_risk_score int := 50;
BEGIN
    IF p_goal = 'أمان'     THEN v_risk_score := 20; END IF;
    IF p_goal = 'مخاطرة'   THEN v_risk_score := 80; END IF;
    IF p_experience = 'مبتدئ' THEN v_risk_score := v_risk_score - 10; END IF;
    IF p_experience = 'خبير'  THEN v_risk_score := v_risk_score + 10; END IF;
    v_risk_score := GREATEST(10, LEAST(100, v_risk_score));

    INSERT INTO public.user_risk_profiles
        (user_id, experience_level, investment_goal, risk_score, selected_sectors)
    VALUES (p_user_id, p_experience, p_goal, v_risk_score, p_sectors)
    ON CONFLICT (user_id) DO UPDATE SET
        experience_level = EXCLUDED.experience_level,
        investment_goal  = EXCLUDED.investment_goal,
        risk_score       = EXCLUDED.risk_score,
        selected_sectors = EXCLUDED.selected_sectors,
        updated_at       = now();

    DELETE FROM public.user_watchlist WHERE user_id = p_user_id;

    IF v_risk_score <= 30 THEN
        INSERT INTO public.user_watchlist (user_id, stock_symbol) VALUES (p_user_id, 'GOLD')   ON CONFLICT DO NOTHING;
        INSERT INTO public.user_watchlist (user_id, stock_symbol) VALUES (p_user_id, 'USDEGP') ON CONFLICT DO NOTHING;
        INSERT INTO public.user_watchlist (user_id, stock_symbol) VALUES (p_user_id, 'EGX30')  ON CONFLICT DO NOTHING;
    ELSIF v_risk_score >= 70 THEN
        INSERT INTO public.user_watchlist (user_id, stock_symbol) VALUES (p_user_id, 'BTC')    ON CONFLICT DO NOTHING;
        INSERT INTO public.user_watchlist (user_id, stock_symbol) VALUES (p_user_id, 'ETH')    ON CONFLICT DO NOTHING;
    END IF;

    INSERT INTO public.user_watchlist (user_id, stock_symbol)
    SELECT p_user_id, symbol
    FROM (
        SELECT symbol, ROW_NUMBER() OVER (PARTITION BY sector ORDER BY symbol) AS rn
        FROM public.stocks WHERE sector = ANY(p_sectors)
    ) sub WHERE rn <= 2
    LIMIT 7
    ON CONFLICT DO NOTHING;
END;
$$;

-- L. RPC: Execute Trade
CREATE OR REPLACE FUNCTION execute_trade(
    p_user_id  uuid,
    p_symbol   text,
    p_type     text,
    p_quantity numeric,
    p_price    numeric
)
RETURNS void LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE v_total_cost numeric := p_quantity * p_price;
        v_balance    numeric;
BEGIN
    IF p_type = 'buy' THEN
        SELECT balance INTO v_balance FROM public.user_wallets WHERE user_id = p_user_id;
        IF v_balance < v_total_cost THEN RAISE EXCEPTION 'رصيدك غير كافٍ'; END IF;

        UPDATE public.user_wallets SET balance = balance - v_total_cost WHERE user_id = p_user_id;

        INSERT INTO public.user_holdings (user_id, symbol, quantity, average_price)
        VALUES (p_user_id, p_symbol, p_quantity, p_price)
        ON CONFLICT (user_id, symbol) DO UPDATE SET
            average_price = ((public.user_holdings.quantity * public.user_holdings.average_price) + v_total_cost)
                            / (public.user_holdings.quantity + p_quantity),
            quantity      = public.user_holdings.quantity + p_quantity;

    ELSIF p_type = 'sell' THEN
        UPDATE public.user_holdings SET quantity = quantity - p_quantity
        WHERE user_id = p_user_id AND symbol = p_symbol AND quantity >= p_quantity;
        IF NOT FOUND THEN RAISE EXCEPTION 'لا تملك كمية كافية للبيع'; END IF;

        UPDATE public.user_wallets SET balance = balance + v_total_cost WHERE user_id = p_user_id;
    END IF;

    INSERT INTO public.user_transactions (user_id, symbol, type, quantity, price, total_value)
    VALUES (p_user_id, p_symbol, p_type, p_quantity, p_price, v_total_cost);
END;
$$;




CREATE OR REPLACE FUNCTION public.get_latest_ai_prediction(p_symbol TEXT)
RETURNS TABLE (
    symbol VARCHAR,
    company_name_ar VARCHAR,
    company_name_en VARCHAR,
    sector VARCHAR,
    close_price NUMERIC,
    probability NUMERIC,
    overall_trend VARCHAR,
    ml_signal VARCHAR,
    volatility_status VARCHAR,
    macd_status VARCHAR,
    momentum_status VARCHAR,
    atr_pct FLOAT8,
    prediction_date DATE
) LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.symbol,
        s.company_name_ar,
        s.company_name_en,
        s.sector,
        p.close_price,
        p.probability,
        p.overall_trend,
        p.ml_signal,
        p.volatility_status,
        p.macd_status,
        p.momentum_status,
        p.atr_pct,
        p.prediction_date
    FROM public.ai_predictions p
    JOIN public.stocks s ON p.symbol = s.symbol
    WHERE p.symbol = UPPER(p_symbol)
    ORDER BY p.prediction_date DESC, p.created_at DESC
    LIMIT 1;
END;
$$;
