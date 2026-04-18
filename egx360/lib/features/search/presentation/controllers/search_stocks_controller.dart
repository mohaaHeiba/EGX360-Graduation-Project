import 'dart:async';
import 'package:egx/features/search/data/datasources/search_remote_datasource.dart';
import 'package:egx/features/search/data/repositories/search_repository_impl.dart';
import 'package:egx/features/search/domain/entities/news_entity.dart';
import 'package:egx/features/search/domain/entities/stock_entity.dart';
import 'package:egx/features/search/domain/usecases/get_initial_stocks_usecase.dart';
import 'package:egx/features/search/domain/usecases/get_latest_news_usecase.dart';
import 'package:egx/features/search/domain/usecases/search_stocks_usecase.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:supabase_flutter/supabase_flutter.dart';

class SearchStocksController extends GetxController {
  // Dependencies
  late final SearchStocksUseCase searchStocksUseCase;
  late final GetInitialStocksUseCase getInitialStocksUseCase;
  late final GetLatestNewsUseCase getLatestNewsUseCase;

  var searchResults = <StockEntity>[].obs;
  var initialPicks = <StockEntity>[].obs;
  var latestNews = <NewsEntity>[].obs;
  var allNews = <NewsEntity>[].obs; // For All News Page
  final ScrollController scrollController = ScrollController();
  int newsPage = 0;
  final int newsLimit = 10;
  var hasMoreNews = true.obs;
  var isLoadingMoreNews = false.obs;

  // Stocks Pagination
  final ScrollController searchPageScrollController = ScrollController();
  int stocksPage = 0;
  final int stocksLimit = 10;
  var hasMoreStocks = true.obs;
  var isLoadingMoreStocks = false.obs;

  var selectedCategory = 'All'.obs;
  var isLoading = false.obs;
  var isLoadingAllNews = false.obs; // Loading state for initial load
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;

  late stt.SpeechToText _speech;
  var isListening = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize dependencies (In a real app, use Bindings)
    final supabase = Supabase.instance.client;
    final remoteDataSource = SearchRemoteDataSourceImpl(supabase);
    final repository = SearchRepositoryImpl(remoteDataSource);

    searchStocksUseCase = SearchStocksUseCase(repository);
    getInitialStocksUseCase = GetInitialStocksUseCase(repository);
    getLatestNewsUseCase = GetLatestNewsUseCase(repository);

