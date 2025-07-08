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
