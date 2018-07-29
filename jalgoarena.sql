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

CREATE TABLE submissions (
	id INTEGER NOT NULL,
	consumed_memory BIGINT NOT NULL,
	elapsed_time DOUBLE PRECISION NOT NULL,
	error_message STRING(255) NULL,
	failed_test_cases INTEGER NULL,
	passed_test_cases INTEGER NULL,
	problem_id STRING(255) NOT NULL,
	source_code STRING(20000) NOT NULL,
	status_code STRING(255) NOT NULL,
	submission_id STRING(255) NOT NULL,
	submission_time TIMESTAMP NOT NULL,
	token STRING(255) NULL,
	user_id STRING(255) NOT NULL,
	CONSTRAINT "primary" PRIMARY KEY (id ASC),
	UNIQUE INDEX uk_51d698q9pdvfldc75kskyxmlf (submission_id ASC),
	FAMILY "primary" (id, consumed_memory, elapsed_time, error_message, failed_test_cases, passed_test_cases, problem_id, source_code, status_code, submission_id, submission_time, token, user_id)
);