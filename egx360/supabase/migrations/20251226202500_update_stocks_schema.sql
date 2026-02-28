-- 1. Drop columns as requested
ALTER TABLE stocks 
DROP COLUMN IF EXISTS current_price,
DROP COLUMN IF EXISTS change_percent;

-- 2. Trending Stocks RPC (Calculates values dynamically)
CREATE OR REPLACE FUNCTION get_stocks_with_sparklines(row_limit INT)
RETURNS JSONB LANGUAGE plpgsql AS $$
DECLARE
    stock_record RECORD;
    final_json JSONB := '[]'::JSONB;
    latest_price FLOAT4;
    calc_change FLOAT4;
    spark_data JSONB;
BEGIN
    FOR stock_record IN (
        SELECT * FROM stocks 
        WHERE sector != 'Indices' 
        AND candle_table_name != 'API' 
        LIMIT row_limit
    ) 
    LOOP
        IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = stock_record.candle_table_name) THEN
            -- Get latest price
            EXECUTE format('SELECT close FROM %I ORDER BY timestamp DESC LIMIT 1', stock_record.candle_table_name) INTO latest_price;
            
            -- Get sparkline data
            EXECUTE format('SELECT json_agg(c) FROM (SELECT close FROM %I ORDER BY timestamp DESC LIMIT 20) sub(c)', stock_record.candle_table_name) INTO spark_data;

            -- Calculate change
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

-- 3. Indices RPC
CREATE OR REPLACE FUNCTION get_indices_with_sparklines()
RETURNS JSONB LANGUAGE plpgsql AS $$
DECLARE
    index_record RECORD;
    final_json JSONB := '[]'::JSONB;
    latest_price FLOAT4;
    calc_change FLOAT4;
    spark_data JSONB;
BEGIN
    FOR index_record IN (SELECT * FROM stocks WHERE sector = 'Indices' LIMIT 2) 
    LOOP
        IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = index_record.candle_table_name) THEN
            EXECUTE format('SELECT close FROM %I ORDER BY timestamp DESC LIMIT 1', index_record.candle_table_name) INTO latest_price;
            EXECUTE format('SELECT json_agg(c) FROM (SELECT close FROM %I ORDER BY timestamp DESC LIMIT 20) sub(c)', index_record.candle_table_name) INTO spark_data;
            
            calc_change := CASE WHEN index_record.prev_close > 0 
                           THEN ((latest_price - index_record.prev_close) / index_record.prev_close) * 100 
                           ELSE 0 END;

            final_json := final_json || jsonb_build_object(
                'id', index_record.id,
                'symbol', index_record.symbol,
                'company_name_en', index_record.company_name_en,
                'current_price', latest_price,
                'change_percent', ROUND(calc_change::numeric, 2),
                'logo_url', index_record.logo_url,
                'sparkline_data', COALESCE(spark_data, '[]'::JSONB)
            );
        END IF;
    END LOOP;
    RETURN final_json;
END;
$$;

-- 4. Watchlist RPC
CREATE OR REPLACE FUNCTION get_watchlist_with_sparklines(viewer_id UUID)
RETURNS JSONB LANGUAGE plpgsql AS $$
DECLARE
    stock_record RECORD;
    final_json JSONB := '[]'::JSONB;
    latest_price FLOAT4;
    calc_change FLOAT4;
    spark_data JSONB;
BEGIN
    FOR stock_record IN (
        SELECT s.* FROM stocks s JOIN user_watchlist uw ON s.symbol = uw.stock_symbol WHERE uw.user_id = viewer_id
    ) 
    LOOP
        IF EXISTS (SELECT FROM information_schema.tables WHERE table_name = stock_record.candle_table_name) THEN
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

-- Add Foreign Key to user_watchlist if it doesn't exist
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_constraint WHERE conname = 'user_watchlist_stock_symbol_fkey') THEN
        ALTER TABLE user_watchlist
        ADD CONSTRAINT user_watchlist_stock_symbol_fkey
        FOREIGN KEY (stock_symbol)
        REFERENCES stocks(symbol)
        ON DELETE CASCADE;
    END IF;
END $$;
