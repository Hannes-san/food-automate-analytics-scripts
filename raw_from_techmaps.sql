-- Запрос считает сколько сырья и упаковок находится в каждой техкарте

WITH raw_table AS
(
   SELECT
       t.name AS techcard_name,
       pr1.name AS raw_material,
       SUM(tcp1.count) AS raw_count,  -- Суммируем количество
       pr1.measure
   FROM techcards t
   JOIN techcardproducts tcp1
       ON t.id = tcp1.techcard_id
   JOIN techcardproducts tcp2
       ON tcp1.techcard_id = tcp2.techcard_id
       AND tcp1.parent_id = tcp2.id
   JOIN products pr1
       ON tcp1.product_id = pr1.id
   JOIN products pr2
       ON tcp2.product_id = pr2.id
   JOIN workshops w1
       ON pr1.workshop_id = w1.id
   JOIN workshops w2
       ON pr2.workshop_id = w2.id
   WHERE
       w1.name IN ('Склад сырья', 'Склад упаковки')
   GROUP BY
       t.name, pr1.name, pr1.measure
   ORDER BY
       techcard_name, raw_material
)
SELECT * FROM raw_table;
