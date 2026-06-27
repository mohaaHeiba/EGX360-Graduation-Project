-- ============================================================
-- US Stocks & Index Funds/ETFs — Finnhub + Massive/Polygon Hybrid
-- candle_table_name = 'API_FINNHUB'  → triggers UsStocksRemoteDataSource
-- sector = 'US Stocks' | 'US ETFs'   → proper category filtering & AssetType routing
-- 35 entries total
-- ============================================================

-- ─── Index Funds & ETFs (sector = 'US ETFs') ────────────────────────────────

INSERT INTO public.stocks (symbol, company_name_en, company_name_ar, sector, candle_table_name, isin_code, logo_url, listing_date, website, description) VALUES
('SPY','SPDR S&P 500 ETF Trust','صندوق إس آند بي 500','US ETFs','API_FINNHUB','US78462F1030','https://upload.wikimedia.org/wikipedia/commons/thumb/6/69/S%26P_Global_Logo.svg/1200px-S%26P_Global_Logo.svg.png','1993-01-22','https://www.ssga.com/us/en/intermediary/etfs/funds/spdr-sp-500-etf-trust-spy','The largest and most liquid ETF tracking the S&P 500 index.'),
('QQQ','Invesco QQQ Trust','صندوق كيو كيو كيو ناسداك','US ETFs','API_FINNHUB','US46090E1038','https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/Invesco_logo.svg/1200px-Invesco_logo.svg.png','1999-03-10','https://www.invesco.com/qqq-etf/en/home.html','ETF tracking the Nasdaq-100 Index of top non-financial companies.'),
('DIA','SPDR Dow Jones Industrial Average ETF','صندوق داو جونز الصناعي','US ETFs','API_FINNHUB','US78467X1090','https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Dow_Jones_Industrial_Average_logo.svg/1200px-Dow_Jones_Industrial_Average_logo.svg.png','1998-01-14','https://www.ssga.com/us/en/intermediary/etfs/funds/spdr-dow-jones-industrial-average-etf-trust-dia','ETF tracking the Dow Jones Industrial Average of 30 blue-chip US stocks.'),
('IWM','iShares Russell 2000 ETF','صندوق آي شيرز راسل 2000','US ETFs','API_FINNHUB','US4642876555','https://upload.wikimedia.org/wikipedia/commons/thumb/0/0a/BlackRock_wordmark.svg/1200px-BlackRock_wordmark.svg.png','2000-05-22','https://www.ishares.com/us/products/239710/ishares-russell-2000-etf','ETF tracking the Russell 2000 index of US small-cap stocks.'),
('VTI','Vanguard Total Stock Market ETF','صندوق فانغارد للسوق الكلي','US ETFs','API_FINNHUB','US9229087690','https://upload.wikimedia.org/wikipedia/commons/thumb/7/70/Vanguard_Logo.svg/1200px-Vanguard_Logo.svg.png','2001-05-24','https://investor.vanguard.com/investment-products/etfs/profile/vti','ETF providing exposure to the entire US equity market.')
ON CONFLICT (symbol) DO NOTHING;

-- ─── Magnificent 7 / Mega-Cap Tech (sector = 'US Stocks') ───────────────────

INSERT INTO public.stocks (symbol, company_name_en, company_name_ar, sector, candle_table_name, isin_code, logo_url, listing_date, website, description) VALUES
('AAPL','Apple Inc.','أبل','US Stocks','API_FINNHUB','US0378331005','https://upload.wikimedia.org/wikipedia/commons/thumb/f/fa/Apple_logo_black.svg/800px-Apple_logo_black.svg.png','1980-12-12','https://www.apple.com','Consumer electronics giant; maker of iPhone, Mac, and services ecosystem.'),
('MSFT','Microsoft Corporation','مايكروسوفت','US Stocks','API_FINNHUB','US5949181045','https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Microsoft_logo.svg/1200px-Microsoft_logo.svg.png','1986-03-13','https://www.microsoft.com','Global software leader in cloud (Azure), productivity, and AI.'),
('GOOGL','Alphabet Inc.','ألفابت (جوجل)','US Stocks','API_FINNHUB','US02079K3059','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Google_2015_logo.svg/1200px-Google_2015_logo.svg.png','2004-08-19','https://abc.xyz','Parent company of Google; dominates search, ads, cloud, and AI.'),
('AMZN','Amazon.com Inc.','أمازون','US Stocks','API_FINNHUB','US0231351067','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a9/Amazon_logo.svg/1200px-Amazon_logo.svg.png','1997-05-15','https://www.amazon.com','E-commerce and cloud computing giant; leader in AWS.'),
('NVDA','NVIDIA Corporation','إنفيديا','US Stocks','API_FINNHUB','US67066G1040','https://upload.wikimedia.org/wikipedia/sco/thumb/2/21/Nvidia_logo.svg/1200px-Nvidia_logo.svg.png','1999-01-22','https://www.nvidia.com','Leading designer of GPUs; dominant force in AI hardware.'),
('META','Meta Platforms Inc.','ميتا (فيسبوك)','US Stocks','API_FINNHUB','US30303M1027','https://upload.wikimedia.org/wikipedia/commons/thumb/7/7b/Meta_Platforms_Inc._logo.svg/1200px-Meta_Platforms_Inc._logo.svg.png','2012-05-18','https://about.meta.com','Social media conglomerate; Facebook, Instagram, WhatsApp, Reality Labs.'),
('TSLA','Tesla Inc.','تيسلا','US Stocks','API_FINNHUB','US88160R1014','https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Tesla_Motors.svg/800px-Tesla_Motors.svg.png','2010-06-29','https://www.tesla.com','Electric vehicle and clean energy company led by Elon Musk.')
ON CONFLICT (symbol) DO NOTHING;

