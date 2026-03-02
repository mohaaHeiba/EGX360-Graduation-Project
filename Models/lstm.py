import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from sklearn.preprocessing import MinMaxScaler
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import LSTM, Dense, Dropout, Input

# 1. تحميل وتنظيف البيانات
def load_and_clean_data(filepath):
    df = pd.read_csv(filepath)
    
    # تحويل التاريخ وتعيينه كـ Index
    df['Date'] = pd.to_datetime(df['Date'])
    df.set_index('Date', inplace=True)
    
    # حذف البيانات اللي قبل 2008 (بناءً على نصيحتنا بخصوص الـ Volume)
    df = df[df.index.year >= 2008]
    
    # معالجة الأيام الناقصة (الإجازات) لضمان استمرارية السلسلة الزمنية
    df = df.asfreq('D').fillna(method='ffill')
    
    # معالجة أي قيم مفقودة (NaN) كانت موجودة أصلاً في الداتا
    df = df.interpolate(method='linear')
    
    return df

# 2. إضافة المؤشرات الفنية (Features Engineering)
def add_indicators(df):
    # SMA & EMA
    df['SMA_20'] = df['Close'].rolling(window=20).mean()
    df['EMA_20'] = df['Close'].ewm(span=20, adjust=False).mean()
    
    # RSI (Relative Strength Index)
    delta = df['Close'].diff()
    gain = (delta.where(delta > 0, 0)).rolling(window=14).mean()
    loss = (-delta.where(delta < 0, 0)).rolling(window=14).mean()
    rs = gain / loss
    df['RSI'] = 100 - (100 / (1 + rs))
    
    # حساب Target (النسبة المئوية للتغير في اليوم التالي)
    # ده اللي الموديل هيحاول يتوقعه
    df['Target_Return'] = df['Close'].pct_change().shift(-1)
    
    df.dropna(inplace=True) # حذف الصفوف اللي باظت بسبب الـ Moving Averages
    return df

# 3. التحضير للموديل (Scaling & Sequencing)
def prepare_sequences(df, window_size=60):
    feature_cols = ['Close', 'Volume', 'SMA_20', 'EMA_20', 'RSI']
    
    scaler_x = MinMaxScaler(feature_range=(0, 1))
    scaler_y = MinMaxScaler(feature_range=(-1, 1)) # لأن النسبة ممكن تكون سالب أو موجب
    
    x_scaled = scaler_x.fit_transform(df[feature_cols])
    y_scaled = scaler_y.fit_transform(df[['Target_Return']])
    
    X, y = [], []
    for i in range(window_size, len(df)):
        X.append(x_scaled[i-window_size:i])
        y.append(y_scaled[i])
        
    return np.array(X), np.array(y), scaler_x, scaler_y

# --- التنفيذ المباشر ---

# تحميل الداتا
df = load_and_clean_data('EGX30D_processed.csv') # استبدل باسم ملفك
df = add_indicators(df)

# تحضير الـ Sequences
window = 60 # الموديل هيشوف آخر شهرين
X, y, scaler_x, scaler_y = prepare_sequences(df, window_size=window)

# تقسيم الداتا لـ Train و Test (بدون shuffle عشان ده Time Series)
split = int(len(X) * 0.8)
X_train, X_test = X[:split], X[split:]
y_train, y_test = y[:split], y[split:]

# 4. بناء هيكل الـ LSTM
model = Sequential([
    Input(shape=(X_train.shape[1], X_train.shape[2])),
    LSTM(units=64, return_sequences=True),
    Dropout(0.2),
    LSTM(units=64, return_sequences=False),
    Dropout(0.2),
    Dense(units=32, activation='relu'),
    Dense(units=1) # المخرج هو رقم واحد يعبر عن النسبة المتوقعة
])

model.compile(optimizer='adam', loss='mse')

# 5. التدريب
history = model.fit(
    X_train, y_train, 
    epochs=20, 
    batch_size=32, 
    validation_data=(X_test, y_test),
    verbose=1
)

print("✅ الموديل جاهز والبيانات اتنظفت بنجاح!")