-- CREATE DATABASE taxi;

CREATE TYPE payment_type_t AS ENUM ('cash', 'card', 'bitcoin');
CREATE TYPE level_t AS ENUM ('economy', 'comfort', 'lux');

CREATE TABLE addresses
(
  id       INT PRIMARY KEY,
  country  VARCHAR(200) NOT NULL,
  city     VARCHAR(200) NOT NULL,
  street   VARCHAR(200) NOT NULL,
  building VARCHAR(200) NOT NULL
);

CREATE TABLE taxi_drivers
(
  id          INT PRIMARY KEY,
  full_name   VARCHAR(100) NOT NULL,
  license_num INT          NOT NULL
);

CREATE TABLE taxi_users
(
  id           INT PRIMARY KEY,
  full_name    VARCHAR(100) NOT NULL,
  pass_hash    TEXT         NOT NULL,
  home_addr_id INT REFERENCES addresses (id),
  work_addr_id INT REFERENCES addresses (id)
);

CREATE TABLE cars
(
  id          INT PRIMARY KEY,
  brand       VARCHAR(50)   NOT NULL,
  level       level_t       NOT NULL,
  capacity    NUMERIC(2, 0) NOT NULL,
  numberplate VARCHAR(15)   NOT NULL
);

CREATE TABLE taxi_parks
(
  id    INT PRIMARY KEY,
  name  VARCHAR(50) NOT NULL,
  email VARCHAR(60) NOT NULL
);

CREATE TABLE owned_cars
(
  car_id     INT PRIMARY KEY REFERENCES cars (id),
  park_id    INT NOT NULL REFERENCES taxi_parks (id),
  rent_price INT NOT NULL
);

CREATE TABLE rides
(
  id             INT PRIMARY KEY,
  src_id         INT            NOT NULL REFERENCES addresses (id),
  dst_id         INT            NOT NULL REFERENCES addresses (id),
  start_time     TIMESTAMP      NOT NULL,
  end_time       TIMESTAMP      NOT NULL,
  payment_type   payment_type_t NOT NULL,
  price          INT            NOT NULL,
  level          level_t        NOT NULL,
  passengers_cnt NUMERIC(2, 0)  NOT NULL,
  driver_id      INT            NOT NULL REFERENCES taxi_drivers (id),
  car_id         INT            NOT NULL REFERENCES cars (id),
  user_id        INT            NOT NULL REFERENCES taxi_users (id),
  distance       INT            NOT NULL
);

CREATE TABLE ongoing_rides
(
  src_id         INT           NOT NULL REFERENCES addresses (id),
  dst_id         INT           NOT NULL REFERENCES addresses (id),
  start_time     TIMESTAMP,
  level          level_t       NOT NULL,
  passengers_cnt NUMERIC(2, 0) NOT NULL,
  user_id        INT PRIMARY KEY REFERENCES taxi_users (id),
  car_id         INT UNIQUE    NOT NULL REFERENCES cars (id),
  driver_id      INT UNIQUE    NOT NULL REFERENCES taxi_drivers (id)
);