-- ─── Large-Cap Tech & Software (sector = 'US Stocks') ───────────────────────

INSERT INTO public.stocks (symbol, company_name_en, company_name_ar, sector, candle_table_name, isin_code, logo_url, listing_date, website, description) VALUES
('CRM','Salesforce Inc.','سيلزفورس','US Stocks','API_FINNHUB','US79466L3024','https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Salesforce.com_logo.svg/1200px-Salesforce.com_logo.svg.png','2004-06-23','https://www.salesforce.com','Leading cloud-based CRM platform for enterprise sales and marketing.'),
('ORCL','Oracle Corporation','أوراكل','US Stocks','API_FINNHUB','US68389X1054','https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/Oracle_logo.svg/1200px-Oracle_logo.svg.png','1986-03-12','https://www.oracle.com','Enterprise software and cloud infrastructure provider.'),
('ADBE','Adobe Inc.','أدوبي','US Stocks','API_FINNHUB','US00724F1012','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Adobe_Corporate_Logo.svg/1200px-Adobe_Corporate_Logo.svg.png','1986-08-20','https://www.adobe.com','Creative and document software leader; Photoshop, Premiere, Acrobat.'),
('AMD','Advanced Micro Devices','إي إم دي','US Stocks','API_FINNHUB','US0079031078','https://upload.wikimedia.org/wikipedia/commons/thumb/7/7c/AMD_Logo.svg/1200px-AMD_Logo.svg.png','1972-09-27','https://www.amd.com','Semiconductor company competing in CPUs and GPUs for data centers and gaming.'),
('INTC','Intel Corporation','إنتل','US Stocks','API_FINNHUB','US4581401001','https://upload.wikimedia.org/wikipedia/commons/thumb/7/7d/Intel_logo_%282006-2020%29.svg/1200px-Intel_logo_%282006-2020%29.svg.png','1971-10-13','https://www.intel.com','Historic semiconductor manufacturer for CPUs and foundry services.'),
('NFLX','Netflix Inc.','نتفليكس','US Stocks','API_FINNHUB','US64110L1061','https://upload.wikimedia.org/wikipedia/commons/thumb/0/08/Netflix_2015_logo.svg/1200px-Netflix_2015_logo.svg.png','2002-05-23','https://www.netflix.com','Global streaming entertainment service with original content.')
ON CONFLICT (symbol) DO NOTHING;

-- ─── Financials (sector = 'US Stocks') ──────────────────────────────────────

INSERT INTO public.stocks (symbol, company_name_en, company_name_ar, sector, candle_table_name, isin_code, logo_url, listing_date, website, description) VALUES
('JPM','JPMorgan Chase & Co.','جي بي مورغان تشيس','US Stocks','API_FINNHUB','US46625H1005','https://upload.wikimedia.org/wikipedia/commons/thumb/a/af/J.P._Morgan_Logo_2008_1.svg/1200px-J.P._Morgan_Logo_2008_1.svg.png','1969-03-05','https://www.jpmorganchase.com','Largest US bank by assets; investment banking, asset management.'),
('V','Visa Inc.','فيزا','US Stocks','API_FINNHUB','US92826C8394','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Visa_Inc._logo.svg/1200px-Visa_Inc._logo.svg.png','2008-03-19','https://www.visa.com','Global payments technology company processing billions of transactions.'),
('MA','Mastercard Incorporated','ماستركارد','US Stocks','API_FINNHUB','US57636Q1040','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Mastercard-logo.svg/1200px-Mastercard-logo.svg.png','2006-05-25','https://www.mastercard.com','Global payment network connecting consumers, businesses, and governments.'),
('GS','Goldman Sachs Group','غولدمان ساكس','US Stocks','API_FINNHUB','US38141G1040','https://upload.wikimedia.org/wikipedia/commons/thumb/6/61/Goldman_Sachs.svg/1200px-Goldman_Sachs.svg.png','1999-05-04','https://www.goldmansachs.com','Leading global investment banking and financial services firm.')
ON CONFLICT (symbol) DO NOTHING;

-- ─── Healthcare & Pharma (sector = 'US Stocks') ─────────────────────────────

