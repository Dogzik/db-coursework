CREATE OR REPLACE FUNCTION upgrades_in_period(start_arg TIMESTAMP,
                                              end_arg TIMESTAMP)
  RETURNS TABLE
          (
            requested_level level_t,
            cnt             BIGINT
          )
  IMMUTABLE
AS
$$
BEGIN
  RETURN QUERY
    SELECT upgrades.requested_level,
           count(1) AS cnt
    FROM upgrades
    WHERE time BETWEEN start_arg AND end_arg
    GROUP BY upgrades.requested_level;
END;
$$ LANGUAGE plpgsql;
