-- Create the database
CREATE DATABASE IF NOT EXISTS machina_labs;
USE machina_labs;

CREATE TABLE customer (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uuid CHAR(36) NOT NULL UNIQUE,
  INDEX (uuid),
  name VARCHAR(255) NOT NULL
);

CREATE TABLE part (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uuid CHAR(36) NOT NULL UNIQUE,
  INDEX (uuid),
  name VARCHAR(255) NOT NULL,
  customer_uuid CHAR(36) NOT NULL,
  FOREIGN KEY (customer_uuid) REFERENCES customer (uuid)
);

CREATE TABLE file (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uuid CHAR(36) NOT NULL UNIQUE,
  INDEX (uuid),
  type VARCHAR(255) NOT NULL,
  location VARCHAR(255) NOT NULL
);

CREATE TABLE part_revision (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uuid CHAR(36) NOT NULL UNIQUE,
  INDEX (uuid),
  name VARCHAR(255) NOT NULL,
  part_uuid CHAR(36) NOT NULL,
  FOREIGN KEY (part_uuid) REFERENCES part (uuid),
  geometry_file_uuid CHAR(36) NOT NULL,
  FOREIGN KEY (geometry_file_uuid) REFERENCES file (uuid)
);

CREATE TABLE trial (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uuid CHAR(36) NOT NULL UNIQUE,
  INDEX (uuid),
  part_revision_uuid CHAR(36) NOT NULL,
  FOREIGN KEY (part_revision_uuid) REFERENCES part_revision (uuid),
  success BOOLEAN
);

CREATE TABLE process_run (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uuid CHAR(36) NOT NULL UNIQUE,
  INDEX (uuid),
  type VARCHAR(255) NOT NULL,
  trial_uuid CHAR(36) NOT NULL,
  FOREIGN KEY (trial_uuid) REFERENCES trial (uuid)
);

CREATE TABLE process_run_file_artifact (
  id INT AUTO_INCREMENT PRIMARY KEY,
  uuid CHAR(36) NOT NULL UNIQUE,
  INDEX (uuid),
  process_run_uuid CHAR(36) NOT NULL,
  FOREIGN KEY (process_run_uuid) REFERENCES process_run (uuid),
  file_artifact_uuid CHAR(36) NOT NULL,
  FOREIGN KEY (file_artifact_uuid) REFERENCES file (uuid)
);

--
-- Create seed data
--

INSERT INTO customer (uuid, name) VALUES
('d4b11d78-74e2-4efb-987c-38e2eb1a7a02', 'Customer A'),
('a0373fc3-f7f3-42ec-aa7d-222f16b35c88', 'Customer B');

INSERT INTO part (uuid, name, customer_uuid) VALUES
('4ca4f320-536c-4b2e-b63f-80c4a55b719d', 'Flange', 'd4b11d78-74e2-4efb-987c-38e2eb1a7a02'),
('d45f5112-1c67-49ef-a61d-16b1f3d3be7c', 'Stiffener', 'a0373fc3-f7f3-42ec-aa7d-222f16b35c88');

