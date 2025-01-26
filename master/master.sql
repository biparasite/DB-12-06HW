CREATE USER 'replication_user'@'%.' IDENTIFIED BY 'replication_user';
GRANT REPLICATION SLAVE ON *.* TO 'replication_user'@'%';
UPDATE mysql.user SET Super_Priv='Y' WHERE user='replication_user' AND host='%';
FLUSH PRIVILEGES;

