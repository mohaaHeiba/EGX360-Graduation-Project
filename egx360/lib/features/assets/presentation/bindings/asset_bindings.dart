import 'package:egx/core/data/init_local_data.dart';
import 'package:egx/core/services/cerebras_ai_service.dart';
import 'package:egx/features/assets/data/datasources/crypto_remote_data_source.dart';
import 'package:egx/features/assets/data/datasources/stock_remote_data_source.dart';
import 'package:egx/features/assets/data/repositories/stock_repository_impl.dart';
import 'package:egx/features/assets/domain/entities/asset_type.dart';
import 'package:egx/features/assets/domain/usecases/get_material_price_usecase.dart';
import 'package:egx/features/assets/domain/usecases/get_stock_candles_usecase.dart';
import 'package:egx/features/assets/domain/usecases/get_stock_news_usecase.dart';
import 'package:egx/features/assets/presentation/controllers/asset_details_controller.dart';
import 'package:egx/features/community/data/datasources/community_remote_data_source.dart';
import 'package:egx/features/community/data/repositories/community_repository_impl.dart';
import 'package:egx/features/community/domain/usecase/get_all_posts_usecase.dart';
import 'package:egx/features/assets/data/repositories/crypto_repository_impl.dart';
import 'package:egx/features/assets/domain/usecases/get_crypto_candles_usecase.dart';
import 'package:egx/features/assets/domain/usecases/get_crypto_ticker_usecase.dart';
import 'package:egx/features/news_briefing/data/datasources/news_briefing_remote_data_source.dart';
import 'package:egx/features/news_briefing/data/repositories/news_briefing_repository_impl.dart';
import 'package:egx/features/news_briefing/domain/usecases/summarize_news_usecase.dart';
import 'package:egx/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:egx/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:egx/features/profile/domain/usecase/interaction_usecases.dart';
import 'package:egx/features/profile/domain/usecase/get_user_profile_usecase.dart';
import 'package:egx/features/search/data/datasources/search_remote_datasource.dart';
import 'package:egx/features/search/data/repositories/search_repository_impl.dart';
import 'package:egx/features/search/domain/usecases/get_latest_news_usecase.dart';
import 'package:egx/features/search/domain/usecases/get_watchlist_status_usecase.dart';
import 'package:egx/features/search/domain/usecases/toggle_watchlist_usecase.dart'
    as watchlist;
import 'package:egx/features/stock_chat/data/datasources/stock_chat_remote_datasource.dart';
import 'package:egx/features/stock_chat/data/repositories/stock_chat_repository_impl.dart';
import 'package:egx/features/stock_chat/domian/usecases/get_chat_stream_usecase.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Unified bindings for all asset types (stocks, crypto, materials, indices)
class AssetBindings extends Bindings {
  @override
  void dependencies() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String stockId = args['id'].toString();
    String symbol = args['symbol'] ?? args['stock_name'] ?? '';

    // Determine asset type from arguments
    AssetType assetType = AssetType.stock; // Default

    if (args.containsKey('asset_type')) {
      // Explicit asset type passed
      final String typeStr = args['asset_type'];
      if (typeStr == 'crypto') {
        assetType = AssetType.crypto;
      } else if (typeStr == 'material') {
        assetType = AssetType.material;
      } else if (typeStr == 'index') {
        assetType = AssetType.marketIndex;
      }
    } else {
      // Infer from symbol or sector
      if (symbol.toUpperCase().contains('GOLD')) {
        symbol = 'GOLD';
        assetType = AssetType.material;
      } else if (symbol.toUpperCase().contains('SILVER')) {
        symbol = 'SILVER';
        assetType = AssetType.material;
      } else if (args['sector'] == 'Indices') {
        assetType = AssetType.marketIndex;
      }
      // If coming from crypto search/navigation, it would have asset_type set
    }

    // Core Dependencies
    final supabase = Supabase.instance.client;
    final localData = Get.find<InitLocalData>();
    final httpClient = http.Client();

    // AI Service for news summarization
    final cerebrasAiService = CerebrasAiService(client: httpClient);

