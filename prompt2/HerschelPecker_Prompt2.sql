CREATE OR REPLACE TABLE
  SENSOR_ANALYTICS AS
WITH
  FLAT_DATA AS (
    SELECT
      VALUE:container_id AS container_id
      , MAX(VALUE:fill_level_percentage) AS fill_level_percentage
      , VALUE:timestamp::timestamp AS event_timestamp
    FROM
      TIMESERIES
      , LATERAL flatten(INPUT => v:data.data)
    GROUP BY
        1, 3
  ),
  STATE_EVENTS AS (
    SELECT
      *
      , min(fill_level_percentage) OVER (
        PARTITION BY
          container_id
        ORDER BY
          event_timestamp
        ROWS
          BETWEEN 3 PRECEDING AND CURRENT ROW) > 80 AS alert_triggered
      , max(fill_level_percentage) OVER (
        PARTITION BY
          container_id
        ORDER BY
          event_timestamp
        ROWS
          BETWEEN 3 PRECEDING AND CURRENT ROW) < 20 AS serviced
      , min(fill_level_percentage) OVER (
        PARTITION BY
          container_id
        ORDER BY
          event_timestamp
        ROWS
          BETWEEN 2 PRECEDING AND CURRENT ROW) > 100 AS overflowed
    FROM
      FLAT_DATA
  ),
  NEXT_SERVICE AS (
    SELECT
      t.container_id
      , t.event_timestamp AS alert_time
      , min(s.event_timestamp) AS serviced_time
    FROM
      STATE_EVENTS AS t
    JOIN
      STATE_EVENTS AS s
    ON
      t.container_id = s.container_id
      AND t.event_timestamp < s.event_timestamp
    WHERE
      t.alert_triggered = TRUE
      AND s.serviced = TRUE
    GROUP BY
      1, 2
  ),
  START_END AS (
    SELECT
      container_id
      , min(alert_time) AS alert_triggered_time
      , serviced_time
    FROM
      NEXT_SERVICE
    GROUP BY
      1, 3
  )
SELECT
  se.*
  , round(datediff(second, alert_triggered_time, serviced_time) / 3600.0, 2) AS pick_up_time_hrs
  , CASE WHEN count(o.*) > 0 THEN 1 ELSE 0 END AS overflow
FROM
  START_END AS se
LEFT JOIN
  STATE_EVENTS AS o
ON
  se.container_id = o.container_id
  AND o.overflowed = TRUE
  AND o.event_timestamp BETWEEN alert_triggered_time AND serviced_time
GROUP BY
  1, 2, 3, 4
;