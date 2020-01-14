-- returns if change happened
-- null address arg means delete
CREATE OR REPLACE FUNCTION modify_home_address(user_id_arg INT,
                                               pass_arg TEXT,
                                               home_addr_arg INT)
  RETURNS BOOLEAN
AS
$$
DECLARE
  affected_rows INT;
BEGIN
  UPDATE taxi_users
  SET home_addr_id = home_addr_arg
  WHERE id = user_id_arg
    AND auth_token = crypt(pass_arg, auth_token);
  GET DIAGNOSTICS affected_rows = ROW_COUNT;
  RETURN affected_rows > 0;
END;
$$ LANGUAGE plpgsql;

-- returns if change happened
-- null address arg equals delete
CREATE OR REPLACE FUNCTION modify_work_address(user_id_arg INT,
                                               pass_arg TEXT,
                                               work_addr_arg INT)
  RETURNS BOOLEAN
AS
$$
DECLARE
  affected_rows INT;
BEGIN
  UPDATE taxi_users
  SET work_addr_id = work_addr_arg
  WHERE id = user_id_arg
    AND auth_token = crypt(pass_arg, auth_token);
  GET DIAGNOSTICS affected_rows = ROW_COUNT;
  RETURN affected_rows > 0;
END;
$$ LANGUAGE plpgsql;
