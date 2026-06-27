# EGX 360 Chatbot (EGX AI)

## Overview
EGX AI is a financial assistant integrated into the EGX 360 trading application. It is designed to help users with:
- Analyzing their portfolio and wallet status.
- Providing market news and community sentiment.
- Predicting stock performance using AI-driven scores.
- Offering investment advice based on user risk tolerance and timeframe.
- Explaining technical indicators (EMA, SMA, RSI, MACD).

## Current Architecture (Refactored)
The chatbot follows **Clean Architecture** principles, decoupling intent detection, data orchestration, and response generation into specialized UseCases.

### How it Works:
1. **User Input:** `ChatbotController` receives a message.
2. **Intent Routing (Hybrid RAG):** `RouteIntentUseCase` uses local heuristics (regex/keywords) and a small zero-shot LLM call to identify what the user needs.
3. **Selective Context Gathering:** `GetContextualDataUseCase` fetches **only** the required data categories (Wallet, News, etc.) in parallel using `Future.wait`.
4. **Dynamic Prompting:** `GenerateChatResponseUseCase` assembles a surgical system prompt using only the retrieved data.
5. **AI Generation:** Sends the optimized prompt to Cerebras AI (`llama3.1-8b`).

## Resolved Problems

### 1. Token Bloat & Context Noise (RESOLVED)
- **Fix:** Implemented selective fetching. If a user asks for news, we no longer fetch their wallet or crypto trends.
- **Impact:** ~70% reduction in tokens per prompt.

### 2. "Fake" RAG Implementation (RESOLVED)
- **Fix:** Replaced hardcoded injection with Intent-Driven retrieval. The LLM only sees data relevant to its specific task.

### 3. Fragile Stock Detection (RESOLVED)
- **Fix:** Improved entity extraction in `RouteIntentUseCase` using an aggressive match against the full asset dictionary.

### 4. Conflicting Implementations (RESOLVED)
- **Fix:** Deleted the monolithic `ChatbotService` and unified all logic under the `domain/` and `data/` Clean Architecture layers.

### 5. Prompt Over-Engineering (RESOLVED)
- **Fix:** Switched from negative constraints ("NEVER...") to positive, task-oriented framing which `llama3.1-8b` handles more reliably.

### 6. Synchronous "Everything" Fetch (RESOLVED)
- **Fix:** Used `Future.wait` for parallel fetching of required chunks only.

### 7. Heavy Computation on Request (RESOLVED)
- **Fix:** Moved technical analysis to pre-calculated database RPCs, eliminating on-the-fly candle processing in the app.

## Recommended Path Forward
1. **Vector Search:** Eventually transition from keyword/intent-based RAG to a full vector-based semantic search if news volume increases significantly.
2. **Streaming:** Implement Time-to-First-Token (TTFT) optimizations by streaming the AI response to the UI.
3. **Advanced Personalization:** Use the `ChatbotContextData` to provide more personalized portfolio alerts and notifications via the chatbot interface.
