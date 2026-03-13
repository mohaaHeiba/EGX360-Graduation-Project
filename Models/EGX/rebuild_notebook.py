"""
Rebuild THE DEEP QUANT MODEL notebook with:
1. Professional dark-theme Plotly visualizations
2. Clean code organization (one purpose per cell)
3. New charts: label distribution, split timeline, confusion matrix, feature importance, signal overlay
"""

import json, uuid, copy

# ---- helpers ----
def md(text):
    return {"cell_type": "markdown", "id": uuid.uuid4().hex[:8], "metadata": {}, "source": [text]}

def code(src, exec_count=None):
    return {"cell_type": "code", "execution_count": exec_count, "id": uuid.uuid4().hex[:8],
            "metadata": {}, "outputs": [], "source": [src]}

# ============================================================
# DARK THEME TEMPLATE (reusable across all plots)
# ============================================================
DARK_THEME_CODE = """
# ─── Global Dark Finance Theme ───────────────────────────────
import plotly.io as pio
import plotly.graph_objects as go
from plotly.subplots import make_subplots

DARK = dict(
    paper_bgcolor='#0d1117',
    plot_bgcolor='#0d1117',
    font=dict(color='#c9d1d9', family='Inter, Arial, sans-serif', size=12),
    xaxis=dict(gridcolor='#21262d', linecolor='#30363d', zeroline=False, showgrid=True),
    yaxis=dict(gridcolor='#21262d', linecolor='#30363d', zeroline=False, showgrid=True),
    legend=dict(bgcolor='#161b22', bordercolor='#30363d', borderwidth=1),
    hoverlabel=dict(bgcolor='#161b22', font_color='#c9d1d9'),
    margin=dict(l=60, r=40, t=70, b=60),
)

INC_COLOR = '#00c58e'  # green for bullish candles
DEC_COLOR = '#ff4757'  # red for bearish candles

def apply_dark(fig, title=''):
    fig.update_layout(title=dict(text=title, font=dict(size=16, color='#58a6ff')), **DARK)
    return fig
"""

# ============================================================
# SECTION 1: RAW CANDLESTICK + VOLUME
# ============================================================
RAW_CHART_CODE = """
# ─── Chart 1: Raw Market Data (Last 150 Days) ────────────────
sample_df = df.tail(150).copy()

fig_raw = make_subplots(
    rows=2, cols=1, shared_xaxes=True,
    row_heights=[0.75, 0.25], vertical_spacing=0.03,
    subplot_titles=('EGX30 Price Action', 'Volume')
)

fig_raw.add_trace(go.Candlestick(
    x=sample_df.index,
    open=sample_df['open'], high=sample_df['high'],
    low=sample_df['low'],   close=sample_df['close'],
    name='EGX30',
    increasing_line_color=INC_COLOR, decreasing_line_color=DEC_COLOR,
    increasing_fillcolor=INC_COLOR, decreasing_fillcolor=DEC_COLOR,
), row=1, col=1)

colors = [INC_COLOR if c >= o else DEC_COLOR
          for c, o in zip(sample_df['close'], sample_df['open'])]
fig_raw.add_trace(go.Bar(
    x=sample_df.index, y=sample_df['volume'],
    marker_color=colors, name='Volume', showlegend=False
), row=2, col=1)

fig_raw.update_layout(
    **DARK,
    title=dict(text='📊 EGX30 — Raw Market Data (Last 150 Days)', font=dict(size=16, color='#58a6ff')),
    xaxis_rangeslider_visible=False, height=600,
)
fig_raw.update_yaxes(gridcolor='#21262d', linecolor='#30363d')
fig_raw.show()
"""

