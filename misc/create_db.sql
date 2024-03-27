CREATE DATABASE [wtdb] ON PRIMARY (
  NAME = [wtdb],
  FILENAME = '/var/opt/mssql/data/wtdb.mdf',
  SIZE = 5 MB,
  FILEGROWTH = 10%
),
FILEGROUP BLOBS (
  NAME = BLOBS,
  FILENAME = '/var/opt/mssql/data/wtdb_blobs.mdf',
  SIZE = 5 MB,
  FILEGROWTH = 10%
),
FILEGROUP IDX (
  NAME = IDX,
  FILENAME = '/var/opt/mssql/data/wtdb_idx.mdf',
  SIZE = 5 MB,
  FILEGROWTH=10%
),
FILEGROUP FT_IDX (
  NAME = FT_IDX,
  FILENAME = '/var/opt/mssql/data/wtdb_ft_idx.mdf',
  SIZE = 5 MB,
  FILEGROWTH=10%
) LOG ON (
  NAME = LOG,
  FILENAME = '/var/opt/mssql/data/wtdb.ldf',
  SIZE = 1 MB,
  FILEGROWTH=10%
);