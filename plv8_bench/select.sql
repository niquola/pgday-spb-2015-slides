\set nbranches :scale
\set ntellers 10 * :scale
\set naccounts 100000 * :scale
\setrandom aid 1 :naccounts
\setrandom bid 1 :nbranches
\setrandom tid 1 :ntellers
\setrandom delta -5000 5000

SELECT :aid + i from generate_series(0,10000) i;
SELECT sql_add(:aid, i)  from generate_series(0,10000) i;
SELECT v8_add(:aid, i) from generate_series(0,10000) i;
SELECT pl_add(:aid, i) from generate_series(0,10000) i;

SELECT (('{"a":' || i || '}')::json)->>'a' from generate_series(0,10000) i;

SELECT v8_get(('{"a":' || i || '}')::json,'a') from generate_series(0,10000) i;

SELECT pl_get(('{"a":' || i || '}')::json,'a') from generate_series(0,10000) i;

SELECT v8_iter(('{a,b,c,d,e,f,g' || i || '}')::text[],i::text) from generate_series(0,10000) i;
SELECT pl_iter(('{a,b,c,d,e,f,g' || i || '}')::text[],i::text) from generate_series(0,10000) i;


SELECT v8_exec(i) from generate_series(0,1000) i;
SELECT pl_exec(i) from generate_series(0,1000) i;

--select v8_poly(10) from generate_series(0,3) i;
--select pl_poly(10) from generate_series(0,3) i;

select pl_str(E'a b\nc ' || i) from generate_series(0,1000) i;
select v8_str(E'a b\nc ' || i) from generate_series(0,1000) i;

