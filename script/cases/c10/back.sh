#!/bin/bash
  
psql postgres<< EOF
BEGIN;
INSERT INTO plan SELECT id + 2000001,typ,current_date + id * '1 seconds'::interval ,val FROM plan where id < 500000;
commit;
BEGIN;
INSERT INTO plan SELECT id + 2500001,typ,current_date + id * '1 seconds'::interval ,val FROM plan where id < 500000;
commit;
BEGIN;
INSERT INTO plan SELECT id + 3000001,typ,current_date + id * '1 seconds'::interval ,val FROM plan where id < 500000;
commit;
BEGIN;
INSERT INTO plan SELECT id + 3500001,typ,current_date + id * '1 seconds'::interval ,val FROM plan where id < 500000;
commit;
BEGIN;
INSERT INTO plan SELECT id + 4000001,typ,current_date + id * '1 seconds'::interval ,val FROM plan where id < 500000;
commit;
BEGIN;
INSERT INTO plan SELECT id + 4500001,typ,current_date + id * '1 seconds'::interval ,val FROM plan where id < 500000;
commit;
BEGIN;
INSERT INTO plan SELECT id + 5000001,typ,current_date + id * '1 seconds'::interval ,val FROM plan where id < 500000;
commit;
BEGIN;
INSERT INTO plan SELECT id + 5500001,typ,current_date + id * '1 seconds'::interval ,val FROM plan where id < 500000;
commit;
BEGIN;
INSERT INTO plan SELECT id + 6000001,typ,current_date + id * '1 seconds'::interval ,val FROM plan where id < 500000;
commit;
BEGIN;
INSERT INTO plan SELECT id + 6500001,typ,current_date + id * '1 seconds'::interval ,val FROM plan where id < 500000;
commit;
BEGIN;
INSERT INTO plan SELECT id + 7000001,typ,current_date + id * '1 seconds'::interval ,val FROM plan where id < 500000;
commit;
BEGIN;
INSERT INTO plan SELECT id + 7500001,typ,current_date + id * '1 seconds'::interval ,val FROM plan where id < 500000;
commit;
BEGIN;
INSERT INTO plan SELECT id + 8000001,typ,current_date + id * '1 seconds'::interval ,val FROM plan where id < 500000;
commit;
BEGIN;
INSERT INTO plan SELECT id + 8500001,typ,current_date + id * '1 seconds'::interval ,val FROM plan where id < 500000;
commit;
BEGIN;
INSERT INTO plan SELECT id + 9000001,typ,current_date + id * '1 seconds'::interval ,val FROM plan where id < 500000;
commit;
BEGIN;
INSERT INTO plan SELECT id + 9500001,typ,current_date + id * '1 seconds'::interval ,val FROM plan where id < 500000;
commit;
BEGIN;
INSERT INTO plan SELECT id + 10000001,typ,current_date + id * '1 seconds'::interval ,val FROM plan where id < 500000;
commit;
EOF

