-- Finalize the title_basics table

	-- Create varchar[] from comma separated text
	UPDATE title_basics
	SET "genres" = STRING_TO_ARRAY("genres", ',');
	
	-- Refine column types
	ALTER TABLE IF EXISTS title_basics
	ALTER COLUMN "tconst" TYPE varchar(11) USING "tconst"::varchar(11),
	ALTER COLUMN "genres" TYPE varchar[] USING "genres"::character varying[],
	ALTER COLUMN "startYear" TYPE smallint USING "startYear"::smallint,
	ALTER COLUMN "endYear" TYPE smallint USING "endYear"::smallint;

	-- Change isAdult column type to boolean
	ALTER TABLE IF EXISTS title_basics ADD COLUMN "new_boolean_column" BOOLEAN;
	ALTER TABLE IF EXISTS title_basics ALTER COLUMN "isAdult" TYPE INT USING "isAdult"::integer;
	UPDATE title_basics SET new_boolean_column = ("isAdult" <> 0);
	ALTER TABLE IF EXISTS title_basics DROP COLUMN "isAdult";
	ALTER TABLE IF EXISTS title_basics RENAME COLUMN "new_boolean_column" TO "isAdult";

	-- Create tconst primary key and unique constrains
	ALTER TABLE IF EXISTS title_basics
	ADD CONSTRAINT pk_title_basics PRIMARY KEY ("tconst");


-- Finalize the name_basics table

	-- Create varchar[] from comma separated text
	UPDATE name_basics
	SET "primaryProfession" = STRING_TO_ARRAY("primaryProfession", ','),
	"knownForTitles" = STRING_TO_ARRAY("knownForTitles", ',');
	
	-- Refine column types
	ALTER TABLE IF EXISTS name_basics
	ALTER COLUMN "nconst" TYPE varchar(11) USING "nconst"::varchar(11),
	ALTER COLUMN "primaryProfession" TYPE varchar[] USING "primaryProfession"::character varying[],
	ALTER COLUMN "knownForTitles" TYPE varchar[] USING "knownForTitles"::character varying[],
	ALTER COLUMN "birthYear" TYPE smallint USING "birthYear"::smallint,
	ALTER COLUMN "deathYear" TYPE smallint USING "deathYear"::smallint;

	-- Create nconst primary key and unique constrains
	ALTER TABLE IF EXISTS name_basics
	ADD CONSTRAINT pk_name_basics PRIMARY KEY ("nconst");


-- Create lookup table knownfortitles_name_basics_lookup

CREATE TABLE IF NOT EXISTS knownfortitles_name_basics_lookup
AS
SELECT "nconst", UNNEST("knownForTitles") AS knownForTitles
FROM name_basics;

	-- Add constraint nconst foreign key
	ALTER TABLE IF EXISTS knownfortitles_name_basics_lookup
	ADD CONSTRAINT fk_knownfortitles_t_const
	FOREIGN KEY ("nconst") REFERENCES name_basics("nconst");

	-- Drop rows where the corresponding values in the "knownForTitles" column do not exist in the "tconst" column of the title_basics table
	DELETE FROM knownfortitles_name_basics_lookup
	WHERE "knownForTitles" IS NOT NULL
	AND NOT EXISTS (
		SELECT 1 FROM title_basics WHERE "tconst" = knownfortitles_name_basics_lookup."knownForTitles"
	);
	
	-- Refine column types
	ALTER TABLE IF EXISTS knownfortitles_name_basics_lookup
	ALTER COLUMN "knownForTitles" TYPE varchar(11) USING "knownForTitles"::varchar(11);
	
	-- Add constraint knownForTitles foreign key
	ALTER TABLE IF EXISTS knownfortitles_name_basics_lookup
	ADD CONSTRAINT fk_knownfortitles
	FOREIGN KEY ("knownForTitles") REFERENCES title_basics("tconst");


-- Create lookup tables from the title_crew table

-- Create lookup table directors_title_crew_lookup
CREATE TABLE IF NOT EXISTS directors_title_crew_lookup
AS
SELECT "tconst", UNNEST(STRING_TO_ARRAY("directors", ',')) AS directors
FROM title_crew;

	-- Add constraint tconst foreign key
	ALTER TABLE IF EXISTS directors_title_crew_lookup
	ADD CONSTRAINT fk_directors_t_const
	FOREIGN KEY ("tconst") REFERENCES title_basics("tconst");

	-- Eliminate \N or NaN from directors column
	UPDATE directors_title_crew_lookup
	SET "directors" = NULL
	WHERE "directors" = '\N';

	-- Drop rows where the corresponding values in the "directors" column do not exist in the "nconst" column of the name_basics table
	DELETE FROM directors_title_crew_lookup
	WHERE "directors" IS NOT NULL
	AND NOT EXISTS (
		SELECT 1 FROM name_basics WHERE "nconst" = directors_title_crew_lookup."directors"
	);

	-- Add constraint directors foreign key
	ALTER TABLE IF EXISTS directors_title_crew_lookup
	ADD CONSTRAINT fk_directors
	FOREIGN KEY ("directors") REFERENCES name_basics("nconst");

