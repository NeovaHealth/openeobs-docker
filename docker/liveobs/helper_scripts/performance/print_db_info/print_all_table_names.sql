select table_schema, table_name
from information_schema.tables
where
  table_schema = 'public'
  and table_type='BASE TABLE'
;