INSERT INTO public.stocks (symbol, company_name_en, company_name_ar, sector, candle_table_name, isin_code, logo_url, listing_date, website, description) VALUES
('JNJ','Johnson & Johnson','جونسون آند جونسون','US Stocks','API_FINNHUB','US4781601046','https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Johnson_and_Johnson_Logo.svg/1200px-Johnson_and_Johnson_Logo.svg.png','1944-01-01','https://www.jnj.com','Diversified healthcare conglomerate; pharma, medical devices.'),
('UNH','UnitedHealth Group','يونايتد هيلث غروب','US Stocks','API_FINNHUB','US91324P1021','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/UnitedHealth_Group_logo.svg/1200px-UnitedHealth_Group_logo.svg.png','1984-10-17','https://www.unitedhealthgroup.com','Largest US health insurer and healthcare services company.'),
('LLY','Eli Lilly and Company','إيلي ليلي','US Stocks','API_FINNHUB','US5324571083','https://upload.wikimedia.org/wikipedia/commons/thumb/2/2b/Eli_Lilly_and_Company.svg/1200px-Eli_Lilly_and_Company.svg.png','1952-01-01','https://www.lilly.com','Major pharmaceutical company; leading in diabetes and obesity drugs.'),
('PFE','Pfizer Inc.','فايزر','US Stocks','API_FINNHUB','US7170811035','https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Pfizer_logo.svg/1200px-Pfizer_logo.svg.png','1944-01-01','https://www.pfizer.com','Global pharmaceutical company with broad therapeutic portfolio.')
ON CONFLICT (symbol) DO NOTHING;

-- ─── Consumer & Retail (sector = 'US Stocks') ───────────────────────────────

INSERT INTO public.stocks (symbol, company_name_en, company_name_ar, sector, candle_table_name, isin_code, logo_url, listing_date, website, description) VALUES
('WMT','Walmart Inc.','وول مارت','US Stocks','API_FINNHUB','US9311421039','https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Walmart_logo.svg/1200px-Walmart_logo.svg.png','1972-08-25','https://www.walmart.com','World largest retailer operating hypermarkets and e-commerce.'),
('KO','The Coca-Cola Company','كوكا كولا','US Stocks','API_FINNHUB','US1912161007','https://upload.wikimedia.org/wikipedia/commons/thumb/c/ce/Coca-Cola_logo.svg/1200px-Coca-Cola_logo.svg.png','1919-09-05','https://www.coca-colacompany.com','Iconic global beverage company with 200+ brands.'),
('DIS','The Walt Disney Company','ديزني','US Stocks','API_FINNHUB','US2546871060','https://upload.wikimedia.org/wikipedia/commons/thumb/3/36/Disney_logo.svg/1200px-Disney_logo.svg.png','1957-11-12','https://thewaltdisneycompany.com','Global entertainment conglomerate; theme parks, streaming, studios.')
ON CONFLICT (symbol) DO NOTHING;

-- ─── Energy (sector = 'US Stocks') ──────────────────────────────────────────

INSERT INTO public.stocks (symbol, company_name_en, company_name_ar, sector, candle_table_name, isin_code, logo_url, listing_date, website, description) VALUES
('XOM','Exxon Mobil Corporation','إكسون موبيل','US Stocks','API_FINNHUB','US30231G1022','https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/ExxonMobil.svg/1200px-ExxonMobil.svg.png','1920-01-01','https://corporate.exxonmobil.com','Largest publicly traded oil and gas company by revenue.'),
('CVX','Chevron Corporation','شيفرون','US Stocks','API_FINNHUB','US1667641005','https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Chevron_Logo.svg/1200px-Chevron_Logo.svg.png','1921-06-01','https://www.chevron.com','Integrated energy company in oil, gas, and renewable energy.')
ON CONFLICT (symbol) DO NOTHING;

-- ─── Aerospace & Defense (sector = 'US Stocks') ─────────────────────────────

INSERT INTO public.stocks (symbol, company_name_en, company_name_ar, sector, candle_table_name, isin_code, logo_url, listing_date, website, description) VALUES
('BA','The Boeing Company','بوينغ','US Stocks','API_FINNHUB','US0970231058','https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/Boeing_full_logo.svg/1200px-Boeing_full_logo.svg.png','1962-01-02','https://www.boeing.com','Aerospace manufacturer of commercial jets and defense systems.'),
('LMT','Lockheed Martin Corporation','لوكهيد مارتن','US Stocks','API_FINNHUB','US5398301094','https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/Lockheed_Martin_logo.svg/1200px-Lockheed_Martin_logo.svg.png','1995-03-15','https://www.lockheedmartin.com','Global defense and aerospace company; F-35, space systems.')
ON CONFLICT (symbol) DO NOTHING;

-- ─── Telecom (sector = 'US Stocks') ─────────────────────────────────────────

INSERT INTO public.stocks (symbol, company_name_en, company_name_ar, sector, candle_table_name, isin_code, logo_url, listing_date, website, description) VALUES
('T','AT&T Inc.','إيه تي آند تي','US Stocks','API_FINNHUB','US00206R1023','https://upload.wikimedia.org/wikipedia/commons/thumb/3/31/AT%26T_logo_2016.svg/1200px-AT%26T_logo_2016.svg.png','1984-01-01','https://www.att.com','Major US telecommunications and media conglomerate.')
ON CONFLICT (symbol) DO NOTHING;
