CREATE DATABASE IF NOT EXISTS jalgoarena;
CREATE USER IF NOT EXISTS jalgo;
GRANT ALL ON DATABASE jalgoarena TO jalgo;

CREATE TABLE users (
	id BIGINT NOT NULL,
	email STRING(255) NULL,
	password STRING(255) NULL,
	region STRING(255) NULL,
	role STRING(255) NULL,
	team STRING(255) NULL,
	username STRING(255) NULL,
	CONSTRAINT "primary" PRIMARY KEY (id ASC),
	FAMILY "primary" (id, email, password, region, role, team, username)
)