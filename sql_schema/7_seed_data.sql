-- ==============================================================================
-- 7. STOCK & CRYPTO DATA (Seed Data)
-- ==============================================================================

-- Egyptian stocks
INSERT INTO public.stocks (symbol, company_name_en, company_name_ar, sector, candle_table_name, isin_code, logo_url, listing_date, website, total_shares, description) VALUES
('TMGH','Talaat Moustafa Group','مجموعة طلعت مصطفى','Real Estate','tmgh_candles','EGS65001C013','https://drive.google.com/uc?export=view&id=1uUYqPlcZK4wmb-CO62mS-sYwYYNWmBoU','2007-11-01','https://www.tmg.com.eg',2063562286,'One of the largest real estate developers in Egypt.'),
('COMI','Commercial International Bank','البنك التجاري الدولي','Banks','comi_candles','EGS60121C018','https://drive.google.com/uc?export=view&id=1yidPsldOPlXn6TRRX-bWJfFTliAXaK5Z','1995-01-02','https://www.cibeg.com',3019080000,'The leading private sector bank in Egypt.'),
('FWRY','Fawry','فوري لتكنولوجيا البنوك','Technology','fwry_candles','EGS745L1C014','https://drive.google.com/uc?export=view&id=1vmLYAgQ7uLJvJDKhje3Jj83b9mmXjgK9','2019-08-08','https://fawry.com',1709625000,'The leading e-payments platform in Egypt.'),
('ABUK','Abu Qir Fertilizers','أبوقير للأسمدة','Basic Resources','abuk_candles','EGS38191C010','https://drive.google.com/uc?export=view&id=11aUTCcmxssUxs56faoeHGg8EZVLzFkCu','1994-09-27','https://abuqir.com',1261875000,'One of the largest nitrogenous fertilizer producers.'),
('EAST','Eastern Company','ايسترن كومباني','Food, Beverage & Tobacco','east_candles','EGS30221C013','https://t3.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON&fallback_opts=TYPE,SIZE,URL&url=http://easternegypt.com&size=256','1995-09-27','https://www.easternegypt.com',2230000000,'Dominant manufacturer of tobacco products in Egypt.'),
('EFIH','e-finance','إي فاينانس','Non-bank Financial Services','efih_candles','EGS74051C018','https://drive.google.com/uc?export=view&id=1ZSuiEyPAiI5ZslIrDxkj1hTl7TlhU6r9','2021-10-20','https://efinanceinvestment.com',1848888889,'Leading developer of digital payments infrastructure.'),
('EMFD','Emaar Misr','إعمار مصر','Real Estate','emfd_candles','EGS65901C018','https://drive.google.com/uc?export=view&id=1ngj6WCwdjORsJ0Nv6J7nIVytqRXz1SVC','2015-07-05','https://www.emaarmisr.com',4800000000,'Leading real estate developer of prestigious communities.'),
('ETEL','Telecom Egypt (WE)','المصرية للاتصالات','Telecommunications','etel_candles','EGS48031C016','https://drive.google.com/uc?export=view&id=1Yboxs11RmdHvN1bOCBUE_IVbegWsqtV4','2005-12-14','https://www.te.eg',1707071600,'Primary telephone company in Egypt (WE).'),
('EXPA','EBank','البنك المصري لتنمية الصادرات','Banks','expa_candles','EGS60281C019','https://drive.google.com/uc?export=view&id=1z5QABqMt19GP2LUBftW7WissKJa40cUt','1984-02-01','https://ebank.com.eg',527360000,'Export Development Bank of Egypt.'),
('HRHO','EFG Holding','مجموعة إي إف جي القابضة','Non-bank Financial Services','hrho_candles','EGS69161C011','https://drive.google.com/uc?export=view&id=1VYhM7DyJfN5nQIqLyl4Og4hU3wwbOr0h','1999-02-17','https://www.efgholding.com',1458537000,'Leading financial services corporation.'),
('IRON','Ezz Steel','حديد عز','Basic Resources','iron_candles','EGS3A221C013','https://drive.google.com/uc?export=view&id=1eCPaTzcY2c_RQktqtT2rp8ICQ1y4mE8t','1999-05-23','https://www.ezzsteel.com',543265000,'Largest independent steel producer in the Middle East.'),
('ORAS','Orascom Construction','أوراسكوم كونستراكشون','Construction & Materials','oras_candles','EGS95001C011','https://drive.google.com/uc?export=view&id=1eCPaTzcY2c_RQktqtT2rp8ICQ1y4mE8t','2015-03-11','https://www.orascom.com',116761379,'Leading global engineering and construction contractor.'),
('SWDY','Elsewedy Electric','السويدي إليكتريك','Industrial Goods','swdy_candles','EGS3G0Z1C014','https://drive.google.com/uc?export=view&id=1Rgb46jgX3l9pAt3VB-kFi3-zIdoumwxZ','2006-05-24','https://www.elsewedyelectric.com',2184180000,'Global leader in integrated energy solutions.'),
('CLHO','Cleopatra Hospitals','مستشفيات كليوباترا','Healthcare','clho_candles','EGS330R1C018','https://www.cleopatrahospitals.com/images/logo.png','2016-06-02','https://www.cleopatrahospitals.com',NULL,'Largest private hospital group in Egypt.'),
('ISPH','Ibnsina Pharma','ابن سينا فارما','Healthcare','isph_candles','EGS384A1C013','https://ibnsina-pharma.com/wp-content/uploads/2019/12/logo.png','2017-12-12','https://ibnsina-pharma.com',NULL,'One of the largest pharmaceutical distributors in Egypt.'),
('SKPC','Sidi Kerir Petrochemicals','سيدي كرير للبتروكيماويات','Petrochemicals','skpc_candles','EGS38201C017','https://www.sidpec.com/images/logo.png','2005-01-01','https://www.sidpec.com',NULL,'Leader in petrochemicals and plastics production.'),
('AMOC','Alexandria Mineral Oils','الإسكندرية للزيوت المعدنية','Petrochemicals','amoc_candles','EGS380S1C017','https://amoc.com.eg/images/logo.png','2004-09-22','https://amoc.com.eg',NULL,'Specialised in mineral oils and wax production.'),
('ALCN','Alexandria Containers','الإسكندرية لتداول الحاويات','Logistics','alcn_candles','EGS420H1C013','https://www.alexcont.com/images/logo.png','1995-08-01','https://www.alexcont.com',NULL,'Main container terminal at Alexandria Port.'),
('CIRA','CIRA Education','سيرا للتعليم','Education','cira_candles','EGS401W1C015','https://cira.com.eg/wp-content/uploads/2021/04/Cira-Logo.png','2018-10-01','https://cira.com.eg',NULL,'Largest private education services company.'),
('ORWE','Oriental Weavers','النساجون الشرقيون','Consumer Goods','orwe_candles','EGS32041C012','https://www.orientalweavers.com/wp-content/uploads/2016/10/logo.png','1997-09-24','https://www.orientalweavers.com',NULL,'Largest mechanical carpet producer in the world.'),
('JUFO','Juhayna Food Industries','جهينة للصناعات الغذائية','Food & Beverage','jufo_candles','EGS30901C010','https://www.juhayna.com/wp-content/uploads/2020/09/Juhayna-Logo.png','2010-06-15','https://www.juhayna.com',NULL,'Leader in dairy and juice production in Egypt.'),
('EFID','Edita Food Industries','إيديتا للصناعات الغذائية','Food & Beverage','efid_candles','EGS306S1C011','https://edita.com.eg/wp-content/uploads/2016/12/logo-edita.png','2015-04-16','https://edita.com.eg',NULL,'Leader in baked goods and snacks.'),
('PHDC','Palm Hills Developments','بالم هيلز للتعمير','Real Estate','phdc_candles','EGS65591C015','https://palmhillsdevelopments.com/assets/images/logo.png','2008-04-16','https://palmhillsdevelopments.com',NULL,'Leading real estate and commercial developer.'),
('ADIB','Abu Dhabi Islamic Bank','مصرف أبو ظبي الإسلامي','Banks','adib_candles','EGS60041C018','https://www.adib.eg/images/logo.png','1999-01-01','https://www.adib.eg',NULL,'Leading Islamic banking services.'),
('CCAP','Qalaa Holdings','القلعة للاستشارات المالية','Non-bank Financial Services','ccap_candles','EGS69081C018','https://www.qalaaholdings.com/images/logo.png','2009-12-23','https://www.qalaaholdings.com',NULL,'Direct investment in infrastructure and industry.'),
('RAYA','Raya Holding','راية القابضة للاستثمارات','Technology','raya_candles','EGS69061C010','https://www.rayacorp.com/wp-content/uploads/2018/02/raya-logo.png','2005-05-18','https://www.rayacorp.com',NULL,'IT, contact centres, and manufacturing.'),
('OIH','Orascom Investment','أوراسكوم للاستثمار القابضة','Telecommunications','oih_candles','EGS690A1C011','https://www.orascomih.com/images/logo.png','2011-12-14','https://www.orascomih.com',NULL,'Invests in telecom, media, and technology.'),
('CSAG','Canal Shipping Agencies','القناة للتوكيلات الملاحية','Logistics','csag_candles','EGS42051C013','https://www.csag.com.eg/images/logo.png','1995-07-26','https://www.csag.com.eg',NULL,'Shipping agencies in the Suez Canal zone.'),
('TEEG','Taaleem Management','تعليم لخدمات الإدارة','Education','teeg_candles','EGS402C1C016','https://taaleem.me/wp-content/uploads/2021/04/Taaleem-Logo-1.png','2021-04-07','https://taaleem.me',NULL,'Manages higher education institutions.'),
('DSCW','Dice Sport & Casual Wear','دايس للملابس الجاهزة','Consumer Goods','dscw_candles','EGS330U1C013','https://www.dicefactory.net/assets/images/logo.png','2017-11-08','https://www.dicefactory.net',NULL,'Leading apparel and textiles brand in Egypt.'),
('EGAL','Egypt Aluminum','مصر للألومنيوم','Industrial Goods','egal_candles','EGS3D0C1C016','https://www.egyptalum.com.eg/images/logo.png','1997-07-28','https://www.egyptalum.com.eg',NULL,'Largest aluminum producer in Egypt and the Middle East.'),
('ARCC','Arabian Cement','العربية للأسمنت','Construction & Materials','arcc_candles','EGS3C4H1C013','https://www.arabiancement.com/assets/images/logo.png','2014-05-18','https://www.arabiancement.com',NULL,'Leader in cement and construction materials.')
ON CONFLICT (symbol) DO NOTHING;

