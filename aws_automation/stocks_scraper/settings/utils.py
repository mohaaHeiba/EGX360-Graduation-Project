from datetime import datetime, time as dtime
import pytz  # مكتبة التعامل مع المناطق الزمنية

# دالة تجيب توقيت القاهرة سواء صيفي أو شتوي أوتوماتيك
def get_cairo_time():
    cairo_timezone = pytz.timezone('Africa/Cairo')
    return datetime.now(cairo_timezone)

def is_market_open():
    now_cairo = get_cairo_time()
    
    # 0=Monday, ..., 4=Friday, 5=Saturday, 6=Sunday
    # أجازة البورصة المصرية الجمعة (4) والسبت (5)
    weekday = now_cairo.weekday()
    current_time = now_cairo.time()
    
    # مواعيد الجلسة
    market_open = dtime(10, 0)
    market_close = dtime(14, 46) # لضمان إغلاق جلسة المزاد
    
    # الشرط: ليس جمعة أو سبت + الوقت داخل حدود الجلسة
    return weekday not in [4, 5] and market_open <= current_time <= market_close