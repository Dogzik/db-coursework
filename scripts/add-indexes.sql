-- indexes on foreign keys
CREATE INDEX ON owned_cars USING hash (park_id);
CREATE INDEX ON rides USING btree (src_id, dst_id);
CREATE INDEX ON rides USING btree (dst_id, src_id);
CREATE INDEX ON ongoing_rides USING btree (src_id, dst_id);
CREATE INDEX ON ongoing_rides USING btree (dst_id, src_id);

-- boost time queries
CREATE INDEX ON rides USING btree (start_time, end_time);

-- boost constraints
CREATE INDEX ON rides USING btree (user_id, end_time);

-- boost level search
CREATE INDEX ON cars (level);