-- Indices
INSERT INTO public.stocks (symbol, company_name_en, company_name_ar, sector, candle_table_name, isin_code, logo_url, listing_date, website, prev_close, description) VALUES
('EGX30','EGX 30 Index','مؤشر إي جي إكس 30','Indices','egx30_candles','INDEX-EGX30','https://drive.google.com/uc?export=view&id=1a7Ig_mpMm3MhFHy8KFdNXXdEECr3M-W9','1998-01-01','https://www.egx.com.eg',41102.8,'Main benchmark index tracking top 30 companies.'),
('EGX70','EGX 70 EWI','مؤشر إي جي إكس 70','Indices','egx70ewi_candles','INDEX-EGX70','https://drive.google.com/uc?export=view&id=1jlrG1Z8s9-pRT7NN9Uod61JSnIDT0jnW','2009-03-01','https://www.egx.com.eg',0,'Equal-weighted index of 70 small/mid-cap companies.')
ON CONFLICT (symbol) DO NOTHING;

-- Commodities
INSERT INTO public.stocks (symbol, company_name_en, company_name_ar, sector, candle_table_name, isin_code, logo_url, listing_date, website, description) VALUES
('GOLD','Gold Spot / Egyptian Market','الذهب - السوق المصري والعالمي','Materials','gold_candles','XAU-EGP','https://drive.google.com/uc?export=view&id=1G3bTw96_-DN0CgMGBAQcIYRhrpioxeaV','2025-01-01','https://goldprice.org','Live tracking of international and local gold prices.'),
('SILVER','Silver Local/Global','الفضة - محلي وعالمي','Materials','silver_candles','XAG-EGP','https://drive.google.com/uc?export=view&id=1Lz-f_E_tUjP4o7S0Y3qG7Q-U3X6jVvGz',now(),'https://goldprice.org','Live tracking of silver 999 and 800 prices.')
ON CONFLICT (symbol) DO NOTHING;

