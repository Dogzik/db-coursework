CREATE OR REPLACE FUNCTION rides_hour_distribution(from_arg TIMESTAMP,
                                                   to_arg TIMESTAMP)
  RETURNS TABLE
          (
            hour INT,
            cnt  BIGINT
          )
  IMMUTABLE
AS
$$
BEGIN
  RETURN QUERY
    SELECT extract(HOUR FROM start_time)::INT as hour,
           count(1) as cnt
    FROM rides
    WHERE start_time BETWEEN from_arg AND to_arg
    GROUP BY extract(HOUR FROM start_time)
    ORDER BY extract(HOUR FROM start_time);
END;
$$ LANGUAGE plpgsql;
