CREATE EXTENSION btree_gist;

-- Ride's timestamps must be correct
ALTER TABLE rides
  ADD CHECK ( start_time < end_time );

-- Can't have intersected rides on same car
ALTER TABLE rides
  ADD EXCLUDE USING gist (
    car_id WITH =,
    tsrange(start_time, end_time, '[]') WITH &&
    );

-- Can't have intersected rides with same driver
ALTER TABLE rides
  ADD EXCLUDE USING gist (
    driver_id WITH =,
    tsrange(start_time, end_time, '[]') WITH &&
    );

-- car must have enough space and satisfy class requirements
CREATE OR REPLACE FUNCTION check_passengers() RETURNS TRIGGER
AS
$check_passengers$
BEGIN
  IF NOT exists(
    SELECT *
    FROM cars
    WHERE cars.id = NEW.car_id
      AND capacity >= NEW.passengers_cnt
      AND cars.level >= NEW.level
    ) THEN
    RAISE EXCEPTION 'Non-suitable car';
  ELSE
    RETURN NEW;
  END IF;
END;
$check_passengers$ LANGUAGE plpgsql;

CREATE TRIGGER check_passengers_complete
  BEFORE INSERT OR UPDATE
  ON rides
  FOR EACH ROW
EXECUTE PROCEDURE check_passengers();

CREATE TRIGGER check_passengers_ongoing
  BEFORE INSERT OR UPDATE
  ON ongoing_rides
  FOR EACH ROW
EXECUTE PROCEDURE check_passengers();

-- there can't be ongoing ride started after current
CREATE OR REPLACE FUNCTION check_ongoing_ride() RETURNS TRIGGER
AS
$check_ongoing_ride$
BEGIN
  IF exists(
    SELECT *
    FROM ongoing_rides o_r
    WHERE (
        o_r.driver_id = NEW.driver_id
        OR o_r.car_id = NEW.car_id
      )
      AND o_r.start_time <= NEW.end_time
    ) THEN
    RAISE EXCEPTION 'Ride ends after ongoing ride';
  ELSE
    RETURN NEW;
  END IF;
END;
$check_ongoing_ride$ LANGUAGE plpgsql;

CREATE TRIGGER check_ongoing_ride
  BEFORE INSERT OR UPDATE
  ON rides
  FOR EACH ROW
EXECUTE PROCEDURE check_ongoing_ride();

-- ride can't start before newest completed ride
CREATE OR REPLACE FUNCTION check_finished_ride() RETURNS TRIGGER
AS
$check_finished_ride$
BEGIN
  IF exists(
    SELECT *
    FROM rides r
    WHERE (
        r.user_id = NEW.user_id
        OR r.driver_id = NEW.driver_id
        OR r.car_id = NEW.car_id
      )
      AND r.end_time >= NEW.start_time
    ) THEN
    RAISE EXCEPTION 'Ongoing ride starts after completed ride';
  ELSE
    RETURN NEW;
  END IF;
END;
$check_finished_ride$ LANGUAGE plpgsql;

CREATE TRIGGER check_finished_ride
  BEFORE INSERT OR UPDATE
  ON ongoing_rides
  FOR EACH ROW
EXECUTE PROCEDURE check_finished_ride();
