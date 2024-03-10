DROP MATERIALIZED VIEW highest_avg_trip;
DROP MATERIALIZED VIEW times_per_zone;

CREATE MATERIALIZED VIEW times_per_zone AS
 SELECT taxi_zone.Zone AS pickup_zone, taxi_zone_1.Zone AS dropoff_zone,
 MAX(EXTRACT(EPOCH FROM (tpep_dropoff_datetime - tpep_pickup_datetime)) / 60) AS max_time,
 MIN(EXTRACT(EPOCH FROM (tpep_dropoff_datetime - tpep_pickup_datetime)) / 60) AS min_time,
 AVG(EXTRACT(EPOCH FROM (tpep_dropoff_datetime - tpep_pickup_datetime)) / 60) AS avg_time,
 COUNT(*) AS trips
 FROM trip_data
 JOIN taxi_zone ON trip_data.PULocationID = taxi_zone.location_id
 JOIN taxi_zone as taxi_zone_1 ON trip_data.DOLocationID = taxi_zone_1.location_id
 GROUP BY taxi_zone.Zone, taxi_zone_1.Zone;


CREATE MATERIALIZED VIEW highest_avg_trip AS
    WITH t AS (
        SELECT MAX(avg_time) AS h_avg_time FROM times_per_zone
    )
    SELECT
        times_per_zone.pickup_zone, times_per_zone.dropoff_zone, times_per_zone.max_time, times_per_zone.min_time, times_per_zone.avg_time, times_per_zone.trips
    FROM times_per_zone JOIN t ON times_per_zone.avg_time = t.h_avg_time;

SELECT * FROM highest_avg_trip;


select * from busiest_zones ORDER BY trips DESC;

CREATE MATERIALIZED VIEW busiest_zones AS
    WITH t AS (
        SELECT MAX(tpep_pickup_datetime) AS hours_ago FROM trip_data
    )
    SELECT taxi_zone.Zone AS pickup_zone, COUNT(*) AS trips
    FROM trip_data
    JOIN taxi_zone ON trip_data.PULocationID = taxi_zone.location_id
    WHERE tpep_pickup_datetime >= (t.hours_ago - INTERVAL '17 hours')
    GROUP BY taxi_zone.Zone;


CREATE MATERIALIZED VIEW busiest_zones AS
    SELECT taxi_zone.Zone AS pickup_zone, COUNT(*) AS trips
    FROM trip_data
    JOIN taxi_zone ON trip_data.PULocationID = taxi_zone.location_id
    WHERE tpep_pickup_datetime >= (SELECT MAX(tpep_pickup_datetime) - INTERVAL '17 hours' FROM trip_data)
    GROUP BY taxi_zone.Zone;


SELECT MAX(tpep_pickup_datetime) AS MAX_PICKUP, MAX(tpep_pickup_datetime) - INTERVAL '17 hours' FROM trip_data;

SELECT MAX(tpep_pickup_datetime) AS MAX_PICKUP, MIN(tpep_pickup_datetime) MIN_PICKUP FROM trip_data;

SELECT taxi_zone.Zone AS pickup_zone, COUNT(*) AS trips FROM trip_data
JOIN taxi_zone ON trip_data.PULocationID = taxi_zone.location_id
WHERE tpep_pickup_datetime >= (SELECT MAX(tpep_pickup_datetime) - INTERVAL '17 hours' FROM trip_data)
GROUP BY taxi_zone.Zone ORDER BY trips DESC;