-- Cryptocurrencies
INSERT INTO public.stocks (symbol, company_name_en, company_name_ar, sector, candle_table_name, isin_code, logo_url, listing_date, website, description) VALUES
('BTC','Bitcoin','بيتكوين','Crypto','API','CRYPTO-BTC','https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Bitcoin.svg/1200px-Bitcoin.svg.png','2009-01-03','https://bitcoin.org','The first decentralized cryptocurrency, known as digital gold.'),
('ETH','Ethereum','إيثيريوم','Crypto','API','CRYPTO-ETH','https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Ethereum-icon-purple.svg/1200px-Ethereum-icon-purple.svg.png','2015-07-30','https://ethereum.org','The leading programmable blockchain for DeFi and NFTs.'),
('SOL','Solana','سولانا','Crypto','API','CRYPTO-SOL','https://cryptologos.cc/logos/solana-sol-logo.png','2020-03-16','https://solana.com','High-performance blockchain with fast speeds and low fees.'),
('XRP','Ripple','ريبل','Crypto','API','CRYPTO-XRP','https://cryptologos.cc/logos/xrp-xrp-logo.png','2012-06-02','https://ripple.com','Digital asset for fast, low-cost cross-border payments.'),
('DOGE','Dogecoin','دوج كوين','Crypto','API','CRYPTO-DOGE','https://cryptologos.cc/logos/dogecoin-doge-logo.png','2013-12-06','https://dogecoin.com','Meme-origin coin with a vibrant community.'),
('BNB','Binance Coin','باينانس كوين','Crypto','API','CRYPTO-BNB','https://cryptologos.cc/logos/bnb-bnb-logo.png','2017-07-08','https://www.binance.com','Native utility token of the Binance ecosystem.'),
('ADA','Cardano','كاردانو','Crypto','API','CRYPTO-ADA','https://cryptologos.cc/logos/cardano-ada-logo.png','2017-09-23','https://cardano.org','Proof-of-stake blockchain built on peer-reviewed research.'),
('AVAX','Avalanche','أفالانش','Crypto','API','CRYPTO-AVAX','https://cryptologos.cc/logos/avalanche-avax-logo.png','2020-09-21','https://www.avax.network','Scalable smart contracts platform with near-instant finality.'),
('DOT','Polkadot','بولكادوت','Crypto','API','CRYPTO-DOT','https://cryptologos.cc/logos/polkadot-new-dot-logo.png','2020-05-26','https://polkadot.network','Multichain protocol connecting specialized blockchains.'),
('LINK','Chainlink','تشين لينك','Crypto','API','CRYPTO-LINK','https://cryptologos.cc/logos/chainlink-link-logo.png','2017-09-19','https://chain.link','Decentralized oracle network for smart contracts.'),
('SHIB','Shiba Inu','شيبا إينو','Crypto','API','CRYPTO-SHIB','https://cryptologos.cc/logos/shiba-inu-shib-logo.png','2020-08-01','https://shibatoken.com','Meme coin that evolved into a broader ecosystem.'),
('PEPE','Pepe','بيبي','Crypto','API','CRYPTO-PEPE','https://cryptologos.cc/logos/pepe-pepe-logo.png','2023-04-17','https://www.pepe.vip','Deflationary meme coin on Ethereum.'),
('MATIC','Polygon','بوليجون','Crypto','API','CRYPTO-MATIC','https://cryptologos.cc/logos/polygon-matic-logo.png','2017-10-01','https://polygon.technology','Ethereum-compatible Layer 2 scaling network.'),
('LTC','Litecoin','لايت كوين','Crypto','API','CRYPTO-LTC','https://cryptologos.cc/logos/litecoin-ltc-logo.png','2011-10-07','https://litecoin.org','Peer-to-peer crypto often called the silver to Bitcoin.'),
('UNI','Uniswap','يوني سواب','Crypto','API','CRYPTO-UNI','https://cryptologos.cc/logos/uniswap-uni-logo.png','2020-09-17','https://uniswap.org','Leading decentralized trading protocol.'),
('TRX','TRON','ترون','Crypto','API','CRYPTO-TRX','https://cryptologos.cc/logos/tron-trx-logo.png','2017-09-13','https://tron.network','Blockchain-based operating system.'),
('ETC','Ethereum Classic','إيثيريوم كلاسيك','Crypto','API','CRYPTO-ETC','https://cryptologos.cc/logos/ethereum-classic-etc-logo.png','2016-07-20','https://ethereumclassic.org','Original Ethereum chain running smart contracts.'),
('FIL','Filecoin','فايل كوين','Crypto','API','CRYPTO-FIL','https://cryptologos.cc/logos/filecoin-fil-logo.png','2020-10-15','https://filecoin.io','Decentralized storage system.'),
('AAVE','Aave','آف','Crypto','API','CRYPTO-AAVE','https://cryptologos.cc/logos/aave-aave-logo.png','2020-10-02','https://aave.com','Decentralized finance lending protocol.'),
('NEAR','NEAR Protocol','نير بروتوكول','Crypto','API','CRYPTO-NEAR','https://cryptologos.cc/logos/near-protocol-near-logo.png','2020-04-22','https://near.org','Layer-1 blockchain for decentralized applications.'),
('FET','Artificial Superintelligence','الذكاء الاصطناعي الفائق','Crypto','API','CRYPTO-FET','https://cryptologos.cc/logos/fetch-ai-fet-logo.png','2019-02-28','https://fetch.ai','Token powering the Artificial Superintelligence Alliance.'),
('RNDR','Render','رندر','Crypto','API','CRYPTO-RNDR','https://cryptologos.cc/logos/render-rndr-logo.png','2020-06-15','https://render.x.io','Distributed GPU rendering network.'),
('ARB','Arbitrum','أربيتراوم','Crypto','API','CRYPTO-ARB','https://cryptologos.cc/logos/arbitrum-arb-logo.png','2023-03-23','https://arbitrum.io','Layer-2 scaling solution for Ethereum.'),
('APT','Aptos','أبتوس','Crypto','API','CRYPTO-APT','https://cryptologos.cc/logos/aptos-apt-logo.png','2022-10-12','https://aptoslabs.com','Layer-1 Proof-of-Stake blockchain.'),
('ATOM','Cosmos','كوزموس','Crypto','API','CRYPTO-ATOM','https://cryptologos.cc/logos/cosmos-atom-logo.png','2019-03-14','https://cosmos.network','Ecosystem for interoperable blockchain networks.')
ON CONFLICT (symbol) DO NOTHING;

