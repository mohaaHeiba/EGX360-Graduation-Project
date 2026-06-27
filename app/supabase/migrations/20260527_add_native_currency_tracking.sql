-- Migration: Add Native Currency Tracking for Multi-Currency Portfolios
-- Date: 2026-05-27

-- 1. Alter user_transactions to store currency context at time of trade
ALTER TABLE public.user_transactions
ADD COLUMN IF NOT EXISTS currency text DEFAULT 'EGP',
ADD COLUMN IF NOT EXISTS exchange_rate numeric DEFAULT 1.0,
ADD COLUMN IF NOT EXISTS native_price numeric;

-- 2. Alter user_holdings to permanently store the average cost basis in the native currency
ALTER TABLE public.user_holdings
ADD COLUMN IF NOT EXISTS average_price_native numeric DEFAULT 0;

-- Optional: Initialize existing holdings native price to their EGP price to prevent division by zero or nulls
UPDATE public.user_holdings 
SET average_price_native = average_price 
WHERE average_price_native = 0;

-- 3. Update the execute_trade RPC function to accept and compute native tracking
CREATE OR REPLACE FUNCTION execute_trade(
  p_user_id       uuid,
  p_symbol        text,
  p_type          text,
  p_quantity      numeric,
  p_price         numeric,         -- EGP price
  p_currency      text DEFAULT 'EGP',
  p_exchange_rate numeric DEFAULT 1.0,
  p_native_price  numeric DEFAULT NULL
)
RETURNS void AS $$
DECLARE
  v_total_cost       numeric := p_quantity * p_price;
  v_total_native     numeric := p_quantity * COALESCE(p_native_price, p_price);
  v_current_balance  numeric;
BEGIN
  IF p_type = 'buy' THEN
    SELECT balance INTO v_current_balance
    FROM   public.user_wallets WHERE user_id = p_user_id;

    IF v_current_balance < v_total_cost THEN
      RAISE EXCEPTION 'Insufficient balance';
    END IF;

    UPDATE public.user_wallets
    SET    balance = balance - v_total_cost
    WHERE  user_id = p_user_id;

    INSERT INTO public.user_holdings (user_id, symbol, quantity, average_price, average_price_native)
    VALUES (p_user_id, p_symbol, p_quantity, p_price, COALESCE(p_native_price, p_price))
    ON CONFLICT (user_id, symbol) DO UPDATE SET
      average_price = ((public.user_holdings.quantity * public.user_holdings.average_price) + v_total_cost)
                      / (public.user_holdings.quantity + p_quantity),
      average_price_native = ((public.user_holdings.quantity * public.user_holdings.average_price_native) + v_total_native)
                      / (public.user_holdings.quantity + p_quantity),
      quantity      = public.user_holdings.quantity + p_quantity,
      updated_at    = now();

  ELSIF p_type = 'sell' THEN
    UPDATE public.user_holdings
    SET    quantity   = quantity - p_quantity,
           updated_at = now()
    WHERE  user_id = p_user_id AND symbol = p_symbol AND quantity >= p_quantity;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'Insufficient holdings to sell';
    END IF;

    UPDATE public.user_wallets
    SET    balance = balance + v_total_cost
    WHERE  user_id = p_user_id;
  END IF;

  INSERT INTO public.user_transactions (user_id, symbol, type, quantity, price, total_value, currency, exchange_rate, native_price)
  VALUES (p_user_id, p_symbol, p_type, p_quantity, p_price, v_total_cost, p_currency, p_exchange_rate, COALESCE(p_native_price, p_price));
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