# ============================================================
# SECTION 2: 4-PANEL TECHNICAL DASHBOARD
# ============================================================
TECH_DASHBOARD_CODE = """
# ─── Chart 2: 4-Panel Quant Technical Dashboard ─────────────
sample_df = df.tail(150).copy()

fig_dash = make_subplots(
    rows=4, cols=1, shared_xaxes=True,
    row_heights=[0.45, 0.2, 0.2, 0.15],
    vertical_spacing=0.04,
    subplot_titles=('Price + EMAs', 'RSI (14)', 'MACD Histogram', 'BB Width')
)

# Panel 1: Candlestick + EMAs
fig_dash.add_trace(go.Candlestick(
    x=sample_df.index,
    open=sample_df['open'], high=sample_df['high'],
    low=sample_df['low'],   close=sample_df['close'],
    name='Price',
    increasing_line_color=INC_COLOR, decreasing_line_color=DEC_COLOR,
    increasing_fillcolor=INC_COLOR, decreasing_fillcolor=DEC_COLOR,
), row=1, col=1)

ema_styles = [('EMA_9', '#ffd700', 1.5), ('EMA_21', '#7b68ee', 1.5), ('EMA_50', '#ff6b35', 2)]
for col_name, color, width in ema_styles:
    if col_name in sample_df.columns:
        fig_dash.add_trace(go.Scatter(
            x=sample_df.index, y=sample_df[col_name],
            name=col_name, line=dict(color=color, width=width)
        ), row=1, col=1)

# Panel 2: RSI with overbought/oversold bands
if 'RSI' in sample_df.columns:
    fig_dash.add_trace(go.Scatter(
        x=sample_df.index, y=sample_df['RSI'],
        name='RSI', line=dict(color='#a78bfa', width=1.5), fill='tozeroy',
        fillcolor='rgba(167,139,250,0.1)'
    ), row=2, col=1)
    for level, color in [(70, '#ff4757'), (30, '#00c58e'), (50, '#555')]:
        fig_dash.add_hline(y=level, line=dict(color=color, width=1, dash='dot'), row=2, col=1)

# Panel 3: MACD Histogram
if 'MACD_Hist' in sample_df.columns:
    macd_colors = [INC_COLOR if v >= 0 else DEC_COLOR for v in sample_df['MACD_Hist']]
    fig_dash.add_trace(go.Bar(
        x=sample_df.index, y=sample_df['MACD_Hist'],
        name='MACD Hist', marker_color=macd_colors, showlegend=False
    ), row=3, col=1)

# Panel 4: BB Width
if 'BB_Width' in sample_df.columns:
    fig_dash.add_trace(go.Scatter(
        x=sample_df.index, y=sample_df['BB_Width'],
        name='BB Width', line=dict(color='#38bdf8', width=1.5), fill='tozeroy',
        fillcolor='rgba(56,189,248,0.1)'
    ), row=4, col=1)

fig_dash.update_layout(
    **DARK,
    title=dict(text='📈 EGX30 — Quant Technical Dashboard', font=dict(size=16, color='#58a6ff')),
    xaxis_rangeslider_visible=False, height=850, showlegend=True,
)
fig_dash.update_yaxes(gridcolor='#21262d', linecolor='#30363d')
fig_dash.show()
"""

# ============================================================
# SECTION 3: LABEL / TARGET DISTRIBUTION
# ============================================================
LABEL_DIST_CODE = """
# ─── Chart 3: Target Label Distribution ──────────────────────
label_counts = df['Target'].value_counts().sort_index()
label_names  = {0: '📉 Down Trend', 1: '📈 Up Trend'}
names  = [label_names.get(i, str(i)) for i in label_counts.index]
values = label_counts.values

fig_dist = go.Figure()
bar_colors = [INC_COLOR if n == 1 else DEC_COLOR for n in label_counts.index]

fig_dist.add_trace(go.Bar(
    x=names, y=values,
    marker_color=bar_colors,
    text=[f'{v:,}  ({v/values.sum()*100:.1f}%)' for v in values],
    textposition='outside',
    textfont=dict(color='#c9d1d9'),
    name='Count'
))
apply_dark(fig_dist, '🎯 Target Label Distribution')
fig_dist.update_layout(height=420, showlegend=False,
    yaxis_title='Number of Trading Days', xaxis_title='')
fig_dist.show()

print(f"Class Balance  ▶  Up: {label_counts.get(1,0):,} | Down: {label_counts.get(0,0):,}")
"""

# ============================================================
# SECTION 4: TRAIN/VAL/TEST SPLIT TIMELINE
# ============================================================
SPLIT_VIZ_CODE = """
# ─── Chart 4: Train / Test Split Timeline ────────────────────
split_idx = int(len(X) * 0.80)
train_dates = df.index[:split_idx]
test_dates  = df.index[split_idx:]

fig_split = go.Figure()
fig_split.add_trace(go.Scatter(
    x=train_dates, y=df['close'].iloc[:split_idx],
    name='Train Set', line=dict(color='#38bdf8', width=1.5),
    fill='tozeroy', fillcolor='rgba(56,189,248,0.08)'
))
fig_split.add_trace(go.Scatter(
    x=test_dates, y=df['close'].iloc[split_idx:],
    name='Test Set', line=dict(color='#ffd700', width=1.5),
    fill='tozeroy', fillcolor='rgba(255,215,0,0.08)'
))
fig_split.add_vline(
    x=str(df.index[split_idx]), line_width=2,
    line_dash='dash', line_color='#ff6b35',
    annotation_text='Split Point', annotation_font_color='#ff6b35'
)
apply_dark(fig_split, '📅 Chronological Train / Test Split')
fig_split.update_layout(height=400, yaxis_title='EGX30 Close Price', xaxis_title='Date')
fig_split.show()

print(f"Train: {len(train_dates):,} days ({train_dates[0].date()} → {train_dates[-1].date()})")
print(f"Test:  {len(test_dates):,}  days ({test_dates[0].date()}  → {test_dates[-1].date()})")
"""