-- Currencies (API-based, no candle table)
INSERT INTO public.stocks (symbol, company_name_en, company_name_ar, sector, candle_table_name, isin_code, logo_url, listing_date, website, description) VALUES
('USDEGP','US Dollar','الدولار الأمريكي','Currencies','API','FX-USD','https://upload.wikimedia.org/wikipedia/commons/thumb/a/a4/Flag_of_the_United_States.svg/1200px-Flag_of_the_United_States.svg.png','1792-04-02','https://www.federalreserve.gov','World reserve currency issued by the Federal Reserve.'),
('EUREGP','Euro','اليورو','Currencies','API','FX-EUR','https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/Flag_of_Europe.svg/1200px-Flag_of_Europe.svg.png','1999-01-01','https://www.ecb.europa.eu','Unified currency of the Eurozone, second most traded globally.'),
('GBPEGP','British Pound','الجنيه الإسترليني','Currencies','API','FX-GBP','https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Flag_of_the_United_Kingdom.svg/1200px-Flag_of_the_United_Kingdom.svg.png','1694-07-27','https://www.bankofengland.co.uk','Oldest currency still in use, issued by the Bank of England.'),
('SAREGP','Saudi Riyal','الريال السعودي','Currencies','API','FX-SAR','https://upload.wikimedia.org/wikipedia/commons/thumb/0/0d/Flag_of_Saudi_Arabia.svg/1200px-Flag_of_Saudi_Arabia.svg.png','1952-10-22','https://www.sama.gov.sa','Saudi Arabia''s official currency, pegged to the USD.'),
('AEDEGP','UAE Dirham','الدرهم الإماراتي','Currencies','API','FX-AED','https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Flag_of_the_United_Arab_Emirates.svg/1200px-Flag_of_the_United_Arab_Emirates.svg.png','1973-05-19','https://www.centralbank.ae','UAE''s official currency, pegged to the USD.'),
('JPYEGP','Japanese Yen','الين الياباني','Currencies','API','FX-JPY','https://upload.wikimedia.org/wikipedia/en/thumb/9/9e/Flag_of_Japan.svg/1200px-Flag_of_Japan.svg.png','1871-05-10','https://www.boj.or.jp/en','Third most traded currency, a traditional safe-haven.'),
('CHFEGP','Swiss Franc','الفرنك السويسري','Currencies','API','FX-CHF','https://upload.wikimedia.org/wikipedia/commons/thumb/f/f3/Flag_of_Switzerland.svg/1024px-Flag_of_Switzerland.svg.png','1850-05-07','https://www.snb.ch','Primary traditional safe-haven currency.'),
('KWDEGP','Kuwaiti Dinar','الدينار الكويتي','Currencies','API','FX-KWD','https://upload.wikimedia.org/wikipedia/commons/thumb/c/cb/Flag_of_Kuwait.svg/1200px-Flag_of_Kuwait.svg.png','1961-04-01','https://www.cbk.gov.kw','Highest-value currency in the world.'),
('QAREGP','Qatari Riyal','الريال القطري','Currencies','API','FX-QAR','https://upload.wikimedia.org/wikipedia/commons/thumb/6/65/Flag_of_Qatar.svg/1200px-Flag_of_Qatar.svg.png','1973-03-21','https://www.qcb.gov.qa','Qatar''s official currency, pegged to the USD.'),
('JODEGP','Jordanian Dinar','الدينار الأردني','Currencies','API','FX-JOD','https://upload.wikimedia.org/wikipedia/commons/thumb/c/c0/Flag_of_Jordan.svg/1200px-Flag_of_Jordan.svg.png','1950-07-01','https://www.cbj.gov.jo','Jordan''s official currency, closely pegged to the USD.')
ON CONFLICT (symbol) DO UPDATE SET
    company_name_en = EXCLUDED.company_name_en,
    company_name_ar = EXCLUDED.company_name_ar,
    website         = EXCLUDED.website,
    listing_date    = EXCLUDED.listing_date,
    description     = EXCLUDED.description;