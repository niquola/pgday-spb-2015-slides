Time: 283.697 ms sql
Time: 1132.362 ms v8
Time: 1429.812 ms pl


3.734283SELECT :aid + i from generate_series(0,10000) i;
4.116957SELECT sql_add(:aid, i)  from generate_series(0,10000) i;
11.593530SELECT v8_add(:aid, i) from generate_series(0,10000) i;
18.006653SELECT pl_add(:aid, i) from generate_series(0,10000) i;

10.182467SELECT (('{"a":' || i || '}')::json)->>'a' from generate_series(0,10000) i;
45.561677SELECT v8_get(('{"a":' || i || '}')::json,'a') from generate_series(0,10000) i;
29.446960SELECT pl_get(('{"a":' || i || '}')::json,'a') from generate_series(0,10000) i;

58.849527SELECT v8_iter(('{a,b,c,d,e,f,g' || i || '}')::text[],i::text) from generate_series(0,10000) i;
70.493943SELECT pl_iter(('{a,b,c,d,e,f,g' || i || '}')::text[],i::text) from generate_series(0,10000) i;

64.525520SELECT v8_exec(i) from generate_series(0,1000) i;
51.357317SELECT pl_exec(i) from generate_series(0,1000) i;

6.317000 select v8_poly(10) from generate_series(0,3) i;
1314.272210  select pl_poly(10) from generate_series(0,3) i;

8.902307 select pl_str(E'a b\nc ' || i) from generate_series(0,1000) i;
4.898727 select v8_str(E'a b\nc ' || i) from generate_series(0,1000) i;