-- Create lookup table writers_title_crew_lookup
CREATE TABLE IF NOT EXISTS writers_title_crew_lookup
AS
SELECT "tconst", UNNEST(STRING_TO_ARRAY("writers", ',')) AS writers
FROM title_crew;

	-- Add constraint tconst foreign key
	ALTER TABLE IF EXISTS writers_title_crew_lookup
	ADD CONSTRAINT fk_directors_t_const
	FOREIGN KEY ("tconst") REFERENCES title_basics("tconst");

	-- Eliminate \N or NaN from writers column
	UPDATE writers_title_crew_lookup
	SET "writers" = NULL
	WHERE "writers" = '\N';
	
	-- Drop rows where the corresponding values in the "directors" column do not exist in the "nconst" column of the name_basics table
	DELETE FROM writers_title_crew_lookup
	WHERE "writers" IS NOT NULL
	AND NOT EXISTS (
		SELECT 1 FROM name_basics WHERE "nconst" = writers_title_crew_lookup."writers"
	);

	-- Add constraint writers foreign key
	ALTER TABLE IF EXISTS writers_title_crew_lookup
	ADD CONSTRAINT fk_writers
	FOREIGN KEY ("writers") REFERENCES name_basics("nconst");


-- Create lookup table genres_title_basics_lookup

CREATE TABLE IF NOT EXISTS genres_title_basics_lookup
AS
SELECT "tconst", UNNEST("genres") AS genres
FROM title_basics;

	-- Refine column dtypes
	ALTER TABLE IF EXISTS genres_title_basics_lookup
	ALTER COLUMN "tconst" TYPE varchar(11) USING "tconst"::varchar(11);

	-- Add constraint tconst foreign key
	ALTER TABLE IF EXISTS genres_title_basics_lookup
	ADD CONSTRAINT fk_genres_t_const
	FOREIGN KEY ("tconst") REFERENCES title_basics("tconst");
	
	-- Eliminate \N or NaN from genres column
	UPDATE genres_title_basics_lookup
	SET "genres" = NULL
	WHERE "genres" = '\N';
	
	/*Add constraint genres (gconst) foreign key
	(no table yet to describe the genres,
	this column contains the genre names for the moment) */
	-- 	ALTER TABLE IF EXISTS genres_title_basics_lookup
	-- 	ADD CONSTRAINT fk_genres
	-- 	FOREIGN KEY ("genres") REFERENCES genre_basics("gconst");


-- Create lookup table primaryprofession_name_basics_lookup

CREATE TABLE IF NOT EXISTS primaryprofession_name_basics_lookup
AS
SELECT "nconst", UNNEST("primaryProfession") AS primaryProfession
FROM name_basics;

	-- Refine column types
	ALTER TABLE IF EXISTS primaryprofession_name_basics_lookup
	ALTER COLUMN "nconst" TYPE varchar(11) USING "nconst"::varchar(11);
	
	-- Add constraint tconst foreign key
	ALTER TABLE IF EXISTS primaryprofession_name_basics_lookup
	ADD CONSTRAINT fk_primaryPr_t_const
	FOREIGN KEY ("nconst") REFERENCES name_basics("nconst");
	
	-- Eliminate \N or NaN from genres column
	UPDATE genres_title_basics_lookup
	SET "genres" = NULL
	WHERE "genres" = '\N';
	
	/*Add constraint primaryProfession (pconst) foreign key
	(no table yet to describe the genres,
	this column contains the genre names for the moment) */
	-- 	ALTER TABLE IF EXISTS genres_title_basics_lookup
	-- 	ADD CONSTRAINT fk_genres
	-- 	FOREIGN KEY ("primaryProfession") REFERENCES profession_basics("pconst");


