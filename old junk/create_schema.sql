DROP DATABASE IF EXISTS green_line_records;
CREATE DATABASE green_line_records;

USE green_line_records;

/** TODO:

*instead of contributions table, we could break contributions into separate tables:
-member_produces_video ~~release date of video
-member_works_event ~~event date
-recording_assignment ~~date of master completion
-member_publicizes_artist ~~release date
-member_designs_something? ~~date of completed design
-(ar_rep attribute of artist/project) ~~release date



-eboard name identifier should be title/role, not member name (update conversion function and get data stored procedure)

dept membership for video & events
add more releases
projects need a "date added"
populate contributions
login credentials (not a priority for class submission)
find a way to translate foreign keys and many-to-many tables into user-friendly data in web app

PROCEDURES:
set active members based on who has made a contribution this semester?
update voting privileges based on projects/contributions
update engineer roles/send email to head of recording
stuff from presentation that's not here

TRIGGERS?:
when a release is added, update project status to 'released'

BEFORE SUBMISSION:
set foreign key checks = 1
organize sql files
resolve all TODOs
remove comments

FUTURE:
add plays/reach
*/

-- club_member --
DROP TABLE IF EXISTS club_member;
CREATE TABLE club_member (
  member_id INT         NOT NULL UNIQUE AUTO_INCREMENT,
  email     VARCHAR(50) NULL UNIQUE,
  lastname  VARCHAR(50) NOT NULL,
  firstname VARCHAR(50) NOT NULL,
  PRIMARY KEY (member_id)
);

-- project --
DROP TABLE IF EXISTS project;
CREATE TABLE project (
  project_id INT                                                                   NOT NULL UNIQUE AUTO_INCREMENT,
  title      VARCHAR(100)                                                          NOT NULL,
  type       ENUM ('Single', 'EP', 'Album', 'Video', 'Other')                      NOT NULL,
  status     ENUM ('Unconfirmed', 'Confirmed', 'Scheduled',
                   'In-Progress', 'Completed', 'On Hold', 'Cancelled', 'Released') NOT NULL,
  rep_id     INT                                                                   NULL,
  PRIMARY KEY (project_id),
  INDEX project_rep_idx (rep_id ASC),
  FOREIGN KEY (rep_id)
  REFERENCES club_member (member_id)
);

-- genre --
DROP TABLE IF EXISTS genre;
CREATE TABLE genre (
  genre_id   INT                NOT NULL UNIQUE AUTO_INCREMENT,
  genre_name VARCHAR(50) UNIQUE NOT NULL,
  PRIMARY KEY (genre_id)
);

-- genre_of_project --
DROP TABLE IF EXISTS genre_of_project;
CREATE TABLE genre_of_project (
  project_id INT NOT NULL,
  genre_id   INT NOT NULL,
  PRIMARY KEY (project_id, genre_id),
  FOREIGN KEY (project_id)
  REFERENCES project (project_id),
  FOREIGN KEY (genre_id)
  REFERENCES genre (genre_id)
);

-- marketing_assignment --
DROP TABLE IF EXISTS marketing_assignment;
CREATE TABLE marketing_assignment (
  project_id          INT NOT NULL,
  campaign_manager_id INT NOT NULL,
  PRIMARY KEY (project_id, campaign_manager_id),
  INDEX marketing_assignment_project_idx (project_id ASC),
  INDEX marketing_assignment_member_id_idx (campaign_manager_id ASC),
  FOREIGN KEY (project_id)
  REFERENCES project (project_id),
  FOREIGN KEY (campaign_manager_id)
  REFERENCES club_member (member_id)
);

-- ar_member --
# DROP TABLE IF EXISTS ar_member;
# CREATE TABLE ar_member (
#   ar_member_id   INT NOT NULL UNIQUE AUTO_INCREMENT,
#   club_member_id INT NOT NULL UNIQUE,
#   PRIMARY KEY (ar_member_id),
#   INDEX ar_member_club_member (club_member_id ASC),
#   FOREIGN KEY (club_member_id)
#   REFERENCES club_member (member_id)
# );

