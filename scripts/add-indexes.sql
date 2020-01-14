-- indexes on foreign keys
CREATE INDEX ON owned_cars (car_id);
CREATE INDEX ON owned_cars (park_id);
CREATE INDEX ON rides (src_id);
CREATE INDEX ON rides (dst_id);
CREATE INDEX ON ongoing_rides (src_id);
CREATE INDEX ON ongoing_rides (dst_id);

-- boost time queries
CREATE INDEX ON rides USING btree (start_time, end_time);

-- boost level search
CREATE INDEX ON cars (level);