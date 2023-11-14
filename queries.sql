-- US most populars w/o shorts and documentaries
SELECT
    subquery."Title",
    subquery."Start Year",
    subquery."Average Rating",
    subquery."Number of Votes",
    subquery."Genre"
FROM (
SELECT DISTINCT ON (title_basics."primaryTitle")
    title_basics."primaryTitle" AS "Title",
    title_basics."startYear" AS "Start Year",
    title_ratings."averageRating" AS "Average Rating",
    title_ratings."numVotes" AS "Number of Votes",
    genres_title_basics_lookup."genres" AS "Genre"
FROM
    title_basics
JOIN
    title_akas ON title_akas."titleId" = title_basics."tconst"
JOIN
    title_ratings ON title_basics."tconst" = title_ratings."tconst"
JOIN
    genres_title_basics_lookup ON genres_title_basics_lookup.tconst = title_basics.tconst
WHERE
    "region" = 'US'
    AND genres_title_basics_lookup."genres" NOT IN ('Short', 'Documentary')
    AND title_basics."startYear" > 2010
) subquery
ORDER BY
    subquery."Average Rating" DESC,
	subquery."Number of Votes" DESC
LIMIT 10;


-- Most popular documentaries
SELECT
    title_basics."primaryTitle" AS "Title",
    MAX(title_basics."startYear") AS "Start Year",
    MAX(title_ratings."averageRating") AS "Average Rating",
    MAX(title_ratings."numVotes") AS "Number of Votes",
    MAX(genres_title_basics_lookup."genres") AS "Genre"
FROM
    title_basics
JOIN
    title_akas ON title_akas."titleId" = title_basics."tconst"
JOIN
    title_ratings ON title_basics."tconst" = title_ratings."tconst"
JOIN
    genres_title_basics_lookup ON genres_title_basics_lookup.tconst = title_basics.tconst
GROUP BY
    title_basics."primaryTitle"
HAVING
    MAX(genres_title_basics_lookup."genres") = 'Documentary'
ORDER BY
    "Average Rating" DESC, "Number of Votes" DESC LIMIT 10;
	
	
-- Best movies from Steven Spielberg
SELECT
    subquery."Title",
    subquery."Start Year",
    subquery."Average Rating",
    subquery."Number of Votes",
    subquery."Genre"
FROM (
    SELECT DISTINCT ON (title_basics."primaryTitle")
        title_basics."primaryTitle" AS "Title",
        title_basics."startYear" AS "Start Year",
        title_ratings."averageRating" AS "Average Rating",
        title_ratings."numVotes" AS "Number of Votes",
        genres_title_basics_lookup."genres" AS "Genre"
    FROM
        title_basics
    JOIN
        title_akas ON title_akas."titleId" = title_basics."tconst"
    JOIN
        title_ratings ON title_basics."tconst" = title_ratings."tconst"
    JOIN
        genres_title_basics_lookup ON genres_title_basics_lookup."tconst" = title_basics."tconst"
    JOIN
        directors_title_crew_lookup ON directors_title_crew_lookup."tconst" = title_basics."tconst"
    JOIN
        name_basics ON directors_title_crew_lookup."directors" = name_basics."nconst"
    WHERE
        name_basics."primaryName" = 'Steven Spielberg'
    ORDER BY
        title_basics."primaryTitle", title_ratings."averageRating" DESC, title_ratings."numVotes" DESC
) subquery
ORDER BY
    subquery."Average Rating" DESC, subquery."Number of Votes" DESC;