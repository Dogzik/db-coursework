CREATE VIEW upgrades AS
(
SELECT rides.level AS requested_level,
       start_time AS time
FROM rides
     JOIN cars ON rides.car_id = cars.id
WHERE rides.level < cars.level
  );