# ============================================================
# SECTION 5: CONFUSION MATRIX (dark styled)
# ============================================================
CONF_MATRIX_CODE = """
# ─── Chart 5: Styled Confusion Matrix ────────────────────────
from sklearn.metrics import confusion_matrix
import numpy as np

cm = confusion_matrix(y_test, y_pred)
labels = ['Down (0)', 'Up (1)']

# Annotate with count + %
total = cm.sum()
annot = [[f'{cm[r,c]}<br>{cm[r,c]/total*100:.1f}%' for c in range(cm.shape[1])]
         for r in range(cm.shape[0])]

fig_cm = go.Figure(go.Heatmap(
    z=cm, x=labels, y=labels,
    colorscale=[[0,'#161b22'],[0.5,'#1f4068'],[1,'#0e63a5']],
    text=annot, texttemplate='%{text}',
    textfont=dict(size=16, color='white'),
    showscale=False,
))
fig_cm.update_layout(
    **DARK,
    title=dict(text='🔲 Confusion Matrix — Test Set', font=dict(size=16, color='#58a6ff')),
    xaxis_title='Predicted Label', yaxis_title='True Label',
    height=420, width=520,
)
fig_cm.show()
"""

# ============================================================
# SECTION 6: FEATURE IMPORTANCE
# ============================================================
FEAT_IMP_CODE = """
# ─── Chart 6: Feature Importance ─────────────────────────────
# Extract feature importances from the XGBoost base model
try:
    xgb_model = stack_model.estimators_[0][1]  # first base estimator
    feat_imp = pd.Series(xgb_model.feature_importances_, index=final_features)
    feat_imp = feat_imp.sort_values(ascending=True).tail(20)

    fig_fi = go.Figure(go.Bar(
        x=feat_imp.values, y=feat_imp.index,
        orientation='h',
        marker=dict(
            color=feat_imp.values,
            colorscale=[[0,'#1f4068'],[0.5,'#0e63a5'],[1,'#58a6ff']],
            showscale=False,
        )
    ))
    apply_dark(fig_fi, '🔍 Top Feature Importances (XGBoost)')
    fig_fi.update_layout(height=560, xaxis_title='Importance Score', yaxis_title='',
        margin=dict(l=160, r=40, t=70, b=60))
    fig_fi.show()
except Exception as e:
    print(f"Feature importance not available: {e}")
"""

# ============================================================
# SECTION 7: PREDICTION SIGNAL OVERLAY (full improved version)
# ============================================================
SIGNAL_OVERLAY_CODE = """
# ─── Chart 7: Prediction Signal Overlay ─────────────────────
viz_df = results_df.tail(150).copy()

buy_signals  = viz_df[viz_df['Predicted_Trend'] == 1]
sell_signals = viz_df[viz_df['Predicted_Trend'] == 0]

fig_signals = go.Figure()

# Close Price line
fig_signals.add_trace(go.Scatter(
    x=viz_df['timestamp'], y=viz_df['close'],
    name='Close Price', line=dict(color='#8b9dc3', width=1.5)
))
# EMA_10 Trend Line
if 'EMA_10' in viz_df.columns:
    fig_signals.add_trace(go.Scatter(
        x=viz_df['timestamp'], y=viz_df['EMA_10'],
        name='EMA 10', line=dict(color='#ffd700', width=1.5, dash='dot')
    ))

# Buy Signals
fig_signals.add_trace(go.Scatter(
    x=buy_signals['timestamp'], y=buy_signals['close'],
    mode='markers', name='🟢 Up Signal',
    marker=dict(symbol='triangle-up', size=10, color=INC_COLOR,
                line=dict(color='white', width=0.5))
))
# Sell Signals
fig_signals.add_trace(go.Scatter(
    x=sell_signals['timestamp'], y=sell_signals['close'],
    mode='markers', name='🔴 Down Signal',
    marker=dict(symbol='triangle-down', size=10, color=DEC_COLOR,
                line=dict(color='white', width=0.5))
))

apply_dark(fig_signals, '🚦 EGX360 Model Signals vs Actual Price (Last 150 Test Days)')
fig_signals.update_layout(height=520, xaxis_title='Date', yaxis_title='EGX30 Price')
fig_signals.show()
"""

