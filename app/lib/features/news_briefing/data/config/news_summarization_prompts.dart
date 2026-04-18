class NewsSummarizationPrompts {
  /// System prompt for English content
  static const String systemPromptEnglish =
      'You are a financial news analyst. Create a cohesive, '
      'narrative summary that synthesizes the key information from '
      'multiple news articles. DO NOT list articles separately or use '
      'numbering. Instead, weave the information together into a '
      'flowing paragraph that highlights the main themes, market trends, '
      'and important developments. Keep it under 150 words and focus on '
      'what investors need to know.';

  /// System prompt for Arabic content
  static const String systemPromptArabic =
      'أنت محلل أخبار مالية. اكتب ملخصاً متماسكاً يجمع المعلومات الرئيسية من '
      'عدة مقالات إخبارية. لا تقم بسرد المقالات بشكل منفصل أو استخدام الترقيم. '
      'بدلاً من ذلك، اجمع المعلومات معاً في فقرة متدفقة تسلط الضوء على المواضيع '
      'الرئيسية واتجاهات السوق والتطورات المهمة. اجعل الملخص أقل من 150 كلمة '
      'وركز على ما يحتاج المستثمرون إلى معرفته.';

  /// User prompt for English content
  static const String userPromptEnglish =
      'Analyze and synthesize these news articles into a single '
      'cohesive summary:';

  /// User prompt for Arabic content
  static const String userPromptArabic =
      'قم بتحليل ودمج هذه المقالات الإخبارية في ملخص واحد متماسك:';

  /// Temperature setting for AI responses (controls randomness)
  static const double temperature = 0.3;

  /// Maximum tokens for AI response
  static const int maxTokens = 300;

  /// Maximum characters for input content to avoid context length errors
  /// Cerebras limit is 8192 tokens, keeping safe margin
  static const int maxInputCharacters = 30000;

  /// Detect if content is primarily Arabic
  static bool isArabicContent(String content) {
    // Count Arabic characters
    final arabicChars = RegExp(r'[\u0600-\u06FF]').allMatches(content).length;
    // Count English characters
    final englishChars = RegExp(r'[a-zA-Z]').allMatches(content).length;

    // If we have more Arabic than English characters, consider it Arabic
    return arabicChars > englishChars;
  }

  /// Get appropriate prompts based on content language
  static Map<String, String> getPromptsForContent(String content) {
    final isArabic = isArabicContent(content);

    return {
      'systemPrompt': isArabic ? systemPromptArabic : systemPromptEnglish,
      'userPrompt': isArabic ? userPromptArabic : userPromptEnglish,
    };
  }
}
