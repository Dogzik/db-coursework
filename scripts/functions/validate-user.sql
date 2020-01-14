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
      AND pass_hash = crypt(pass_arg, pass_hash)
    );
END;
$$ LANGUAGE plpgsql;