# ============================================================
# SECTION 8: PORTFOLIO GROWTH CHART (improved)
# ============================================================
PORTFOLIO_CHART_CODE = """
# ─── Chart 8: Portfolio Growth vs Buy & Hold ─────────────────
fig_pf = go.Figure()

fig_pf.add_trace(go.Scatter(
    x=bt_df.index, y=bt_df['portfolio_value'],
    name='🤖 Strategy', line=dict(color=INC_COLOR, width=2),
    fill='tozeroy', fillcolor='rgba(0,197,142,0.07)'
))
fig_pf.add_trace(go.Scatter(
    x=bt_df.index, y=bt_df['bh_value'],
    name='📦 Buy & Hold', line=dict(color='#8b9dc3', width=1.5, dash='dot')
))

apply_dark(fig_pf, '💼 Portfolio Growth: Strategy vs Buy & Hold')
fig_pf.update_layout(height=480, xaxis_title='Date', yaxis_title='Portfolio Value (EGP)')
fig_pf.show()

print(f"\\n{'='*55}")
print(f"  Final Strategy Value : {final_portfolio:>12,.2f} EGP")
print(f"  Final Buy & Hold     : {final_bh:>12,.2f} EGP")
print(f"  Strategy Return      : {strategy_return:>12.2f}%")
print(f"  Buy & Hold Return    : {bh_return:>12.2f}%")
print(f"  Alpha (outperformance): {strategy_return - bh_return:>11.2f}%")
print(f"{'='*55}")
"""

# ============================================================
# BUILD THE NOTEBOOK CELLS
# ============================================================
cells = []

# ─────── TITLE ───────
cells.append(md(
    "# EGX360 — THE DEEP QUANT MODEL\n"
    "### Enhancing Down-Trend Detection & Bias Control · Egyptian Stock Exchange\n"
    "> **Model Accuracy: 89%** | Stacking Ensemble (XGBoost + LightGBM + Logistic Regression)"
))

# ─────── SECTION 1: ENVIRONMENT SETUP ───────
cells.append(md("## 1. Environment Setup & GPU Check"))
cells.append(code(
    "import tensorflow as tf\n"
    "gpu_devices = tf.config.list_physical_devices('GPU')\n"
    "if gpu_devices:\n"
    "    print(f\"✅ GPU found: {gpu_devices}\")\n"
    "else:\n"
    "    print(\"⚠️  No GPU detected — running on CPU.\")"
))
cells.append(code(
    "import pandas as pd\n"
    "import numpy as np\n"
    "import xgboost as xgb\n"
    "import lightgbm as lgb\n"
    "from sklearn.linear_model import LogisticRegression\n"
    "from sklearn.ensemble import StackingClassifier\n"
    "from sklearn.metrics import classification_report, accuracy_score, confusion_matrix\n"
    "from sklearn.preprocessing import StandardScaler\n"
    "import matplotlib.pyplot as plt\n"
    "import seaborn as sns\n"
    "import plotly.graph_objects as go\n"
    "from plotly.subplots import make_subplots\n"
    "import plotly.io as pio\n"
    "import joblib\n"
    "import warnings\n"
    "import os\n"
    "warnings.filterwarnings('ignore')\n"
    "print(\"✅ All libraries loaded.\")"
))
# Dark theme init
cells.append(code(DARK_THEME_CODE))

# ─────── SECTION 2: DATA LOADING ───────
cells.append(md(
    "## 2. Data Loading & Exploration\n"
    "We load the preprocessed EGX30 daily data which includes USD/EGP rates, Gold prices, "
    "and CBE interest rates. Financial time series is inherently noisy — visualizing raw "
    "candlesticks illustrates why we need the quant transformation in Section 3."
))
cells.append(md("### 2.1 Load Core Dataset"))
cells.append(code(
    "print(\"🚀 Loading Dataset (EGX30 + USD + Gold)...\")\n"
    "current_dir = os.getcwd()\n"
    "file_path = os.path.join(current_dir, \"data\", \"EGX30_Final_v9.csv\")\n"
    "df = pd.read_csv(file_path)\n"
    "df['timestamp'] = pd.to_datetime(df['timestamp']).dt.tz_localize(None).dt.normalize()\n"
    "df.set_index('timestamp', inplace=True)\n"
    "print(f\"✅ Loaded {len(df):,} rows × {df.shape[1]} columns\")"
))
cells.append(md("### 2.2 Merge CBE Interest Rates"))
cells.append(code(
    "ir_path = os.path.join(current_dir, \"data\", \"cbe_interest_rate.csv\")\n"
    "if os.path.exists(ir_path):\n"
    "    ir_df = pd.read_csv(ir_path)\n"
    "    ir_df['Date'] = pd.to_datetime(ir_df['Date']).dt.normalize()\n"
    "    ir_df.set_index('Date', inplace=True)\n"
    "    df = df.join(ir_df, how='left')\n"
    "    df['Interest_Rate'] = df['Interest_Rate'].ffill().bfill()\n"
    "    df['IR_Change'] = df['Interest_Rate'].diff().fillna(0)\n"
    "    print(\"✅ Interest Rates merged.\")\n"
    "print(f\"Final shape: {df.shape}\")"
))
cells.append(md("### 2.3 Data Quality Check"))
cells.append(code(
    "missing = df.isnull().sum()\n"
    "print(\"Missing values:\\n\", missing[missing > 0])\n"
    "df.dropna(inplace=True)\n"
    "df.sort_index(inplace=True)\n"
    "print(f\"\\n✅ Clean dataset: {len(df):,} rows\")"
))
cells.append(md("### 2.4 Data Preview"))
cells.append(code("df.head()"))
cells.append(code("df.info()"))
cells.append(code("df.describe()"))
cells.append(md("### 📊 Chart 1 — Raw Candlestick + Volume"))
cells.append(code(RAW_CHART_CODE))

