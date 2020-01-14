-- total_distance is returned distance in km
CREATE OR REPLACE FUNCTION user_statistics_for_year(year_arg INT)
  RETURNS TABLE
          (
            id             INT,
            full_name      VARCHAR(100),
            rides_cnt      BIGINT,
            total_distance FLOAT,
            total_time     INTERVAL
          )
  IMMUTABLE
AS
$$
BEGIN
  RETURN QUERY
    WITH year_rides AS (
      SELECT *
      FROM rides
      WHERE extract(YEAR FROM start_time) = year_arg
        AND extract(YEAR FROM end_time) = year_arg
    )
    SELECT taxi_users.id AS id,
           taxi_users.full_name AS full_name,
           count(year_rides.id) AS rides_cnt,
           coalesce(sum(distance) / 1000.0, 0)::FLOAT AS total_distance,
           coalesce(sum(end_time - start_time), '0 minutes'::INTERVAL) AS total_time
    FROM taxi_users
         LEFT OUTER JOIN year_rides ON taxi_users.id = year_rides.user_id
    GROUP BY taxi_users.id, taxi_users.full_name;
END;
$$ LANGUAGE plpgsql;
