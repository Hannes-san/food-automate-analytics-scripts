-- Запрос считает плановый расход сырья по конкретному плану

WITH plan_table AS
(
  SELECT
      p.name,
      ROUND(SUM(o.count * tcp.count)::NUMERIC, 3) AS total_product_amount,
      p.measure
  FROM orders o
  JOIN techcardproducts tcp
      ON o.techcard_id = tcp.techcard_id
  JOIN products p
      ON tcp.product_id = p.id
  JOIN workshops w
      ON p.workshop_id = w.id
  WHERE
      o.plan_id = 248
      AND w.name IN ('Склад сырья', 'Склад упаковки')
  GROUP BY
      p.name,
      p.measure
  ORDER BY
      p.name
)
SELECT * FROM plan_table;
