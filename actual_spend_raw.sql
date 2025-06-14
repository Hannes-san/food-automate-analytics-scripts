-- Запрос считает фактический расход сырья по конкретному плану

WITH batch_table AS (
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
)
SELECT * FROM batch_table;