    fetchStocks();
    fetchLatestNews();
    _speech = stt.SpeechToText();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        fetchAllNews();
      }
    });

    searchPageScrollController.addListener(() {
      if (searchPageScrollController.position.pixels >=
          searchPageScrollController.position.maxScrollExtent - 200) {
        if (selectedCategory.value == 'Stocks') {
          fetchStocks();
        }
      }
    });
  }

  Future<void> fetchLatestNews() async {
    try {
      final news = await getLatestNewsUseCase(category: selectedCategory.value);
      latestNews.value = news;
    } catch (e) {
      print('Error fetching news: $e');
    }
  }

  Future<void> fetchAllNews({bool refresh = false}) async {
    if (refresh) {
      newsPage = 0;
      hasMoreNews.value = true;
      allNews.clear();
      isLoadingAllNews.value = true;
    } else {
      if (!hasMoreNews.value || isLoadingMoreNews.value) return;
      isLoadingMoreNews.value = true;
    }

    try {
      final news = await getLatestNewsUseCase(
        category: selectedCategory.value,
        limit: newsLimit,
        offset: newsPage * newsLimit,
      );

      if (news.length < newsLimit) {
        hasMoreNews.value = false;
      }

      if (refresh) {
        allNews.assignAll(news);
      } else {
        allNews.addAll(news);
      }

      newsPage++;
    } catch (e) {
      print('Error fetching all news: $e');
    } finally {
      isLoadingAllNews.value = false;
      isLoadingMoreNews.value = false;
    }
  }

  void setCategory(String category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;

    if (searchController.text.isNotEmpty) {
      searchStocks(searchController.text);
    } else {
      fetchStocks(refresh: true);
    }

    // Only fetch news if NOT in 'Stocks' category (or if we want to keep fetching it in background, but user said hide it)
    // For now, we can still fetch it, but UI will hide it. Or we can skip fetching.
    // Let's fetch it to be safe, unless we want to optimize.
    // User said "dont add in it news", so we can skip fetching if category is Stocks.
    if (selectedCategory.value != 'Stocks') {
      fetchLatestNews();
    }
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        searchStocks(query);
      } else {
        fetchStocks();
      }
    });
  }

  Future<void> searchStocks(String query) async {
    isLoading.value = true;
    try {
      final results = await searchStocksUseCase(
        query,
        category: selectedCategory.value,
      );
      searchResults.value = results;
    } catch (e) {
      print('Search Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStocks({bool refresh = false}) async {
    if (selectedCategory.value == 'Stocks') {
      // Pagination Logic for 'Stocks' category
      if (refresh) {
        stocksPage = 0;
        hasMoreStocks.value = true;
        initialPicks.clear();
        isLoading.value = true;
      } else {
        if (!hasMoreStocks.value || isLoadingMoreStocks.value) return;
        isLoadingMoreStocks.value = true;
      }

      try {
        final stocks = await getInitialStocksUseCase(
          category: selectedCategory.value,
          limit: stocksLimit,
          offset: stocksPage * stocksLimit,
        );

        if (stocks.length < stocksLimit) {
          hasMoreStocks.value = false;
        }

        if (refresh) {
          initialPicks.assignAll(stocks);
        } else {
          initialPicks.addAll(stocks);
        }

        stocksPage++;
      } catch (e) {
        print('Fetch Error: $e');
      } finally {
        isLoading.value = false;
        isLoadingMoreStocks.value = false;
      }
    } else if (selectedCategory.value == 'Crypto') {
      // Crypto: Fetch ALL (no pagination)
      isLoading.value = true;
      try {
        final stocks = await getInitialStocksUseCase(
          category: selectedCategory.value,
          limit: 100, // Large limit to get all cryptos
        );

        if (searchController.text.isEmpty) {
          initialPicks.value = stocks;
        }
      } catch (e) {
        print('Fetch Error: $e');
      } finally {
        isLoading.value = false;
      }
    } else if (selectedCategory.value == 'Indices') {
      // Indices: Fetch ALL (no pagination, small list)
      isLoading.value = true;
      try {
        final stocks = await getInitialStocksUseCase(
          category: selectedCategory.value,
          limit: 20, // Sufficient for indices
        );

        if (searchController.text.isEmpty) {
          initialPicks.value = stocks;
        }
      } catch (e) {
        print('Fetch Error: $e');
      } finally {
        isLoading.value = false;
      }
    } else if (selectedCategory.value == 'Currencies') {
      // Currencies: Fetch ALL (no pagination, fixed list of 10)
      isLoading.value = true;
      try {
        final stocks = await getInitialStocksUseCase(
          category: selectedCategory.value,
          limit: 10,
        );

        if (searchController.text.isEmpty) {
          initialPicks.value = stocks;
        }
      } catch (e) {
        print('Fetch Error: $e');
      } finally {
        isLoading.value = false;
      }
    } else {
      // Default behavior for other categories (e.g., All, Gold) - just fetch top 5
      isLoading.value = true;
      try {
        final stocks = await getInitialStocksUseCase(
          category: selectedCategory.value,
          limit: 5, // Default limit
        );

        if (searchController.text.isEmpty) {
          initialPicks.value = stocks;
        }
      } catch (e) {
        print('Fetch Error: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    searchController.dispose();
    scrollController.dispose();
    searchPageScrollController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  void listen() async {
    if (isListening.value) {
      isListening.value = false;
      _speech.stop();
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (val) {
        print('onStatus: $val');
        if (val == 'done' || val == 'notListening') {
          isListening.value = false;
        }
      },
      onError: (val) {
        print('onError: $val');
        isListening.value = false;
      },
    );

    if (available) {
      isListening.value = true;
      _speech.listen(
        onResult: (val) {
          searchController.text = val.recognizedWords;
          if (val.finalResult) {
            isListening.value = false;
            searchStocks(val.recognizedWords);
          }
        },
        cancelOnError: true,
      );
    }
  }
}
