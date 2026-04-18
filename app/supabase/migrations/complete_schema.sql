-- ==========================================
-- EGX360 - Complete Database Schema
-- ==========================================
-- This file contains the complete database schema for the EGX360 application
-- including stocks, indices, crypto, gold, and social features

-- ==========================================
-- 1. تنظيف شامل (Fresh Start) 🧹
-- ==========================================
-- حذف الدوال القديمة لتجنب التعارض
DROP FUNCTION IF EXISTS get_chart_history(TEXT, TIMESTAMPTZ, INT);
DROP FUNCTION IF EXISTS get_gold_chart_data(INT);
DROP FUNCTION IF EXISTS get_gold_chart_data(INT, VARCHAR);
DROP FUNCTION IF EXISTS get_chart_data(TEXT, INT);

-- حذف الجداول
DROP TABLE IF EXISTS stock_messages CASCADE;
DROP TABLE IF EXISTS stock_news CASCADE;
DROP TABLE IF EXISTS gold_candles CASCADE;
DROP TABLE IF EXISTS gold_prices CASCADE;

-- حذف جداول الشموع للشركات (لاحظ tmgh_candles)
DROP TABLE IF EXISTS 
    tmgh_candles, comi_candles, fwry_candles, abuk_candles, 
    east_candles, efih_candles, emfd_candles, etel_candles, 
    expa_candles, hrho_candles, iron_candles, oras_candles, swdy_candles CASCADE;

DROP TABLE IF EXISTS stocks CASCADE;

-- ==========================================
-- 2. جدول الأسهم الرئيسي (Master Table) 🏗️
-- ==========================================
CREATE TABLE stocks (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    symbol VARCHAR(10) UNIQUE NOT NULL,
    company_name_en VARCHAR(255) NOT NULL,
    company_name_ar VARCHAR(255),
    sector VARCHAR(100),
    description TEXT,
    total_shares BIGINT,
    prev_close FLOAT4 DEFAULT 0.0,
    isin_code VARCHAR(50),
    logo_url TEXT,
    listing_date DATE,
    website VARCHAR(255),
    candle_table_name VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ==========================================
-- 3. جداول الشموع (Stock Candles) 🕯️
-- ==========================================
-- تم توحيد اسم جدول طلعت مصطفى إلى tmgh_candles

CREATE TABLE tmgh_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
CREATE TABLE comi_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
CREATE TABLE fwry_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
CREATE TABLE abuk_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
CREATE TABLE east_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
CREATE TABLE efih_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
CREATE TABLE emfd_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
CREATE TABLE etel_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
CREATE TABLE expa_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
CREATE TABLE hrho_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
CREATE TABLE iron_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
CREATE TABLE oras_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));
CREATE TABLE swdy_candles (timestamp TIMESTAMPTZ NOT NULL, open FLOAT4, high FLOAT4, low FLOAT4, close FLOAT4, volume BIGINT, timeframe VARCHAR(5) NOT NULL, created_at TIMESTAMPTZ DEFAULT now(), PRIMARY KEY (timestamp, timeframe));

-- ==========================================
-- 4. جداول الذهب (Gold Tables) 🏆
-- ==========================================
CREATE TABLE gold_candles (
    timestamp TIMESTAMPTZ NOT NULL,
    open NUMERIC(12,2) NOT NULL,
    high NUMERIC(12,2) NOT NULL,
    low NUMERIC(12,2) NOT NULL,
    close NUMERIC(12,2) NOT NULL,
    gold_usd NUMERIC(12,2) NOT NULL,
    usd_egp NUMERIC(12,4) NOT NULL,
    timeframe VARCHAR(5) NOT NULL DEFAULT '1d', 
    created_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (timestamp, timeframe)
);

CREATE TABLE gold_prices (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    price_24k NUMERIC(10, 2),
    price_21k NUMERIC(10, 2),
    price_18k NUMERIC(10, 2)
);