INSERT INTO file (uuid, type, location) VALUES
-- Customer A
('263950c7-7fd2-457c-8d53-b93a1bb36dd8', 'CAD', 'customers/d4b11d78-74e2-4efb-987c-38e2eb1a7a02/parts/4ca4f320-536c-4b2e-b63f-80c4a55b719d/revisions/d09f9cc9-30cc-480d-8d15-f1e5de5c5f1a/flange.stl'),
('b2a3e3f1-2bc7-4502-8f14-7d923c1169a7', 'CAD', 'customers/d4b11d78-74e2-4efb-987c-38e2eb1a7a02/parts/4ca4f320-536c-4b2e-b63f-80c4a55b719d/revisions/cc50e60d-42c3-4a30-9c1b-8a8e0d2e0717/flange.step'),
('63c9e303-0d3e-4150-8c42-44d989e6a906', 'FormPath', 'customers/d4b11d78-74e2-4efb-987c-38e2eb1a7a02/parts/4ca4f320-536c-4b2e-b63f-80c4a55b719d/trials/0e7c36da-4125-4c13-8e5b-2e1a3d51c57e/form_path.csv'),
('e76f9b0d-8c52-41e1-987d-14970c1d5420', 'FormBuild', 'customers/d4b11d78-74e2-4efb-987c-38e2eb1a7a02/parts/4ca4f320-536c-4b2e-b63f-80c4a55b719d/trials/0e7c36da-4125-4c13-8e5b-2e1a3d51c57e/form_build.csv'),
('c620d16d-dae1-4e9f-b8c4-6dc212a4d779', 'FormBuild', 'customers/d4b11d78-74e2-4efb-987c-38e2eb1a7a02/parts/4ca4f320-536c-4b2e-b63f-80c4a55b719d/trials/b58fb2c9-5a3d-44a0-89ef-ecb510883a1a/form_build.csv'),
('e5cb6a8e-9ff2-4d60-a6e7-731c0ad0f321', 'RSILog', 'customers/d4b11d78-74e2-4efb-987c-38e2eb1a7a02/parts/4ca4f320-536c-4b2e-b63f-80c4a55b719d/trials/b58fb2c9-5a3d-44a0-89ef-ecb510883a1a/rsi1way_c1r1_state.log'),
('79f4e4a8-b9f9-47d4-b1a7-f1410c52543d', 'ScanLog', 'customers/d4b11d78-74e2-4efb-987c-38e2eb1a7a02/parts/4ca4f320-536c-4b2e-b63f-80c4a55b719d/trials/b58fb2c9-5a3d-44a0-89ef-ecb510883a1a/scanner_c1r1.log'),
('b3f60ab7-38c8-4d7d-9d2c-d7c723b9132d', 'ScanMesh', 'customers/d4b11d78-74e2-4efb-987c-38e2eb1a7a02/parts/4ca4f320-536c-4b2e-b63f-80c4a55b719d/trials/b58fb2c9-5a3d-44a0-89ef-ecb510883a1a/scan_mesh.ply'),
('9d3b2d58-587e-40b1-94b8-517ecf251789', 'ZMetric', 'customers/d4b11d78-74e2-4efb-987c-38e2eb1a7a02/parts/4ca4f320-536c-4b2e-b63f-80c4a55b719d/trials/b58fb2c9-5a3d-44a0-89ef-ecb510883a1a/zmetric.json'),
-- Customer B
('a144ca90-fc88-4d0c-9e06-6dcf71df46b7', 'CAD', 'customers/a0373fc3-f7f3-42ec-aa7d-222f16b35c882/parts/d45f5112-1c67-49ef-a61d-16b1f3d3be7c/revisions/d09f9cc9-30cc-480d-8d15-f1e5de5c5f1a/stiffener.stl'),
('3d47c4e4-4a8d-4d70-930b-73abf576e31f', 'FormPath', 'customers/a0373fc3-f7f3-42ec-aa7d-222f16b35c882/parts/d45f5112-1c67-49ef-a61d-16b1f3d3be7c/trials/279b93c7-d0d9-48f7-8098-08712d7c775d/form_path.csv'),
('fc2b4794-6a4d-4ad4-b2c7-cd360b18f392', 'FormBuild', 'customers/a0373fc3-f7f3-42ec-aa7d-222f16b35c882/parts/d45f5112-1c67-49ef-a61d-16b1f3d3be7c/trials/279b93c7-d0d9-48f7-8098-08712d7c775d/form_build.csv');

INSERT INTO part_revision (uuid, name, part_uuid, geometry_file_uuid) VALUES
('6cb8d42a-10e1-4522-a7a6-8a714d7e22b9', 'Original', '4ca4f320-536c-4b2e-b63f-80c4a55b719d', '263950c7-7fd2-457c-8d53-b93a1bb36dd8'),
('cc50e60d-42c3-4a30-9c1b-8a8e0d2e0717', 'Prepped', '4ca4f320-536c-4b2e-b63f-80c4a55b719d', 'b2a3e3f1-2bc7-4502-8f14-7d923c1169a7'),
('d09f9cc9-30cc-480d-8d15-f1e5de5c5f1a', 'Original', 'd45f5112-1c67-49ef-a61d-16b1f3d3be7c', 'a144ca90-fc88-4d0c-9e06-6dcf71df46b7');