# ─────── SECTION 3: FEATURE ENGINEERING ───────
cells.append(md(
    "## 3. Advanced Feature Engineering\n"
    "We convert raw OHLCV prices into mathematical signals across four categories: "
    "**Trend**, **Momentum**, **Volatility**, and **Time**."
))
cells.append(md(
    "### 3A. Log Returns & Velocity\n"
    "**Log returns** stabilize variance across time. **Price Velocity** (ΔR) "
    "is an early-warning system for sudden market shifts.\n\n"
    "$$R_t = \\ln\\left(\\frac{P_t + \\epsilon}{P_{t-1} + \\epsilon}\\right), "
    "\\quad V_t = R_t - R_{t-1}$$"
))
cells.append(code(
    "df['log_ret'] = np.log((df['close'] + 1e-6) / (df['close'].shift(1) + 1e-6))\n"
    "df['price_velocity'] = df['log_ret'].diff()\n"
    "\n"
    "if 'close_usd' in df.columns:\n"
    "    df['log_ret_usd'] = np.log((df['close_usd'] + 1e-6) / (df['close_usd'].shift(1) + 1e-6))\n"
    "    df['price_velocity_usd'] = df['log_ret_usd'].diff()\n"
    "    df['log_ret_usd_lag1'] = df['log_ret_usd'].shift(1)\n"
    "\n"
    "# Relative Volume (RVOL) — how unusual is today's volume vs 50-day avg?\n"
    "df['Volume_SMA_50'] = df['volume'].rolling(window=50).mean()\n"
    "df['RVOL_50'] = (df['volume'] / (df['Volume_SMA_50'] + 1e-9)).clip(upper=5.0)\n"
    "print(\"✅ Log returns, velocity, RVOL computed.\")"
))
cells.append(md(
    "### 3B. Cyclic Time Features\n"
    "Tree models don't understand calendar periodicity. We encode day-of-week "
    "as a continuous sine/cosine wave.\n\n"
    "$$X_{\\sin} = \\sin\\!\\left(\\frac{2\\pi d}{7}\\right), "
    "\\quad X_{\\cos} = \\cos\\!\\left(\\frac{2\\pi d}{7}\\right)$$"
))
cells.append(code(
    "df['day_sin'] = np.sin(2 * np.pi * df.index.dayofweek / 7)\n"
    "df['day_cos'] = np.cos(2 * np.pi * df.index.dayofweek / 7)\n"
    "print(\"✅ Cyclic time features added.\")"
))
cells.append(md(
    "### 3C. Exponential Moving Averages (EMA) & Trend Gap\n"
    "The EMA reacts faster to recent prices. The **distance from EMA** "
    "measures how over-extended the price is.\n\n"
    "$$EMA_t = P_t \\cdot \\alpha + EMA_{t-1} \\cdot (1-\\alpha)$$"
))
cells.append(code(
    "for period in [9, 21, 50]:\n"
    "    ema_col = f'EMA_{period}'\n"
    "    df[ema_col] = df['close'].ewm(span=period).mean()\n"
    "    df[f'dist_EMA_{period}'] = (df['close'] - df[ema_col]) / (df[ema_col] + 1e-9)\n"
    "\n"
    "# Binary downtrend sensor: 1 when price breaks below fast EMA\n"
    "df['below_EMA9'] = (df['close'] < df['EMA_9']).astype(int)\n"
    "print(\"✅ EMAs and trend sensors added.\")"
))
cells.append(md(
    "### 3D. Momentum Indicators (RSI & MACD)\n"
    "- **RSI**: Measures buying/selling exhaustion\n"
    "- **MACD Histogram**: Speed and direction of momentum"
))
cells.append(code(
    "# RSI\n"
    "delta = df['close'].diff()\n"
    "gain  = delta.where(delta > 0, 0).rolling(14).mean()\n"
    "loss  = (-delta.where(delta < 0, 0)).rolling(14).mean()\n"
    "df['RSI'] = 100 - (100 / (1 + gain / (loss + 1e-9)))\n"
    "df['RSI_diff'] = df['RSI'].diff()\n"
    "print(\"✅ RSI computed.\")"
))
cells.append(code(
    "# MACD Histogram\n"
    "macd = df['close'].ewm(span=12).mean() - df['close'].ewm(span=26).mean()\n"
    "df['MACD_Hist'] = macd - macd.ewm(span=9).mean()\n"
    "print(\"✅ MACD computed.\")"
))
cells.append(md(
    "### 3E. Volatility (ATR & Bollinger Bands)\n"
    "- **ATR%**: Normalized average true range — market nervousness\n"
    "- **BB Width**: Narrow squeeze mathematically precedes explosive moves"
))
cells.append(code(
    "# ATR (Average True Range %)\n"
    "tr = pd.concat([\n"
    "    df['high'] - df['low'],\n"
    "    np.abs(df['high'] - df['close'].shift()),\n"
    "    np.abs(df['low']  - df['close'].shift())\n"
    "], axis=1).max(axis=1)\n"
    "df['ATR_pct'] = tr.rolling(14).mean() / (df['close'] + 1e-9)\n"
    "print(\"✅ ATR computed.\")"
))
cells.append(code(
    "# Bollinger Band Width\n"
    "ma20  = df['close'].rolling(20).mean()\n"
    "std20 = df['close'].rolling(20).std()\n"
    "df['BB_Width'] = (std20 * 4) / (ma20 + 1e-9)\n"
    "\n"
    "# Stochastic %K\n"
    "low_14  = df['low'].rolling(14).min()\n"
    "high_14 = df['high'].rolling(14).max()\n"
    "df['Stoch_K'] = 100 * ((df['close'] - low_14) / (high_14 - low_14 + 1e-9))\n"
    "print(\"✅ BB Width and Stochastic computed.\")"
))
cells.append(md("### 3F. Temporal Lags"))
cells.append(code(
    "df['log_ret_lag1'] = df['log_ret'].shift(1)\n"
    "df['RSI_lag1']     = df['RSI'].shift(1)\n"
    "print(\"✅ Lag features added.\")"
))