-- ==========================================
-- 5. جداول التواصل والأخبار (Social) 💬
-- ==========================================
CREATE TABLE stock_news (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    stock_id BIGINT REFERENCES stocks(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT,
    content TEXT,
    url TEXT UNIQUE,
    source VARCHAR(100),
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE stock_messages (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    stock_id BIGINT REFERENCES stocks(id) ON DELETE CASCADE,
    user_id UUID DEFAULT auth.uid(),
    username VARCHAR(100),
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ==========================================
-- 6. إدخال بيانات الشركات (Data Insert) 📥
-- ==========================================
-- تم التأكد من اسم الجدول tmgh_candles
INSERT INTO stocks (symbol, company_name_en, company_name_ar, sector, candle_table_name, isin_code, logo_url, listing_date, website, total_shares, description) VALUES 
(
    'TMGH', 'Talaat Moustafa Group', 'مجموعة طلعت مصطفى', 'Real Estate', 'tmgh_candles', 'EGS65001C013', 
    'https://drive.google.com/uc?export=view&id=1uUYqPlcZK4wmb-CO62mS-sYwYYNWmBoU', 
    '2007-11-01', 'https://www.tmg.com.eg', 2063562286,
    'Talaat Moustafa Group Holding is one of the largest real estate developers in Egypt.'
),
(
    'COMI', 'Commercial International Bank', 'البنك التجاري الدولي', 'Banks', 'comi_candles', 'EGS60121C018', 
    'https://drive.google.com/uc?export=view&id=1yidPsldOPlXn6TRRX-bWJfFTliAXaK5Z', 
    '1995-01-02', 'https://www.cibeg.com', 3019080000,
    'Commercial International Bank (CIB) is the leading private sector bank in Egypt.'
),
(
    'FWRY', 'Fawry', 'فوري لتكنولوجيا البنوك', 'Technology', 'fwry_candles', 'EGS745L1C014', 
    'https://drive.google.com/uc?export=view&id=1vmLYAgQ7uLJvJDKhje3Jj83b9mmXjgK9', 
    '2019-08-08', 'https://fawry.com', 1709625000,
    'Fawry is the leading digital transformation and e-payments platform in Egypt.'
),
(
    'ABUK', 'Abu Qir Fertilizers', 'أبوقير للأسمدة', 'Basic Resources', 'abuk_candles', 'EGS38191C010', 
    'https://drive.google.com/uc?export=view&id=11aUTCcmxssUxs56faoeHGg8EZVLzFkCu', 
    '1994-09-27', 'https://abuqir.com', 1261875000,
    'Abu Qir Fertilizers and Chemicals Industries is one of the largest producers of nitrogenous fertilizers.'
),
(
    'EAST', 'Eastern Company', 'ايسترن كومباني', 'Food, Beverage & Tobacco', 'east_candles', 'EGS30221C013', 
    'https://t3.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=http://easternegypt.com&size=256', 
    '1995-09-27', 'https://www.easternegypt.com', 2230000000,
    'Eastern Company is the dominant manufacturer of tobacco products in Egypt.'
),
(
    'EFIH', 'e-finance', 'إي فاينانس', 'Non-bank Financial Services', 'efih_candles', 'EGS74051C018', 
    'https://drive.google.com/uc?export=view&id=1ZSuiEyPAiI5ZslIrDxkj1hTl7TlhU6r9', 
    '2021-10-20', 'https://efinanceinvestment.com', 1848888889,
    'e-finance is a leading developer of digital payments infrastructures.'
),
(
    'EMFD', 'Emaar Misr', 'إعمار مصر', 'Real Estate', 'emfd_candles', 'EGS65901C018', 
    'https://drive.google.com/uc?export=view&id=1ngj6WCwdjORsJ0Nv6J7nIVytqRXz1SVC', 
    '2015-07-05', 'https://www.emaarmisr.com', 4800000000,
    'Emaar Misr is a leading real estate developer known for its prestigious communities.'
),
(
    'ETEL', 'Telecom Egypt (WE)', 'المصرية للاتصالات', 'Telecommunications', 'etel_candles', 'EGS48031C016', 
    'https://drive.google.com/uc?export=view&id=1Yboxs11RmdHvN1bOCBUE_IVbegWsqtV4', 
    '2005-12-14', 'https://www.te.eg', 1707071600,
    'Telecom Egypt is the primary telephone company in Egypt (WE).'
),
(
    'EXPA', 'EBank', 'البنك المصري لتنمية الصادرات', 'Banks', 'expa_candles', 'EGS60281C019', 
    'https://drive.google.com/uc?export=view&id=1z5QABqMt19GP2LUBftW7WissKJa40cUt', 
    '1984-02-01', 'https://ebank.com.eg', 527360000,
    'EBank (Export Development Bank of Egypt) supports exporters.'
),
(
    'HRHO', 'EFG Holding', 'مجموعة إي إف جي القابضة', 'Non-bank Financial Services', 'hrho_candles', 'EGS69161C011', 
    'https://drive.google.com/uc?export=view&id=1VYhM7DyJfN5nQIqLyl4Og4hU3wwbOr0h', 
    '1999-02-17', 'https://www.efgholding.com', 1458537000,
    'EFG Holding is a leading financial services corporation.'
),
(
    'IRON', 'Ezz Steel', 'حديد عز', 'Basic Resources', 'iron_candles', 'EGS3A221C013', 
    'https://drive.google.com/uc?export=view&id=1eCPaTzcY2c_RQktqtT2rp8ICQ1y4mE8t', 
    '1999-05-23', 'https://www.ezzsteel.com', 543265000,
    'Ezz Steel is the largest independent steel producer in the Middle East.'
),
(
    'ORAS', 'Orascom Construction', 'أوراسكوم كونستراكشون', 'Construction & Materials', 'oras_candles', 'EGS95001C011', 
    'https://drive.google.com/uc?export=view&id=1eCPaTzcY2c_RQktqtT2rp8ICQ1y4mE8t', 
    '2015-03-11', 'https://www.orascom.com', 116761379,
    'Orascom Construction is a leading global engineering and construction contractor.'
),
(
    'SWDY', 'Elsewedy Electric', 'السويدي إليكتريك', 'Industrial Goods', 'swdy_candles', 'EGS3G0Z1C014', 
    'https://drive.google.com/uc?export=view&id=1Rgb46jgX3l9pAt3VB-kFi3-zIdoumwxZ', 
    '2006-05-24', 'https://www.elsewedyelectric.com', 2184180000,
    'Elsewedy Electric is a global leader in integrated energy solutions.'
);

INSERT INTO stocks (
    symbol, company_name_en, company_name_ar, sector, description, total_shares, prev_close, isin_code, logo_url, listing_date, website, candle_table_name
) VALUES (
    'GOLD', 'Gold Spot / Egyptian Market', 'الذهب - السوق المصري والعالمي', 'Commodities', 
    'تتبع حي لأسعار الذهب العالمية والمحلية.', 0, 0, 'XAU-EGP', 
    'https://drive.google.com/uc?export=view&id=1G3bTw96_-DN0CgMGBAQcIYRhrpioxeaV', 
    '2025-01-01', 'https://goldprice.org', 'gold_candles'
);

-- ==========================================
-- 7. الدوال (Smart Functions / RPCs) 🧠
-- ==========================================
CREATE OR REPLACE FUNCTION get_chart_history(
    target_symbol TEXT,
    before_date TIMESTAMPTZ DEFAULT NULL,
    limit_count INT DEFAULT 100
)
RETURNS TABLE (
    candle_time TIMESTAMPTZ,
    open FLOAT4,
    high FLOAT4,
    low FLOAT4,
    close FLOAT4,
    volume BIGINT,
    res VARCHAR(5)
) LANGUAGE plpgsql AS $$
DECLARE
    target_table TEXT;
    query_date TIMESTAMPTZ;
BEGIN
    SELECT candle_table_name INTO target_table
    FROM stocks
    WHERE symbol = target_symbol;

    IF target_table IS NULL THEN
        RETURN;
    END IF;

    IF before_date IS NULL THEN
        query_date := NOW() + INTERVAL '100 years';
    ELSE
        query_date := before_date;
    END IF;

    RETURN QUERY EXECUTE format('
        WITH latest_data AS (
            SELECT timestamp, open, high, low, close, volume, timeframe
            FROM %I
            WHERE timestamp < %L
            ORDER BY timestamp DESC
            LIMIT %s
        )
        SELECT timestamp AS candle_time, open, high, low, close, volume, timeframe AS res
        FROM latest_data
        ORDER BY timestamp ASC;
    ', target_table, query_date, limit_count);
END;
$$;

CREATE OR REPLACE FUNCTION get_gold_chart_data(
    days_limit INT DEFAULT 1,
    res_filter VARCHAR DEFAULT '1d'
)
RETURNS TABLE (
    candle_time TIMESTAMPTZ,
    open NUMERIC,
    high NUMERIC,
    low NUMERIC,
    close NUMERIC,
    vol NUMERIC
) LANGUAGE plpgsql AS $$
BEGIN
    RETURN QUERY 
    SELECT 
        timestamp AS candle_time, 
        open, high, low, close, 
        0::numeric AS vol 
    FROM gold_candles
    WHERE timestamp >= NOW() - (days_limit || ' days')::INTERVAL
    AND timeframe = res_filter
    ORDER BY timestamp ASC;
END;
$$;

-- ==========================================
-- 8. تفعيل الأمان (RLS Security) 🔒
-- ==========================================
ALTER TABLE stocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_news ENABLE ROW LEVEL SECURITY;
ALTER TABLE stock_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE gold_prices ENABLE ROW LEVEL SECURITY;
ALTER TABLE gold_candles ENABLE ROW LEVEL SECURITY;

ALTER TABLE tmgh_candles ENABLE ROW LEVEL SECURITY;
ALTER TABLE comi_candles ENABLE ROW LEVEL SECURITY;
ALTER TABLE fwry_candles ENABLE ROW LEVEL SECURITY;
ALTER TABLE abuk_candles ENABLE ROW LEVEL SECURITY;
ALTER TABLE east_candles ENABLE ROW LEVEL SECURITY;
ALTER TABLE efih_candles ENABLE ROW LEVEL SECURITY;
ALTER TABLE emfd_candles ENABLE ROW LEVEL SECURITY;
ALTER TABLE etel_candles ENABLE ROW LEVEL SECURITY;
ALTER TABLE expa_candles ENABLE ROW LEVEL SECURITY;
ALTER TABLE hrho_candles ENABLE ROW LEVEL SECURITY;
ALTER TABLE iron_candles ENABLE ROW LEVEL SECURITY;
ALTER TABLE oras_candles ENABLE ROW LEVEL SECURITY;
ALTER TABLE swdy_candles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public Read Stocks" ON stocks FOR SELECT USING (true);
CREATE POLICY "Public Read News" ON stock_news FOR SELECT USING (true);
CREATE POLICY "Public Read Messages" ON stock_messages FOR SELECT USING (true);
CREATE POLICY "Public Read Gold" ON gold_prices FOR SELECT USING (true);
CREATE POLICY "Public Read Gold Candles" ON gold_candles FOR SELECT USING (true);

CREATE POLICY "Public Read TMGH" ON tmgh_candles FOR SELECT USING (true);
CREATE POLICY "Public Read COMI" ON comi_candles FOR SELECT USING (true);
CREATE POLICY "Public Read FWRY" ON fwry_candles FOR SELECT USING (true);
CREATE POLICY "Public Read ABUK" ON abuk_candles FOR SELECT USING (true);
CREATE POLICY "Public Read EAST" ON east_candles FOR SELECT USING (true);
CREATE POLICY "Public Read EFIH" ON efih_candles FOR SELECT USING (true);
CREATE POLICY "Public Read EMFD" ON emfd_candles FOR SELECT USING (true);
CREATE POLICY "Public Read ETEL" ON etel_candles FOR SELECT USING (true);
CREATE POLICY "Public Read EXPA" ON expa_candles FOR SELECT USING (true);
CREATE POLICY "Public Read HRHO" ON hrho_candles FOR SELECT USING (true);
CREATE POLICY "Public Read IRON" ON iron_candles FOR SELECT USING (true);
CREATE POLICY "Public Read ORAS" ON oras_candles FOR SELECT USING (true);
CREATE POLICY "Public Read SWDY" ON swdy_candles FOR SELECT USING (true);

CREATE POLICY "Auth Insert Messages" ON stock_messages FOR INSERT TO authenticated WITH CHECK (true);

-- ==========================================
-- 9. تعطيل RLS للرفع (مؤقت) 🔓
-- ==========================================
-- هذا الجزء ضروري عشان كود البايثون يقدر يرفع من غير مفتاح Service Role لو لسه مستخدم Anon
-- (الأفضل تستخدم Service Role Key في بايثون وتسيب السطور دي ممسوحة، بس هسيبها لك للأمان)
ALTER TABLE tmgh_candles DISABLE ROW LEVEL SECURITY;
ALTER TABLE comi_candles DISABLE ROW LEVEL SECURITY;
ALTER TABLE fwry_candles DISABLE ROW LEVEL SECURITY;
ALTER TABLE abuk_candles DISABLE ROW LEVEL SECURITY;
ALTER TABLE east_candles DISABLE ROW LEVEL SECURITY;
ALTER TABLE efih_candles DISABLE ROW LEVEL SECURITY;
ALTER TABLE emfd_candles DISABLE ROW LEVEL SECURITY;
ALTER TABLE etel_candles DISABLE ROW LEVEL SECURITY;
ALTER TABLE expa_candles DISABLE ROW LEVEL SECURITY;
ALTER TABLE hrho_candles DISABLE ROW LEVEL SECURITY;
ALTER TABLE iron_candles DISABLE ROW LEVEL SECURITY;
ALTER TABLE oras_candles DISABLE ROW LEVEL SECURITY;
ALTER TABLE swdy_candles DISABLE ROW LEVEL SECURITY;
ALTER TABLE gold_candles DISABLE ROW LEVEL SECURITY;

-- تعطيل الحماية عن جدول الأخبار عشان السكربت يقدر يكتب فيه
ALTER TABLE stock_news DISABLE ROW LEVEL SECURITY;

ALTER TABLE gold_prices DISABLE ROW LEVEL SECURITY;
ALTER TABLE stocks DISABLE ROW LEVEL SECURITY;

-- ==========================================
-- CRYPTO CURRENCIES
-- ==========================================
-- 1. حذف الكريبتو القديم لتجنب التكرار
DELETE FROM stocks WHERE sector = 'Crypto';

-- 2. إضافة الـ 10 عملات بالوصف الإنجليزي المفصل
INSERT INTO stocks (
    symbol, company_name_en, company_name_ar, sector, candle_table_name, 
    logo_url, website, description, 
    listing_date, total_shares, isin_code
) VALUES 
(
    'BTC', 'Bitcoin', 'بيتكوين', 'Crypto', 'API', 
    'https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Bitcoin.svg/1200px-Bitcoin.svg.png',
    'https://bitcoin.org',
    'Bitcoin is the first decentralized cryptocurrency, often referred to as "digital gold". It operates on a peer-to-peer network without any central authority, serving as a global store of value and a hedge against inflation.',
    '2009-01-03', 21000000, 'CRYPTO-BTC'
),
(
    'ETH', 'Ethereum', 'إيثيريوم', 'Crypto', 'API', 
    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Ethereum-icon-purple.svg/1200px-Ethereum-icon-purple.svg.png',
    'https://ethereum.org',
    'Ethereum is the leading programmable blockchain platform. It enables developers to build decentralized applications (dApps) and smart contracts, serving as the foundation for Decentralized Finance (DeFi) and NFTs.',
    '2015-07-30', 120000000, 'CRYPTO-ETH'
),
(
    'SOL', 'Solana', 'سولانا', 'Crypto', 'API', 
    'https://cryptologos.cc/logos/solana-sol-logo.png',
    'https://solana.com',
    'Solana is a high-performance blockchain supporting builders around the world to create crypto apps that scale today. It is known for its incredibly fast transaction speeds and extremely low fees compared to Ethereum.',
    '2020-03-16', 570000000, 'CRYPTO-SOL'
),
(
    'XRP', 'Ripple', 'ريبل', 'Crypto', 'API', 
    'https://cryptologos.cc/logos/xrp-xrp-logo.png',
    'https://ripple.com',
    'XRP is a digital asset built for global payments. It offers financial institutions a fast, reliable, and cost-effective option for cross-border transactions, bridging the gap between traditional finance and crypto.',
    '2012-06-02', 100000000000, 'CRYPTO-XRP'
),
(
    'DOGE', 'Dogecoin', 'دوج كوين', 'Crypto', 'API', 
    'https://cryptologos.cc/logos/dogecoin-doge-logo.png',
    'https://dogecoin.com',
    'Dogecoin is an open-source peer-to-peer digital currency. Originally created as a meme, it has evolved into a popular cryptocurrency used for micro-transactions, tipping, and supported by a vibrant community.',
    '2013-12-06', 140000000000, 'CRYPTO-DOGE'
),
(
    'BNB', 'Binance Coin', 'باينانس كوين', 'Crypto', 'API', 
    'https://cryptologos.cc/logos/bnb-bnb-logo.png',
    'https://www.binance.com',
    'BNB is the native utility token of the Binance ecosystem. It powers the Binance Smart Chain and is used to pay for transaction fees on the Binance exchange and various decentralized applications.',
    '2017-07-08', 145000000, 'CRYPTO-BNB'
),
(
    'ADA', 'Cardano', 'كاردانو', 'Crypto', 'API', 
    'https://cryptologos.cc/logos/cardano-ada-logo.png',
    'https://cardano.org',
    'Cardano is a proof-of-stake blockchain platform: the first to be founded on peer-reviewed research and developed through evidence-based methods. It aims to provide a more secure and scalable infrastructure.',
    '2017-09-23', 45000000000, 'CRYPTO-ADA'
),
(
    'AVAX', 'Avalanche', 'أفالانش', 'Crypto', 'API', 
    'https://cryptologos.cc/logos/avalanche-avax-logo.png',
    'https://www.avax.network',
    'Avalanche is a future-proof blockchain built to scale. It is an open, programmable smart contracts platform for decentralized applications, offering near-instant transaction finality.',
    '2020-09-21', 720000000, 'CRYPTO-AVAX'
),
(
    'DOT', 'Polkadot', 'بولكادوت', 'Crypto', 'API', 
    'https://cryptologos.cc/logos/polkadot-new-dot-logo.png',
    'https://polkadot.network',
    'Polkadot is a multichain protocol that connects and secures a network of specialized blockchains, facilitating the cross-chain transfer of any data or asset types, not just tokens.',
    '2020-05-26', 1300000000, 'CRYPTO-DOT'
),
(
    'LINK', 'Chainlink', 'تشين لينك', 'Crypto', 'API', 
    'https://cryptologos.cc/logos/chainlink-link-logo.png',
    'https://chain.link',
    'Chainlink is a decentralized oracle network. It enables smart contracts on any blockchain to securely connect to real-world data, events, and payments, expanding the capabilities of blockchain technology.',
    '2017-09-19', 1000000000, 'CRYPTO-LINK'
);


-- ==========================================
-- EGYPTIAN MARKET INDICES (EGX30 & EGX70)
-- ==========================================
-- إضافة البيانات الكاملة والحقيقية للمؤشرات المصرية (EGX30 & EGX70) مع روابط الصور الجديدة
INSERT INTO stocks (
    symbol, 
    company_name_en, 
    company_name_ar, 
    sector, 
    description, 
    total_shares, 
    prev_close, 
    isin_code, 
    logo_url, 
    listing_date, 
    website, 
    candle_table_name
) VALUES 
(
    'EGX30', 
    'EGX 30 Index', 
    'مؤشر إي جي إكس 30', 
    'Indices', 
    'The main benchmark index of the Egyptian Exchange, tracking the top 30 companies by liquidity and market cap. --split-- COMI,TMGH,FWRY,ABUK,EAST,EFIH,EMFD,ETEL,EXPA,HRHO,IRON,ORAS,SWDY,EKHO,JUFO,MFOT,MNHD,OCDI,PHDC,HELI,ADIB,SKPC,ESRS,BTEL,CLHO,RMDA,MOIL,MICH,DSCW,MTIE', 
    0, 
    41102.8, 
    'INDEX-EGX30', 
    'https://drive.google.com/uc?export=view&id=1a7Ig_mpMm3MhFHy8KFdNXXdEECr3M-W9',
    '1998-01-01', 
    'https://www.egx.com.eg', 
    'egx30_candles'
),
(
    'EGX70', 
    'EGX 70 EWI', 
    'مؤشر إي جي إكس 70', 
    'Indices', 
    'Tracking the performance of 70 small and medium-sized companies in the Egyptian market using equal weighting. --split-- AMOC,EGAL,NCGC,ISPH,PORT,CCAP,BINV,ACGC,AFMC,AJWA,ALCN,ALRE,AMIA,ARCC,ASPI,ATQA,BRAI,CANA,COPR,DAPH,DGTW,EDBM,EFTG,EGCH,EGSA,EITP,ELSH,ENGC,EPCO,EPHI,EQDP,ERAS,ESGI,GGCC,GTHE,GTUN,IFAP,KRDI,LCSW,MCQE,MEPA,MGED,MILS,MPRC,MTIE,NAHO,NEDA,ODIN,OLFI,PRDC,PRMH,RAYA,REAC,RKHT,SAUD,SDTI,SMPP,SPMD,UEGC,UNRE,UPMS,UTAD,VERT,WAPH,ZMID', 
    0, 
    0.0, 
    'INDEX-EGX70', 
    'https://drive.google.com/uc?export=view&id=1jlrG1Z8s9-pRT7NN9Uod61JSnIDT0jnW',
    '2009-03-01', 
    'https://www.egx.com.eg', 
    'egx70ewi_candles'
);

-- 1. جدول بيانات مؤشر EGX30
CREATE TABLE egx30_candles (
    timestamp TIMESTAMPTZ NOT NULL,
    open FLOAT4,
    high FLOAT4,
    low FLOAT4,
    close FLOAT4, -- هنا يتم تخزين "نقاط المؤشر" بدل السعر
    volume BIGINT,
    timeframe VARCHAR(5) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (timestamp, timeframe)
);

-- 2. جدول بيانات مؤشر EGX70
CREATE TABLE egx70ewi_candles (
    timestamp TIMESTAMPTZ NOT NULL,
    open FLOAT4,
    high FLOAT4,
    low FLOAT4,
    close FLOAT4,
    volume BIGINT,
    timeframe VARCHAR(5) NOT NULL,  
    created_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (timestamp, timeframe)
);

ALTER TABLE egx30_candles DISABLE ROW LEVEL SECURITY;
ALTER TABLE egx70ewi_candles DISABLE ROW LEVEL SECURITY;


-- ==============================================================================
-- SOCIAL FEATURES (Profiles, Posts, Comments, Follows, Bookmarks, Watchlist)
-- ==============================================================================

-- A. Profiles
create table if not exists public.profiles (
  id uuid references auth.users on delete cascade not null primary key,
  email varchar(255) unique not null,
  name varchar(255),
  avatar_url varchar(255),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  updated_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- B. Follows
create table public.follows (
  follower_id uuid references public.profiles(id) on delete cascade not null,
  following_id uuid references public.profiles(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (follower_id, following_id),
  constraint cant_follow_self check (follower_id != following_id)
);

-- C. Watchlist (Stocks)
create table public.user_watchlist (
  user_id uuid references public.profiles(id) on delete cascade not null,
  stock_symbol text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (user_id, stock_symbol)
);

-- D. Posts (شامل Sentiment & Cashtags)
create table public.posts (
  id bigint generated by default as identity primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  content text,
  image_url text,
  sentiment varchar(10) check (sentiment in ('bullish', 'bearish')), 
  cashtags text[], 
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- E. Post Votes (Likes)
create table public.post_votes (
  user_id uuid references public.profiles(id) on delete cascade not null,
  post_id bigint references public.posts(id) on delete cascade not null,
  vote_type int not null check (vote_type in (1, -1)),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (user_id, post_id)
);

-- F. Bookmarks (Saved Posts)
create table public.bookmarks (
  user_id uuid references public.profiles(id) on delete cascade not null,
  post_id bigint references public.posts(id) on delete cascade not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (user_id, post_id)
);

-- G. Comments (تدعم الردود parent_id)
create table public.comments (
  id bigint generated by default as identity primary key,
  user_id uuid references public.profiles(id) on delete cascade not null,
  post_id bigint references public.posts(id) on delete cascade not null,
  parent_id bigint references public.comments(id) on delete cascade,
  content text not null,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- H. Comment Votes (Likes on Comments)
create table public.comment_votes (
  user_id uuid references public.profiles(id) on delete cascade not null,
  comment_id bigint references public.comments(id) on delete cascade not null,
  vote_type int not null check (vote_type in (1, -1)),
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  primary key (user_id, comment_id)
);


-- ==============================================================================
-- VIEWS (للعرض العام)
-- ==============================================================================

create or replace view posts_view as
select 
  p.id, p.user_id, p.content, p.image_url, p.created_at, p.sentiment, p.cashtags,
  pr.name as user_name, pr.avatar_url as user_avatar,
  (select count(*) from public.post_votes v where v.post_id = p.id and v.vote_type = 1) as likes_count,
  (select count(*) from public.post_votes v where v.post_id = p.id and v.vote_type = -1) as dislikes_count,
  (select count(*) from public.comments c where c.post_id = p.id) as comments_count
from public.posts p
left join public.profiles pr on p.user_id = pr.id;

create or replace view comments_full_view as
select 
  c.id, c.post_id, c.parent_id, c.content, c.created_at, c.user_id,
  pr.name as user_name, pr.avatar_url as user_avatar,
  (select count(*) from public.comment_votes cv where cv.comment_id = c.id and cv.vote_type = 1) as likes_count,
  (select count(*) from public.comment_votes cv where cv.comment_id = c.id and cv.vote_type = -1) as dislikes_count
from public.comments c
left join public.profiles pr on c.user_id = pr.id
order by c.created_at asc;


-- ==============================================================================
-- سياسات الحماية (RLS Policies)
-- ==============================================================================

-- تفعيل RLS
alter table public.profiles enable row level security;
alter table public.posts enable row level security;
alter table public.comments enable row level security;
alter table public.follows enable row level security;
alter table public.post_votes enable row level security;
alter table public.comment_votes enable row level security;
alter table public.bookmarks enable row level security;
alter table public.user_watchlist enable row level security;

-- حذف السياسات القديمة (Safe Cleaning)
do $$ begin
  drop policy if exists "Public profiles viewable" on profiles;
  drop policy if exists "Users update own" on profiles;
  drop policy if exists "Public posts viewable" on posts;
  drop policy if exists "Users insert own posts" on posts;
  drop policy if exists "Users delete own posts" on posts;
  drop policy if exists "Public comments viewable" on comments;
  drop policy if exists "Users insert own comments" on comments;
  drop policy if exists "Users delete own comments" on comments;
  drop policy if exists "Public votes viewable" on post_votes;
  drop policy if exists "Users vote posts" on post_votes;
  drop policy if exists "Users unvote posts" on post_votes;
  drop policy if exists "Public comment votes viewable" on comment_votes;
  drop policy if exists "Users vote comments" on comment_votes;
  drop policy if exists "Users unvote comments" on comment_votes;
  drop policy if exists "Public follows viewable" on follows;
  drop policy if exists "Users follow" on follows;
  drop policy if exists "Users unfollow" on follows;
  drop policy if exists "Users view own bookmarks" on bookmarks;
  drop policy if exists "Users bookmark posts" on bookmarks;
  drop policy if exists "Users remove bookmark" on bookmarks;
  drop policy if exists "Users view own watchlist" on user_watchlist;
  drop policy if exists "Users add to watchlist" on user_watchlist;
  drop policy if exists "Users remove from watchlist" on user_watchlist;
end $$;

-- إعادة إنشاء السياسات
create policy "Public profiles viewable" on profiles for select using (true);
create policy "Users update own" on profiles for update using (auth.uid() = id);

create policy "Public posts viewable" on posts for select using (true);
create policy "Users insert own posts" on posts for insert with check (auth.uid() = user_id);
create policy "Users delete own posts" on posts for delete using (auth.uid() = user_id);

create policy "Public comments viewable" on comments for select using (true);
create policy "Users insert own comments" on comments for insert with check (auth.uid() = user_id);
create policy "Users delete own comments" on comments for delete using (auth.uid() = user_id);

create policy "Public votes viewable" on post_votes for select using (true);
create policy "Users vote posts" on post_votes for insert with check (auth.uid() = user_id);
create policy "Users unvote posts" on post_votes for delete using (auth.uid() = user_id);

create policy "Public comment votes viewable" on comment_votes for select using (true);
create policy "Users vote comments" on comment_votes for insert with check (auth.uid() = user_id);
create policy "Users unvote comments" on comment_votes for delete using (auth.uid() = user_id);

create policy "Public follows viewable" on follows for select using (true);
create policy "Users follow" on follows for insert with check (auth.uid() = follower_id);
create policy "Users unfollow" on follows for delete using (auth.uid() = follower_id);

create policy "Users view own bookmarks" on bookmarks for select using (auth.uid() = user_id);
create policy "Users bookmark posts" on bookmarks for insert with check (auth.uid() = user_id);
create policy "Users remove bookmark" on bookmarks for delete using (auth.uid() = user_id);

create policy "Users view own watchlist" on user_watchlist for select using (auth.uid() = user_id);
create policy "Users add to watchlist" on user_watchlist for insert with check (auth.uid() = user_id);
create policy "Users remove from watchlist" on user_watchlist for delete using (auth.uid() = user_id);


-- ==============================================================================
-- الدوال الذكية (RPC Functions) - الأهم للتطبيق
-- ==============================================================================

DROP FUNCTION IF EXISTS get_posts_with_status;

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

-- B. جلب الكومنتات مع حالة اللايك واسم الشخص المردود عليه (لصفحة التفاصيل)
create or replace function get_comments_with_status(viewer_id uuid, target_post_id bigint)
returns table (
  id bigint, post_id bigint, parent_id bigint, content text, created_at timestamptz,
  user_id uuid, user_name text, user_avatar text,
  likes_count bigint, dislikes_count bigint,
  user_vote_type int, parent_username text
) 
language plpgsql as $$
begin
  return query
  select 
    c.id, c.post_id, c.parent_id, c.content, c.created_at, c.user_id,
    pr.name::text, pr.avatar_url::text,
    (select count(*) from public.comment_votes cv where cv.comment_id = c.id and cv.vote_type = 1),
    (select count(*) from public.comment_votes cv where cv.comment_id = c.id and cv.vote_type = -1),
    (select vote_type from public.comment_votes cv where cv.comment_id = c.id and cv.user_id = viewer_id),
    (select p2.name::text from public.comments c2 join public.profiles p2 on c2.user_id = p2.id where c2.id = c.parent_id)
  from public.comments c
  left join public.profiles pr on c.user_id = pr.id
  where c.post_id = target_post_id
  order by c.created_at asc;
end;
$$;

-- C. تريجر إنشاء البروفايل (لليوزرات الجدد)
create or replace function public.handle_new_user() 
returns trigger as $$
begin
  insert into public.profiles (id, email, name, avatar_url)
  values (
    new.id, 
    new.email, 
    -- محاولة جلب الاسم (لو ملقاش name يدور على full_name)
    coalesce(new.raw_user_meta_data->>'name', new.raw_user_meta_data->>'full_name', new.email),
    -- هنا التعديل: جلب الصورة من avatar_url أو picture
    coalesce(new.raw_user_meta_data->>'avatar_url', new.raw_user_meta_data->>'picture')
  );
  return new;
end;
$$ language plpgsql security definer;

-- التأكد من إن التريجر شغال
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();




-- إضافة الأعمدة الجديدة لجدول stocks
ALTER TABLE stocks 
ADD COLUMN current_price FLOAT4 DEFAULT 0.0,
ADD COLUMN change_percent FLOAT4 DEFAULT 0.0;

-- ==============================================================================
-- END OF SCHEMA
-- ==============================================================================