-- artist --
DROP TABLE IF EXISTS artist;
CREATE TABLE artist (
  artist_id   INT         NOT NULL UNIQUE AUTO_INCREMENT,
  artist_name VARCHAR(80) NOT NULL,
  PRIMARY KEY (artist_id)
);

-- artist_writes_project --
DROP TABLE IF EXISTS artist_writes_project;
CREATE TABLE artist_writes_project (
  project_id INT NOT NULL,
  artist_id  INT NOT NULL,
  PRIMARY KEY (project_id, artist_id),
  INDEX artist_writes_project_artist_idx (artist_id ASC),
  INDEX artist_writes_project_project_idx (project_id ASC),
  FOREIGN KEY (project_id)
  REFERENCES project (project_id),
  FOREIGN KEY (artist_id)
  REFERENCES artist (artist_id)
);

-- engineer --
DROP TABLE IF EXISTS engineer;
CREATE TABLE engineer (
  engineer_id INT                               NOT NULL UNIQUE AUTO_INCREMENT,
  member_id   INT UNIQUE                        NOT NULL,
  level       ENUM ('Assistant', 'Lead', 'EIT') NOT NULL,
  PRIMARY KEY (engineer_id),
  INDEX engineer_club_member_idx (member_id ASC),
  FOREIGN KEY (member_id)
  REFERENCES club_member (member_id)
);

-- recording_assignment --
DROP TABLE IF EXISTS recording_assignment;
CREATE TABLE recording_assignment (
  project_id  INT NOT NULL,
  engineer_id INT NOT NULL,
  PRIMARY KEY (project_id, engineer_id),
  INDEX recording_assignment_engineer_idx (engineer_id ASC),
  INDEX recording_assignment_project_idx (project_id ASC),
  FOREIGN KEY (project_id)
  REFERENCES project (project_id),
  FOREIGN KEY (engineer_id)
  REFERENCES engineer (engineer_id)
);

ALTER TABLE recording_assignment
  ADD COLUMN role ENUM ('Assistant', 'Lead', 'EIT') NOT NULL
  AFTER engineer_id;

-- location --
DROP TABLE IF EXISTS location;
CREATE TABLE location (
  location_id   INT         NOT NULL UNIQUE AUTO_INCREMENT,
  location_name varchar(75) NOT NULL UNIQUE,
  PRIMARY KEY (location_id),
  INDEX location_idx (location_id ASC),
  INDEX location_name_idx (location_name ASC)
);

-- live_recording --
DROP TABLE IF EXISTS live_recording;
CREATE TABLE live_recording (
  live_recording_id INT          NOT NULL UNIQUE AUTO_INCREMENT,
  show_name         VARCHAR(150) NOT NULL,
  date              DATE         NOT NULL,
  start_time        TIME         NOT NULL,
  end_time          TIME         NULL,
  location_id       INT          NOT NULL,
  PRIMARY KEY (live_recording_id),
  INDEX live_recording_idx (live_recording_id ASC),
  INDEX live_recording_name_idx (show_name ASC),
  INDEX live_recording_date_idx (date DESC),
  FOREIGN KEY (location_id)
  REFERENCES location (location_id)
);

-- event --
DROP TABLE IF EXISTS `event`;
CREATE TABLE `event` (
  event_id    INT                            NOT NULL UNIQUE AUTO_INCREMENT,
  date        DATETIME                       NOT NULL,
  title       VARCHAR(100)                   NOT NULL,
  description VARCHAR(700)                   NULL,
  turnout     ENUM ('Low', 'Medium', 'High') NULL,
  PRIMARY KEY (event_id)
);

-- booking --
DROP TABLE IF EXISTS booking;
CREATE TABLE booking (
  event_id  INT NOT NULL,
  artist_id INT NOT NULL,
  PRIMARY KEY (event_id, artist_id),
  INDEX booking_artist_idx (artist_id ASC),
  INDEX booking_event_idx (event_id ASC),
  FOREIGN KEY (event_id)
  REFERENCES `event` (event_id),
  FOREIGN KEY (artist_id)
  REFERENCES artist (artist_id)
);

