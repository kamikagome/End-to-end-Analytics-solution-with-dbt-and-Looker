{% test is_positive(model, column_name) %}

-- Generic Data Test: Check if column values are positive (> 0)
-- Returns records where the column value is not positive

SELECT *
FROM {{ model }}
WHERE {{ column_name }} IS NOT NULL
  AND {{ column_name }} <= 0

{% endtest %}
