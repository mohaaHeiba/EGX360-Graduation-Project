
#!/bin/bash

cd /home/ubuntu/stocks_scraper

source venv/bin/activate 2>/dev/null || echo " No virtualenv found, continuing..."


python3 -m egx_candles.abuk_candle &
sleep 5
python -m egx_candles.comi_candle &
sleep 5
python -m egx_candles.east_candle &
 sleep 5
  python -m egx_candles.efih_candle &
  sleep 5
  python -m egx_candles.emfd_candle &
  sleep 5
  python -m egx_candles.etel_candle &
  sleep 5
  python -m egx_candles.expa_candle &
  sleep 5
  python -m egx_candles.fwry_candle &
  sleep 5
  python -m egx_candles.hrho_candle &
  sleep 5
  python -m egx_candles.iron_candle &
  sleep 5
  python -m egx_candles.oras_candle &
  sleep 5
  python -m egx_candles.swdy_candle &
  sleep 5
  python -m egx_candles.tmgh_candle &
  sleep 5
  python -m egx_candles.egx30_candle &
  sleep 5
  python -m egx_candles.egx70ewi_candle &

echo " All EGX candle scripts are running in the background!"

wait
