--db:pgbench
--{{{
CREATE EXTENSION plv8;

-- noop
CREATE OR REPLACE FUNCTION v8_noop(x text) RETURNS text AS $$
return x
$$ LANGUAGE plv8 IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION pl_noop(x text) RETURNS text AS $$
begin
  return x;
end
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION sql_noop(x text) RETURNS text AS $$
select x
$$ LANGUAGE sql IMMUTABLE STRICT;

-- add

CREATE OR REPLACE FUNCTION sql_add(x bigint, y bigint ) RETURNS bigint AS $$
 select x + y
$$ LANGUAGE sql IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION v8_add(x bigint, y bigint ) RETURNS bigint AS $$
 return x + y
$$ LANGUAGE plv8 IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION pl_add(x bigint, y bigint ) RETURNS bigint AS $$
begin
 return x + y;
end
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

-- get key

CREATE OR REPLACE FUNCTION v8_get(x json, y text ) RETURNS text AS $$
 return x[y]
$$ LANGUAGE plv8 IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION pl_get(x json, y text ) RETURNS text AS $$
begin
 return x->>y;
end
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

-- iterate

CREATE OR REPLACE FUNCTION v8_iter(x text[], match text) RETURNS bigint AS $$
 var count = 0;
 for(var i = 0; i < x.length; i++){
   if(x[i] == match){
    count++
   }
 }
 return count
$$ LANGUAGE plv8 IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION pl_iter(x text[], match text) RETURNS bigint AS $$
DECLARE
  count bigint;
  i text;
begin
  count := 0;
  FOREACH i IN ARRAY x
  LOOP
    IF i = match THEN
      count := count + 1;
    END IF;
  END LOOP;
  RETURN count;
end
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

-- execute

drop table if exists users;
create table users (id serial, label text);
insert into users (label) values ('a'),('b'),('c');

CREATE OR REPLACE FUNCTION v8_exec(i bigint) RETURNS json AS $$
  res = plv8.execute('SELECT * FROM users where id=$1 limit 1', [i%3])
  return res;
$$ LANGUAGE plv8 IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION pl_exec(i bigint) RETURNS json AS $$
declare
  res json;
begin
  execute 'SELECT json_agg(u.*) FROM users u where id=$1 limit 1'
  using i%3
  into res;
  return res;
end
$$ LANGUAGE plpgsql IMMUTABLE STRICT;

-- polynomial alg

CREATE OR REPLACE FUNCTION v8_poly(x bigint) RETURNS numeric AS $$
 var n = 5000
 var mu = 10.0
 var pu = 0.0
 var su = 0.0;
 var pol =[];

 for(var i=0; i< n; i++){
   for(var j=0; j< 100; j++){
      pol[j] = mu = (mu + 2.0) / 2.0
   }
   su = 0.0
   for(var j=0; j< 100; j++){
      su = x * su + pol[j]
   }
   pu = pu + su;
 }
 return pu
$$ LANGUAGE plv8 IMMUTABLE STRICT;


CREATE OR REPLACE FUNCTION pl_poly(x bigint) RETURNS numeric AS $$
declare
 n bigint := 5000;
 mu numeric := 10.0;
 pu numeric := 0.0;
 su numeric := 0.0;
 pol numeric[] = '{}'::numeric[];
 i bigint;
begin
  FOR i IN 1 .. n
  LOOP
    FOR j IN 1 ..100
    LOOP
      mu := (mu + 2.0) / 2.0;
      pol[j] := mu;
    END LOOP;
    su := 0.0;
    FOR j IN 1 ..100
    LOOP
      su := x * su + pol[j];
    END LOOP;
    pu := pu + su;
  END LOOP;
  RETURN pu;
end
$$ LANGUAGE plpgsql IMMUTABLE STRICT;
select v8_poly(10);
select pl_poly(10);

-- string ops

CREATE OR REPLACE FUNCTION v8_str(inp text) RETURNS text AS $$
  return inp.split("\n").map(function(x){
    if(x){
    var parts = x.split(" ")
      return ["<",parts[0],">", parts[1], "</", parts[0], ">"].join('')
    }else{
      return ''
    }
  }).join("\n")
$$ LANGUAGE plv8 IMMUTABLE STRICT;


CREATE OR REPLACE FUNCTION pl_str(inp text) RETURNS text AS $$
declare
 parts text[];
 x text;
 res text;
begin
  res := ''::text;
  FOREACH x IN ARRAY string_to_array(inp, E'\n')
  LOOP
    IF x <> '' THEN
      parts := string_to_array(x,E' ');
      res := res || '\n' || '<' || (parts)[1] || '>' || (parts)[2] || '</' || (parts)[1] || '>';
    END IF;
  END LOOP;
  return res;
end
$$ LANGUAGE plpgsql IMMUTABLE STRICT;
--}}}