    // Data Sources
    final stockRemoteDataSource = StockRemoteDataSourceImpl(supabase);
    final cryptoRemoteDataSource = CryptoRemoteDataSourceImpl(
      client: httpClient,
    );
    final searchRemoteDataSource = SearchRemoteDataSourceImpl(supabase);
    final communityRemoteDataSource = CommunityRemoteDataSourceImpl(supabase);
    final profileRemoteDataSource = ProfileRemoteDataSourceImpl(supabase);
    final stockChatRemoteDataSource = StockChatRemoteDataSourceImpl(supabase);
    final newsBriefingRemoteDataSource = NewsBriefingRemoteDataSourceImpl(
      cerebrasService: cerebrasAiService,
    );

    // Repositories
    final stockRepository = StockRepositoryImpl(
      remoteDataSource: stockRemoteDataSource,
    );
    final cryptoRepository = CryptoRepositoryImpl(
      remoteDataSource: cryptoRemoteDataSource,
    );
    final searchRepository = SearchRepositoryImpl(searchRemoteDataSource);
    final communityRepository = CommunityRepositoryImpl(
      remoteDataSource: communityRemoteDataSource,
    );
    final profileRepository = ProfileRepositoryImpl(
      remoteDataSource: profileRemoteDataSource,
      localData: localData,
    );
    final stockChatRepository = StockChatRepositoryImpl(
      stockChatRemoteDataSource,
    );
    final newsBriefingRepository = NewsBriefingRepositoryImpl(
      remoteDataSource: newsBriefingRemoteDataSource,
    );

    // Use Cases - Stock/Material/Index specific
    final getStockNewsUseCase = GetStockNewsUseCase(stockRepository);
    final getStockCandlesUseCase = GetStockCandlesUseCase(stockRepository);
    final getMaterialPriceUseCase = GetMaterialPriceUseCase(stockRepository);
    final getLatestNewsUseCase = GetLatestNewsUseCase(searchRepository);

    // Use Cases - Crypto specific
    final getCryptoCandlesUseCase = GetCryptoCandlesUseCase(cryptoRepository);
    final getCryptoTickerUseCase = GetCryptoTickerUseCase(cryptoRepository);

    // Use Cases - Shared
    final getAllPostsUseCase = GetAllPostsUseCase(communityRepository);
    final togglePostVoteUseCase = TogglePostVoteUseCase(profileRepository);
    final toggleBookmarkUseCase = ToggleBookmarkUseCase(profileRepository);
    final toggleWatchlistUseCase = watchlist.ToggleWatchlistUseCase(
      searchRepository,
    );
    final getWatchlistStatusUseCase = GetWatchlistStatusUseCase(
      searchRepository,
    );
    final summarizeNewsUseCase = SummarizeNewsUseCase(newsBriefingRepository);

    // Put use cases in Get for other controllers to find
    Get.put(toggleWatchlistUseCase);
    Get.put(getWatchlistStatusUseCase);
    Get.put(GetChatStreamUseCase(stockChatRepository));
    Get.put(SendMessageUseCase(stockChatRepository));
    Get.put(GetUserProfileUseCase(profileRepository));

    // Create unified controller with appropriate dependencies based on asset type
    Get.put(
      AssetDetailsController(
        stockId: stockId,
        symbol: symbol,
        assetType: assetType,
        // Only pass use cases that are relevant for this asset type
        getStockNewsUseCase: assetType.isCrypto ? null : getStockNewsUseCase,
        getStockCandlesUseCase: assetType.isCrypto
            ? null
            : getStockCandlesUseCase,
        getCryptoCandlesUseCase: assetType.isCrypto
            ? getCryptoCandlesUseCase
            : null,
        getCryptoTickerUseCase: assetType.isCrypto
            ? getCryptoTickerUseCase
            : null,
        getMaterialPriceUseCase: getMaterialPriceUseCase,
        getAllPostsUseCase: getAllPostsUseCase,
        togglePostVoteUseCase: togglePostVoteUseCase,
        toggleBookmarkUseCase: toggleBookmarkUseCase,
        toggleWatchlistUseCase: toggleWatchlistUseCase,
        getWatchlistStatusUseCase: getWatchlistStatusUseCase,
        getLatestNewsUseCase: getLatestNewsUseCase,
        summarizeNewsUseCase: summarizeNewsUseCase,
      ),
    );
  }
}