-- Finalize the title_principals table

	-- Refine column types
	ALTER TABLE IF EXISTS title_principals
	ALTER COLUMN "tconst" TYPE varchar(11) USING "tconst"::varchar(11),
	ALTER COLUMN "nconst" TYPE varchar(11) USING "nconst"::varchar(11);
	
	-- Drop rows where the corresponding values in the "tconst" column do not exist in the "tconst" column of the title_basics table
	DELETE FROM title_principals
	WHERE "tconst" IS NOT NULL
	AND NOT EXISTS (
		SELECT 1 FROM title_basics WHERE "tconst" = title_principals."tconst"
	);
	
	-- Drop rows where the corresponding values in the "nconst" column do not exist in the "nconst" column of the name_basics table
	DELETE FROM title_principals
	WHERE "nconst" IS NOT NULL
	AND NOT EXISTS (
		SELECT 1 FROM name_basics WHERE "nconst" = title_principals."nconst"
	);

	-- Create tconst and nconst foreign key
	ALTER TABLE IF EXISTS title_principals
	ADD CONSTRAINT t_princ_t_const
	FOREIGN KEY ("tconst") REFERENCES title_basics("tconst"),
	ADD CONSTRAINT t_princ_n_const
	FOREIGN KEY ("nconst") REFERENCES name_basics("nconst");


-- Finalize the title_akas table

	-- Refine column types
	ALTER TABLE IF EXISTS title_akas
	ALTER COLUMN "titleId" TYPE varchar(11) USING "titleId"::varchar(11);
	
	-- Drop rows where the corresponding values in the "titleId" column do not exist in the "tconst" column of the title_basics table
	DELETE FROM title_akas
	WHERE "titleId" IS NOT NULL
	AND NOT EXISTS (
		SELECT 1 FROM title_basics WHERE "tconst" = title_akas."titleId"
	);
	
	-- Create tconst as titleId foreign key
	ALTER TABLE IF EXISTS title_akas
	ADD CONSTRAINT t_aka_t_const
	FOREIGN KEY ("titleId") REFERENCES title_basics("tconst");


-- Finalize the title_episode table

	-- Refine column types
	ALTER TABLE IF EXISTS title_episode
	ALTER COLUMN "tconst" TYPE varchar(11) USING "tconst"::varchar(11),
	ALTER COLUMN "parentTconst" TYPE varchar(11) USING "parentTconst"::varchar(11);
	
	-- Drop rows where the corresponding values in the "tconst" column do not exist in the "tconst" column of the title_basics table
	DELETE FROM title_episode
	WHERE "tconst" IS NOT NULL
	AND NOT EXISTS (
		SELECT 1 FROM title_basics WHERE "tconst" = title_episode."tconst"
	);
	
	-- Drop rows where the corresponding values in the "parentTconst" column do not exist in the "tconst" column of the title_basics table
	DELETE FROM title_episode
	WHERE "parentTconst" IS NOT NULL
	AND NOT EXISTS (
		SELECT 1 FROM title_basics WHERE "tconst" = title_episode."parentTconst"
	);

	-- Create tconst and parentTconst foreign key
	ALTER TABLE IF EXISTS title_episode
	ADD CONSTRAINT t_ep_t_const
	FOREIGN KEY ("tconst") REFERENCES title_basics("tconst"),
	ADD CONSTRAINT t_ep_parent_t_const
	FOREIGN KEY ("parentTconst") REFERENCES title_basics("tconst");


-- Finalize the title_ratings table

	-- Refine column types
	ALTER TABLE IF EXISTS title_ratings
	ALTER COLUMN "tconst" TYPE varchar(11) USING "tconst"::varchar(11);
	
	-- Drop rows where the corresponding values in the "tconst" column do not exist in the "tconst" column of the title_basics table
	DELETE FROM title_ratings
	WHERE "tconst" IS NOT NULL
	AND NOT EXISTS (
		SELECT 1 FROM title_basics WHERE "tconst" = title_ratings."tconst"
	);

	-- Create tconst and parentTconst foreign key
	ALTER TABLE IF EXISTS title_ratings
	ALTER COLUMN "averageRating" TYPE real USING "averageRating"::real,
	ADD CONSTRAINT t_rat_t_const
	FOREIGN KEY ("tconst") REFERENCES title_basics("tconst");
	
	
-- Drop title_crew table

DROP TABLE title_crew;

-- Optionals

	-- Indexing title_basics."tconst"
	CREATE INDEX idx_tconst
	ON title_basics ("tconst");
	
	-- Indexing name_basics."nconst"
	CREATE INDEX idx_nconst
	ON name_basics ("nconst");
	
--	-- Drop indexes
-- 	DROP INDEX idx_tconst;
-- 	DROP INDEX idx_nconst;