CREATE EXTENSION pgcrypto;

CREATE OR REPLACE FUNCTION add_user(id_arg INT,
                                    name_arg VARCHAR(100),
                                    pass_arg TEXT)
  RETURNS BOOLEAN
AS
$$
DECLARE
  affected_rows INT;
BEGIN
  INSERT INTO taxi_users (id, full_name, auth_token)
  VALUES (id_arg, name_arg, crypt(pass_arg, gen_salt('bf')))
  ON CONFLICT (id) DO NOTHING;
  GET DIAGNOSTICS affected_rows = ROW_COUNT;
  RETURN affected_rows > 0;
END;
$$ LANGUAGE plpgsql;