# ─────── SECTION 4: VISUALIZATION ───────
cells.append(md(
    "## 4. Quant Transformation Visualization\n"
    "Comparing raw noise to structured mathematical signals."
))
cells.append(md("### 📊 Chart 2 — 4-Panel Technical Dashboard"))
cells.append(code(TECH_DASHBOARD_CODE))

# ─────── SECTION 5: TARGET ENGINEERING ───────
cells.append(md(
    "## 5. Target Label Engineering\n"
    "**Concept:** We predict the *direction* of the smoothed EMA (not the raw price). "
    "This removes daily noise and forces the model to learn genuine trend changes.\n\n"
    "- **1 (Up)** → EMA_10 tomorrow > EMA_10 today\n"
    "- **0 (Down)** → EMA_10 tomorrow ≤ EMA_10 today"
))
cells.append(code(
    "df['Target'] = (\n"
    "    df['close'].ewm(span=10).mean().shift(-1) > df['close'].ewm(span=10).mean()\n"
    ").astype(int)\n"
    "\n"
    "df.replace([np.inf, -np.inf], np.nan, inplace=True)\n"
    "df.dropna(inplace=True)\n"
    "print(f\"✅ Target created. Dataset size after cleaning: {len(df):,}\")"
))
cells.append(md("### 5.1 Define Final Feature Set"))
cells.append(code(
    "final_features = [\n"
    "    'log_ret', 'log_ret_usd', 'price_velocity', 'price_velocity_usd', 'RVOL_50',\n"
    "    'log_ret_usd_lag1', 'day_sin', 'day_cos',\n"
    "    'dist_EMA_9', 'dist_EMA_21', 'dist_EMA_50', 'below_EMA9',\n"
    "    'RSI', 'RSI_diff', 'RSI_lag1', 'MACD_Hist',\n"
    "    'ATR_pct', 'BB_Width', 'Stoch_K',\n"
    "    'log_ret_lag1',\n"
    "    'gold_log_ret', 'gold_velocity', 'gold_ret_lag1',\n"
    "    'IR_Change',\n"
    "]\n"
    "final_features = [f for f in final_features if f in df.columns]\n"
    "\n"
    "X = df[final_features]\n"
    "y = df['Target']\n"
    "print(f\"✅ Feature matrix: {X.shape[0]:,} rows × {X.shape[1]} features\")"
))
cells.append(md("### 📊 Chart 3 — Label Distribution"))
cells.append(code(LABEL_DIST_CODE))

