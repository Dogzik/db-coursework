CREATE OR REPLACE FUNCTION finish_ride(driver_id_arg INT,
                                       price_arg INT,
                                       distance_arg INT,
                                       ride_id_arg INT,
                                       end_time_arg TIMESTAMP,
                                       payment_type_arg payment_type_t)
  RETURNS BOOLEAN
AS
$$
DECLARE
  cur_ride ongoing_rides;
BEGIN
  DELETE
  FROM ongoing_rides
  WHERE driver_id = driver_id_arg
  RETURNING *
    INTO cur_ride;
  IF cur_ride IS NULL THEN
    RETURN FALSE;
  ELSE
    INSERT INTO rides (id, src_id, dst_id, start_time,
                       end_time, payment_type, price,
                       level, passengers_cnt, driver_id,
                       car_id, user_id, distance)
    VALUES (ride_id_arg, cur_ride.src_id, cur_ride.dst_id, cur_ride.start_time,
            end_time_arg, payment_type_arg, price_arg,
            cur_ride.level, cur_ride.passengers_cnt, driver_id_arg,
            cur_ride.car_id, cur_ride.user_id, distance_arg);
    RETURN TRUE;
  END IF;
END;
$$ LANGUAGE plpgsql;