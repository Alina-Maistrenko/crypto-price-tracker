--Selecting unique cryptocurrency symbols

select DISTINCT cp.symbol 
from crypto_prices cp 
;

--Count the number of entries per cryptocurrency symbol

SELECT symbol
, COUNT(*) AS num_entries
FROM crypto_prices
GROUP BY symbol
ORDER BY num_entries DESC
;

--Price statistics per cryptocurrency

SELECT symbol 
, round(AVG(price),2) as avg_price_usd
, round(MAX(price),2) as max_price_usd
, ROUND(MIN(price),2) as min_price_usd
FROM crypto_prices
GROUP BY symbol
ORDER BY max_price_usd DESC 
;

--Latest closing price by cryptocurrency

SELECT symbol, price, date
FROM crypto_prices cp1
WHERE date = (
    SELECT MAX(date) 
    FROM crypto_prices cp2
    WHERE cp2.symbol = cp1.symbol
)
ORDER BY price desc
;

-- Cryptocurrency price volatility over full period

select 
symbol
, ROUND(sqrt(
        (sum(price * price) - (sum(price) * sum(price) / count(price))) / (count(price) - 1)),2) as volatility
from crypto_prices cp 
group by symbol 
order by volatility desc
;

-- 7-day Price Change Percentage
WITH current as(                
select symbol
, price as current_price
from crypto_prices cp
where date = (select max(date)
			  from crypto_prices)
),
	price_7d_ago AS(
					select symbol
					, price as price_7d_ago
					, date
					from crypto_prices cp
						where date = ( 
									SELECT MAX(date) 
									FROM crypto_prices
									WHERE date <= DATE((SELECT MAX(date) FROM crypto_prices), '-6 day'))
)
SELECT 
c.symbol
, c.current_price
, price_7d_ago 
, round(((c.current_price - price_7d_ago ) / price_7d_ago ) * 100,2) as percent_change_7d
 from current c
JOIN price_7d_ago p
  ON c.symbol = p.symbol
ORDER BY percent_change_7d DESC;

-- What If I Invested $100 Seven Days Ago?

WITH current as(
			select symbol
			, price as current_price
			from crypto_prices cp
			where date = (select max(date)
			  from crypto_prices)
),
price_7d_ago AS(
			select symbol
			, price as price_7d_ago
			, date
			from crypto_prices cp
			where date = ( 
						SELECT MAX(date) 
						FROM crypto_prices
						WHERE date <= DATE((SELECT MAX(date) FROM crypto_prices), '-6 day'))
)
select
c.symbol
, c.current_price
, ROUND(100 / p.price_7d_ago, 6) as coins_bought
, ROUND((100 / p.price_7d_ago) *  c.current_price,2) as value_today
, ROUND(((100 / p.price_7d_ago) * c.current_price) - 100, 2) AS profit_usd
from current c
join price_7d_ago p on c.symbol = p.symbol
;