# ─────── SECTION 6: TRAIN/TEST SPLIT ───────
cells.append(md(
    "## 6. Chronological Train / Test Split\n"
    "We use an **80/20 chronological split** (no shuffle) to prevent data leakage. "
    "The model must predict future events it has never seen."
))
cells.append(code(
    "split = int(len(X) * 0.80)\n"
    "X_train, X_test = X[:split], X[split:]\n"
    "y_train, y_test = y[:split], y[split:]\n"
    "\n"
    "# Scale features\n"
    "scaler = StandardScaler()\n"
    "X_train_scaled = scaler.fit_transform(X_train)\n"
    "X_test_scaled  = scaler.transform(X_test)\n"
    "\n"
    "print(f\"Train: {len(X_train):,} samples | Test: {len(X_test):,} samples\")"
))
cells.append(md("### 📊 Chart 4 — Train/Test Split Timeline"))
cells.append(code(SPLIT_VIZ_CODE))

# ─────── SECTION 7: MODEL TRAINING ───────
cells.append(md(
    "## 7. Stacking Ensemble — XGBoost + LightGBM + Logistic Regression\n"
    "**Architecture:** Two strong tree-based learners feed a Logistic Regression meta-learner "
    "that is biased to penalize missed down-trends more heavily."
))
cells.append(md("### 7.1 Hyperparameter Optimization (Optuna)"))
cells.append(code(
    "import optuna\n"
    "from sklearn.model_selection import cross_val_score\n"
    "optuna.logging.set_verbosity(optuna.logging.WARNING)\n"
    "\n"
    "def objective_xgb(trial):\n"
    "    params = {\n"
    "        'n_estimators':     trial.suggest_int('n_estimators', 200, 800),\n"
    "        'max_depth':        trial.suggest_int('max_depth', 3, 8),\n"
    "        'learning_rate':    trial.suggest_float('learning_rate', 0.01, 0.15),\n"
    "        'subsample':        trial.suggest_float('subsample', 0.6, 1.0),\n"
    "        'colsample_bytree': trial.suggest_float('colsample_bytree', 0.6, 1.0),\n"
    "        'scale_pos_weight': trial.suggest_float('scale_pos_weight', 1.0, 3.0),\n"
    "        'use_label_encoder': False, 'eval_metric': 'logloss',\n"
    "    }\n"
    "    model = xgb.XGBClassifier(**params, random_state=42)\n"
    "    score = cross_val_score(model, X_train_scaled, y_train, cv=5,\n"
    "                            scoring='f1', n_jobs=-1).mean()\n"
    "    return score\n"
    "\n"
    "study_xgb = optuna.create_study(direction='maximize')\n"
    "study_xgb.optimize(objective_xgb, n_trials=30, show_progress_bar=True)\n"
    "print(f\"\\n✅ Best XGBoost F1: {study_xgb.best_value:.4f}\")\n"
    "print(f\"   Best params: {study_xgb.best_params}\")"
))
cells.append(md("### 7.2 Build Base Models"))
cells.append(code(
    "best_xgb = xgb.XGBClassifier(\n"
    "    **study_xgb.best_params,\n"
    "    use_label_encoder=False, eval_metric='logloss', random_state=42\n"
    ")\n"
    "best_lgb = lgb.LGBMClassifier(\n"
    "    n_estimators=500, learning_rate=0.05, num_leaves=31,\n"
    "    class_weight='balanced', random_state=42, verbose=-1\n"
    ")\n"
    "base_models = [('xgb', best_xgb), ('lgb', best_lgb)]\n"
    "print(\"✅ Base models configured.\")"
))
cells.append(md("### 7.3 Meta-Learner with Downtrend Bias Control"))
cells.append(code(
    "# Penalize the model more for missing Down-Trends (class 0)\n"
    "# class_weight={0: 1.5, 1: 1.0} means missing a down-trend is 1.5x costlier\n"
    "final_logic = LogisticRegression(C=0.1, class_weight={0: 1.5, 1: 1.0})\n"
    "print(\"✅ Meta-learner with bias control ready.\")"
))
cells.append(md("### 7.4 Train the Stacking Classifier"))
cells.append(code(
    "stack_model = StackingClassifier(\n"
    "    estimators=base_models,\n"
    "    final_estimator=final_logic,\n"
    "    cv=5\n"
    ")\n"
    "stack_model.fit(X_train_scaled, y_train)\n"
    "print(\"\\n✅ Stacking Ensemble trained!\")"
))

