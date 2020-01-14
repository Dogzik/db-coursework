CREATE OR REPLACE FUNCTION validate_user(id_arg INT,
                                         pass_arg TEXT)
  RETURNS BOOLEAN
  IMMUTABLE
AS
$$
BEGIN
  RETURN exists(
    SELECT *
    FROM taxi_users
    WHERE id = id_arg
      AND auth_token = crypt(pass_arg, auth_token)
    );
END;
$$ LANGUAGE plpgsql;
