create table if not exists change_tracking (
  id integer auto_increment primary key,
  table_name varchar(255),
  pri_key_name varchar(255),
  pri_key_value varchar(255),
  action varchar(255),
  updated_at timestamp
);

SELECT CONCAT(
    'CREATE TRIGGER ', table_name, '_after_insert AFTER INSERT ON ', table_name, 
    ' FOR EACH ROW INSERT INTO change_tracking (table_name, pri_key_name, pri_key_value, action) VALUES (\''
    , table_name, '\', ', '\'', group_concat(distinct column_name separator ',\'|\','), '\', concat(new.'
    , group_concat(distinct column_name separator ', new.')
    , '), \'insert\');',
    'CREATE TRIGGER ', table_name, '_after_update AFTER UPDATE ON ', table_name, 
    ' FOR EACH ROW INSERT INTO change_tracking (table_name, pri_key_name, pri_key_value, action) VALUES (\''
    , table_name, '\', ', '\'', group_concat(distinct column_name separator ',\'|\','), '\', concat(new.'
    , group_concat(distinct column_name separator ', new.')
    , '), \'update\');',
    'CREATE TRIGGER ', table_name, '_after_delete AFTER DELETE ON ', table_name, 
    ' FOR EACH ROW INSERT INTO change_tracking (table_name, pri_key_name, pri_key_value, action) VALUES (\''
    , table_name, '\', ', '\'', group_concat(distinct column_name separator ',\'|\','), '\', concat(old.'
    , group_concat(distinct column_name separator ', old.')
    , '), \'delete\');'
)
from information_schema.columns where column_key='PRI' group by table_name;

drop table change_tracking;
SELECT CONCAT(
    'DROP TRIGGER ', table_name, '_after_insert;',
    'DROP TRIGGER ', table_name, '_after_update;',
    'DROP TRIGGER ', table_name, '_after_delete;'
)
from information_schema.columns where column_key='PRI' group by table_name;




CREATE TRIGGER webform_after_insert AFTER INSERT ON webform   
FOR EACH ROW INSERT INTO change_tracking (table_name, pri_key_name, pri_key_value, action) 
values (   'webform', 'nid', new.nid, 'insert' );



table_name, group_concat(distinct column_name separator ',\'|\',') from information_schema.columns where column_key='PRI' group by table_name;
    