# ─────── SECTION 8: EVALUATION ───────
cells.append(md(
    "## 8. Final Evaluation & Down-Trend Detection\n"
    "Key metric: **Recall for class 0 (Down-Trend)** — how many real crashes did we catch?"
))
cells.append(code(
    "y_pred = stack_model.predict(X_test_scaled)\n"
    "acc = accuracy_score(y_test, y_pred) * 100\n"
    "\n"
    "print(f\"{'='*55}\")\n"
    "print(f\"  DEEP QUANT MODEL — Overall Accuracy: {acc:.2f}%\")\n"
    "print(f\"{'='*55}\\n\")\n"
    "print(classification_report(y_test, y_pred,\n"
    "      target_names=['Down-Trend (0)', 'Up-Trend (1)']))"
))
cells.append(md("### 📊 Chart 5 — Confusion Matrix"))
cells.append(code(CONF_MATRIX_CODE))
cells.append(md("### 📊 Chart 6 — Feature Importance"))
cells.append(code(FEAT_IMP_CODE))

# ─────── SECTION 9: SIGNAL OVERLAY ───────
cells.append(md(
    "## 9. Strategy Testing & Signal Generation\n"
    "Map model predictions back to dates and prices, then overlay buy/sell signals on the chart."
))
cells.append(md("### 9.1 Build Results DataFrame"))
cells.append(code(
    "test_dates = pd.Series(df.index[split:], name='timestamp').reset_index(drop=True)\n"
    "test_close = df['close'].iloc[split:].reset_index(drop=True)\n"
    "test_ema10  = df['close'].ewm(span=10).mean().iloc[split:].reset_index(drop=True)\n"
    "\n"
    "results_df = pd.DataFrame({\n"
    "    'timestamp':       test_dates,\n"
    "    'close':           test_close,\n"
    "    'EMA_10':          test_ema10,\n"
    "    'Actual_Trend':    y_test.reset_index(drop=True),\n"
    "    'Predicted_Trend': y_pred,\n"
    "})\n"
    "print(f\"✅ Results DataFrame: {len(results_df):,} rows\")"
))
cells.append(md("### 📊 Chart 7 — Prediction Signal Overlay"))
cells.append(code(SIGNAL_OVERLAY_CODE))

# ─────── SECTION 10: BACKTESTING ───────
cells.append(md(
    "## 10. Strategy Backtesting & Financial ROI\n"
    "Transform prediction signals into a simulated trading strategy and compare against Buy & Hold."
))
cells.append(code(
    "initial_capital = 10_000.0\n"
    "\n"
    "bt_df = results_df.copy()\n"
    "bt_df['daily_return']   = bt_df['close'].pct_change().fillna(0)\n"
    "bt_df['strategy_return'] = bt_df['daily_return'] * bt_df['Predicted_Trend'].shift(1).fillna(0)\n"
    "\n"
    "bt_df['portfolio_value'] = initial_capital * (1 + bt_df['strategy_return']).cumprod()\n"
    "bt_df['bh_value']        = initial_capital * (1 + bt_df['daily_return']).cumprod()\n"
    "\n"
    "final_portfolio  = bt_df['portfolio_value'].iloc[-1]\n"
    "final_bh         = bt_df['bh_value'].iloc[-1]\n"
    "strategy_return  = (final_portfolio - initial_capital) / initial_capital * 100\n"
    "bh_return        = (final_bh        - initial_capital) / initial_capital * 100\n"
    "print(\"✅ Backtest computed.\")"
))
cells.append(md("### 📊 Chart 8 — Portfolio Growth vs Buy & Hold"))
cells.append(code(PORTFOLIO_CHART_CODE))

# ─────── SECTION 11: SAVE MODEL ───────
cells.append(md("## 11. Save Model & Scaler"))
cells.append(code(
    "models_dir = os.path.join(current_dir, 'models')\n"
    "os.makedirs(models_dir, exist_ok=True)\n"
    "\n"
    "joblib.dump(stack_model, os.path.join(models_dir, 'deep_quant_stacking_model.pkl'))\n"
    "joblib.dump(scaler,      os.path.join(models_dir, 'deep_quant_scaler.pkl'))\n"
    "joblib.dump(final_features, os.path.join(models_dir, 'deep_quant_features.pkl'))\n"
    "\n"
    "print(\"✅ Model, scaler, and feature list saved to:\", models_dir)"
))

# ============================================================
# WRITE THE NEW NOTEBOOK
# ============================================================
nb_template = {
    "nbformat": 4,
    "nbformat_minor": 5,
    "metadata": {
        "kernelspec": {
            "display_name": "Python 3",
            "language": "python",
            "name": "python3"
        },
        "language_info": {
            "name": "python",
            "version": "3.10.0"
        }
    },
    "cells": cells
}

output_path = '/home/heiba/EGX360_Graduation_Project/Models/EGX/THE DEEP QUANT MODEL.ipynb'
with open(output_path, 'w', encoding='utf-8') as f:
    json.dump(nb_template, f, ensure_ascii=False, indent=1)

print(f"✅ Notebook rebuilt: {len(cells)} cells written to:")
print(f"   {output_path}")
