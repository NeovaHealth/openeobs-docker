select
    att2.attname as "child_column",
    cl.relname as "parent_table",
    att.attname as "parent_column"
from
   (select
        unnest(con1.conkey) as "parent",
        unnest(con1.confkey) as "child",
        con1.confrelid,
        con1.conrelid
    from
        pg_class cl
        join pg_namespace ns on cl.relnamespace = ns.oid
        join pg_constraint con1 on con1.conrelid = cl.oid
    where
        cl.relname = 'nh_activity'
        and ns.nspname = 'public'
        and con1.contype = 'f'
   ) con
   join pg_attribute att on
       att.attrelid = con.confrelid and att.attnum = con.child
   join pg_class cl on
       cl.oid = con.confrelid
   join pg_attribute att2 on
       att2.attrelid = con.conrelid and att2.attnum = con.parent
;