INSERT INTO ongoing_rides (src_id, dst_id, start_time, level,
                           passengers_cnt, user_id, car_id, driver_id)
VALUES (1, 2, '2020-02-01', 'lux', 2, 1, 3, 1);

SELECT finish_ride(1, 700, 1000, 6003,
                   '2020-02-02', 'cash');

SELECT *
FROM user_statistics_for_year(2020);
