
USE master;

IF NOT EXISTS (
  SELECT
    name
  FROM master.sys.server_principals
  WHERE name = 'webtutor'
)
BEGIN
    CREATE LOGIN webtutor WITH PASSWORD = 'Webtutor1';
    CREATE USER webtutor FOR LOGIN webtutor;
    ALTER SERVER ROLE dbcreator ADD MEMBER webtutor;
    print 'User webtutor successfully created'
END
ELSE
BEGIN
    print 'User webtutor already exist'
END
