-- km/h
CREATE VIEW average_speed AS
(
SELECT driver_id,
       full_name,
       avg(distance * 3.6 / extract(EPOCH FROM (end_time - start_time)))
         AS speed
FROM rides
     JOIN taxi_drivers on driver_id = taxi_drivers.id
GROUP BY driver_id, full_name
  );
