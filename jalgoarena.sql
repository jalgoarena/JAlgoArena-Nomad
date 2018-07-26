CREATE DATABASE IF NOT EXISTS jalgoarena;
CREATE USER IF NOT EXISTS jalgo;
GRANT ALL ON DATABASE jalgoarena TO jalgo;

CREATE TABLE users (
	id INTEGER NOT NULL,
	email STRING(255) NOT NULL,
	firstname STRING(255) NOT NULL,
	password STRING(255) NOT NULL,
	region STRING(255) NOT NULL,
	role STRING(255) NOT NULL,
	surname STRING(255) NOT NULL,
	team STRING(255) NOT NULL,
	username STRING(255) NOT NULL,
	CONSTRAINT "primary" PRIMARY KEY (id ASC),
	UNIQUE INDEX uk_6dotkott2kjsp8vw4d0m25fb7 (email ASC),
	UNIQUE INDEX uk_r43af9ap4edm43mmtq01oddj6 (username ASC),
	FAMILY "primary" (id, email, firstname, password, region, role, surname, team, username)
);