-- assigned_live_recording --
DROP TABLE IF EXISTS assigned_live_recording;
CREATE TABLE assigned_live_recording (
  live_recording_id INT NOT NULL,
  engineer_id       INT NULL,
  INDEX assigned_live_recording_engineer_idx (engineer_id ASC),
  INDEX assigned_live_recording_live_recording_idx (live_recording_id ASC),
  FOREIGN KEY (live_recording_id)
  REFERENCES live_recording (live_recording_id),
  FOREIGN KEY (engineer_id)
  REFERENCES engineer (engineer_id)
);

-- release --
DROP TABLE IF EXISTS `release`;
CREATE TABLE `release` (
  release_id   INT  NOT NULL UNIQUE AUTO_INCREMENT,
  project_id   INT  NOT NULL,
  release_date DATE NOT NULL,
  PRIMARY KEY (release_id),
  INDEX release_project_idx (project_id ASC),
  FOREIGN KEY (project_id)
  REFERENCES project (project_id)
);

-- department --
DROP TABLE IF EXISTS department;
CREATE TABLE department (
  department_id INT         NOT NULL UNIQUE AUTO_INCREMENT,
  dept_head_id  INT         NOT NULL,
  title         VARCHAR(30) NULL,
  PRIMARY KEY (department_id),
  INDEX department_club_member_idx (dept_head_id ASC),
  FOREIGN KEY (dept_head_id)
  REFERENCES club_member (member_id)
);

-- department_membership --
DROP TABLE IF EXISTS department_membership;
CREATE TABLE department_membership (
  member_id     INT NOT NULL,
  department_id INT NOT NULL,
  PRIMARY KEY (member_id, department_id),
  INDEX department_membership_department_idx (department_id ASC),
  INDEX department_membership_club_member_idx (member_id ASC),
  FOREIGN KEY (member_id)
  REFERENCES club_member (member_id),
  FOREIGN KEY (department_id)
  REFERENCES department (department_id)
);

-- eboard_member --
DROP TABLE IF EXISTS eboard_member;
CREATE TABLE eboard_member (
  title     VARCHAR(30) NOT NULL,
  member_id INT         NOT NULL,
  eboard_id INT         NOT NULL UNIQUE AUTO_INCREMENT,
  INDEX eboard_member_club_member_idx (member_id ASC),
  PRIMARY KEY (eboard_id),
  FOREIGN KEY (member_id)
  REFERENCES club_member (member_id)
);

-- link --
DROP TABLE IF EXISTS link;
CREATE TABLE link (
  type       ENUM ('Bandcamp', 'Soundcloud', 'Spotify', 'Apple Music', 'Tidal',
                   'Pandora', 'YouTube', 'Google Play', 'Amazon Music', 'Other') NOT NULL,
  url        VARCHAR(300)                                                        NOT NULL,
  link_id    INT                                                                 NOT NULL AUTO_INCREMENT,
  release_id INT                                                                 NOT NULL,
  PRIMARY KEY (link_id),
  INDEX fk_Link_Release1_idx (release_id ASC),
  FOREIGN KEY (release_id)
  REFERENCES `release` (release_id)
);

-- contribution --
DROP TABLE IF EXISTS contribution;
CREATE TABLE contribution (
  contribution_id INT          NOT NULL UNIQUE AUTO_INCREMENT,
  date            DATE         NOT NULL,
  description     VARCHAR(300) NOT NULL,
  member_id       INT          NOT NULL,
  department_id   INT,
  PRIMARY KEY (contribution_id),
  INDEX contribution_club_member_idx (member_id ASC),
  INDEX contribution_department_idx (department_id ASC),
  FOREIGN KEY (department_id)
  REFERENCES department (department_id),
  FOREIGN KEY (member_id)
  REFERENCES club_member (member_id)
);


