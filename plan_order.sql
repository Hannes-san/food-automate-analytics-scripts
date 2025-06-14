-- Запрос считает количество заказов по конкретному плану

WITH plan_table_order AS
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
)
SELECT * FROM plan_table_order;
