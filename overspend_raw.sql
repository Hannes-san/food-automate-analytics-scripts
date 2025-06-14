-- Запрос считает перерасход сырья и упаковок по каждой техкарте в соответствии с фактическим расходом конкретного плана

WITH raw_table AS -- Таблица сырья, этикеток и прочего по каждой техкарте
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
),
batch_table AS -- таблица фактического расхода по плану 248 - это 1 июня 2025
(
   SELECT
      pr.name,
       SUM(t.count_accepted) AS total_count_accepted
   FROM batchs b
   JOIN tasks t
       ON t.id = b.task_id
   JOIN plans p
       ON p.id = t.plan_id
   JOIN products pr
       ON t.product_id = pr.id
   WHERE
       p.id = 248
       AND t.workshop_cooking_id IN (2, 3)
   GROUP BY
       pr.name
),
plan_table_order AS -- Таблица заказов по плану 248
(
   SELECT
       p.id,
       t.name,
       o.count
   FROM plans p
   JOIN orders o
       ON p.id = o.plan_id
   JOIN techcards t
       ON o.techcard_id = t.id
   WHERE
       p.id = 248
   ORDER BY
       t.name
),
plan_table_with_per AS -- Таблица заказов по плану 248 с процентами
(
   SELECT
       rt.techcard_name,
       rt.raw_material,
       rt.raw_count * pto.count AS final_count,
       (rt.raw_count * pto.count * 100.0) /
           SUM(rt.raw_count * pto.count) OVER(PARTITION BY rt.raw_material) AS percentage,
       pto.count
   FROM raw_table rt
   JOIN plan_table_order pto
       ON rt.techcard_name = pto.name
   ORDER BY
       rt.techcard_name, rt.raw_material
),
error_table AS -- Таблица перерасхода сырья по каждой техкарте по плану 248
(
   SELECT
       ptwp.techcard_name,
       ptwp.raw_material,
       rt.raw_count,
       COALESCE((bt.total_count_accepted * ptwp.percentage) / (100 * ptwp.count), 0) AS raw_count_error,
       rt.measure
   FROM plan_table_with_per ptwp
   JOIN raw_table rt
       ON ptwp.techcard_name = rt.techcard_name
       AND ptwp.raw_material = rt.raw_material
   LEFT JOIN batch_table bt
       ON ptwp.raw_material = bt.name
   ORDER BY
       techcard_name, raw_material
)
SELECT * FROM error_table
ORDER BY UPPER(raw_material);