INSERT INTO trial (uuid, part_revision_uuid, success) VALUES
('0e7c36da-4125-4c13-8e5b-2e1a3d51c57e', '6cb8d42a-10e1-4522-a7a6-8a714d7e22b9', false),
('b58fb2c9-5a3d-44a0-89ef-ecb510883a1a', 'cc50e60d-42c3-4a30-9c1b-8a8e0d2e0717', true),
('279b93c7-d0d9-48f7-8098-08712d7c775d', 'd09f9cc9-30cc-480d-8d15-f1e5de5c5f1a', NULL);

INSERT INTO process_run (uuid, type, trial_uuid) VALUES
('7a5754a4-6f10-4d37-a44a-93060ed34d3d', 'Form', '0e7c36da-4125-4c13-8e5b-2e1a3d51c57e'),
('1a668cc0-4f56-4d8a-9d2b-1b901eb4a615', 'Form', 'b58fb2c9-5a3d-44a0-89ef-ecb510883a1a'),
('bf3edc89-0585-4d5b-8bc8-77db25b34dc3', 'Scan', 'b58fb2c9-5a3d-44a0-89ef-ecb510883a1a'),
('d61e63c4-fb4e-4cda-99e4-d6c156e00df8', 'Form', '279b93c7-d0d9-48f7-8098-08712d7c775d'),
('7b8e97d1-2aef-4c99-96d8-3b3a87860e5e', 'Scan', '279b93c7-d0d9-48f7-8098-08712d7c775d');

INSERT INTO process_run_file_artifact (uuid, process_run_uuid, file_artifact_uuid) VALUES
('a75b48c1-ef28-435d-ae86-b260547c9dbd', '7a5754a4-6f10-4d37-a44a-93060ed34d3d', '63c9e303-0d3e-4150-8c42-44d989e6a906'),
('1e4df7f9-f1db-4568-9c89-8775417b0d60', '7a5754a4-6f10-4d37-a44a-93060ed34d3d', 'e76f9b0d-8c52-41e1-987d-14970c1d5420'),
('5a114e32-9b17-4c36-9e25-849d02f2e102', '1a668cc0-4f56-4d8a-9d2b-1b901eb4a615', 'c620d16d-dae1-4e9f-b8c4-6dc212a4d779'),
('2a916264-7483-4b54-bc13-15f89ec9f1b8', 'bf3edc89-0585-4d5b-8bc8-77db25b34dc3', 'e5cb6a8e-9ff2-4d60-a6e7-731c0ad0f321'),
('e481b201-2c47-49d3-9f6a-8506ad4c4cb4', 'bf3edc89-0585-4d5b-8bc8-77db25b34dc3', '79f4e4a8-b9f9-47d4-b1a7-f1410c52543d'),
('726cb01e-6da4-4a83-a07e-80e785e79896', 'bf3edc89-0585-4d5b-8bc8-77db25b34dc3', 'b3f60ab7-38c8-4d7d-9d2c-d7c723b9132d'),
('9f8cc8b2-ff17-4ef1-a95c-26502f0d68c3', 'bf3edc89-0585-4d5b-8bc8-77db25b34dc3', '9d3b2d58-587e-40b1-94b8-517ecf251789'),
('a9c5295d-28a0-42f7-913c-d68b70555a92', 'd61e63c4-fb4e-4cda-99e4-d6c156e00df8', '3d47c4e4-4a8d-4d70-930b-73abf576e31f'),
('e28e3db3-55aa-49e7-bf92-165c2db894e1', 'd61e63c4-fb4e-4cda-99e4-d6c156e00df8', 'fc2b4794-6a4d-4ad4-b2c7-cd360b18f392');