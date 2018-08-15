CREATE TABLE `journey` (
  `id` INTEGER PRIMARY KEY NOT NULL,
  `title` TEXT,
  `starting` TEXT,
  `ending` TEXT,
  `distance` TEXT,
  `note` TEXT
);

CREATE TABLE `position` (
  `id` INTEGER PRIMARY KEY NOT NULL,
  `journeyID` INTEGER,
  `latitude` TEXT,
  `longitude` TEXT
);