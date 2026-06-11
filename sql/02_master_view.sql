-- ============================================================
-- Netflix Content Library Analysis
-- Master View & Join Queries
-- Author: Geri Rusk
-- Tool: Google BigQuery
-- Dataset: your-project-id.netflix_project
-- ============================================================
-- Purpose:
-- This file contains the queries used to build the master
-- joined dataset from all three source tables, and the
-- deduplicated view used for all analysis queries.
--
-- All analysis in Goals 1-5 references the final view:
-- netflix_master_deduped
-- ============================================================


-- ============================================================
-- STEP 1: Create the Master Joined View
-- ============================================================
-- Joins all three tables on the title column using LEFT JOIN
-- to preserve all 8,800 titles regardless of whether a match
-- exists in the scoring tables.
--
-- LOWER(TRIM()) applied to both sides of the join condition
-- to normalize capitalization and whitespace differences
-- that would otherwise prevent matching.
-- ============================================================

CREATE OR REPLACE VIEW `your-project-id.netflix_project.netflix_master` AS
SELECT
  nt.title_cleaned,
  nt.type_cleaned,
  nt.director_cleaned,
  nt.country_cleaned,
  nt.date_added_clean,
  nt.year_added,
  nt.month_added,
  nt.release_year,
  nt.rating_cleaned,
  nt.duration,
  nt.listed_in,
  ns.imdb_score,
  ns.imdb_votes,
  ns.runtime,
  rt.rotten_tomatoes_score,
  rt.hidden_gem_score,
  rt.rt_genre
FROM `your-project-id.netflix_project.netflix_titles` nt
LEFT JOIN `your-project-id.netflix_project.netflix_scores` ns
  ON LOWER(TRIM(nt.title_cleaned)) = LOWER(TRIM(ns.title))
LEFT JOIN `your-project-id.netflix_project.netflix_rt` rt
  ON LOWER(TRIM(nt.title_cleaned)) = LOWER(TRIM(rt.title));


-- Verify the master view row and score counts
SELECT
  COUNT(*)                          AS total_rows,
  COUNT(imdb_score)                 AS rows_with_imdb,
  COUNT(rotten_tomatoes_score)      AS rows_with_rt,
  COUNT(*) - COUNT(imdb_score)      AS rows_missing_imdb,
  COUNT(*) - COUNT(rotten_tomatoes_score)
                                    AS rows_missing_rt
FROM `your-project-id.netflix_project.netflix_master`;

-- Expected results:
-- total_rows:       9,158
-- rows_with_imdb:   4,163
-- rows_with_rt:     2,268
-- rows_missing_imdb: 4,995
-- rows_missing_rt:  6,890


-- ============================================================
-- STEP 2: Identify Duplicates in the Master View
-- ============================================================
-- During Q1.2 analysis a duplicate record was discovered.
-- This query identifies all duplicate title/type combinations
-- in the master view to determine the full scope.
-- ============================================================

SELECT
  title_cleaned,
  type_cleaned,
  COUNT(*) AS occurrence_count
FROM `your-project-id.netflix_project.netflix_master`
WHERE imdb_score IS NOT NULL
GROUP BY title_cleaned, type_cleaned
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;

-- Result: 159 duplicate records identified
-- Root cause: Overlapping title coverage between source
-- datasets causing some titles to join to multiple rows


-- ============================================================
-- STEP 3: Create the Deduplicated Master View
-- ============================================================
-- Resolution approach: ROW_NUMBER() window function
-- partitions by title and type, ordering by imdb_votes DESC
-- so the record with the most votes (most statistically
-- reliable) is ranked first and retained.
--
-- This approach is non-destructive — no source data is
-- modified. BigQuery Sandbox does not support UPDATE or
-- DELETE so view-level deduplication is the correct
-- approach for this environment.
-- ============================================================

CREATE OR REPLACE VIEW `your-project-id.netflix_project.netflix_master_deduped` AS
WITH ranked AS (
  SELECT
    *,
    ROW_NUMBER() OVER (
      PARTITION BY LOWER(TRIM(title_cleaned)), type_cleaned
      ORDER BY
        imdb_votes DESC,
        imdb_score DESC
    ) AS row_num
  FROM `your-project-id.netflix_project.netflix_master`
)
SELECT
  title_cleaned,
  type_cleaned,
  director_cleaned,
  country_cleaned,
  date_added_clean,
  year_added,
  month_added,
  release_year,
  rating_cleaned,
  duration,
  listed_in,
  imdb_score,
  imdb_votes,
  runtime,
  rotten_tomatoes_score,
  hidden_gem_score,
  rt_genre
FROM ranked
WHERE row_num = 1;


-- ============================================================
-- STEP 4: Verify the Deduplicated View
-- ============================================================

-- Confirm total row count dropped as expected
SELECT
  COUNT(*)                        AS total_rows,
  COUNT(imdb_score)               AS rows_with_imdb,
  COUNT(rotten_tomatoes_score)    AS rows_with_rt
FROM `your-project-id.netflix_project.netflix_master_deduped`;

-- Expected: total_rows = 8,800
-- (9,158 minus 159 duplicate rows = approximately 8,800)


-- Confirm no duplicate title/type combinations remain
SELECT
  title_cleaned,
  type_cleaned,
  COUNT(*) AS occurrence_count
FROM `your-project-id.netflix_project.netflix_master_deduped`
GROUP BY title_cleaned, type_cleaned
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;

-- Expected: 0 rows returned


-- Verify specific known case — Death Note
-- Expected: 2 rows (distinct titles sharing the same name)
-- Row 1: Death Note — TV Show — Japan — 2006 anime series
-- Row 2: Death Note — Movie — United States — 2017 live action
SELECT
  title_cleaned,
  type_cleaned,
  country_cleaned,
  release_year,
  imdb_score,
  imdb_votes
FROM `your-project-id.netflix_project.netflix_master_deduped`
WHERE LOWER(title_cleaned) LIKE '%death note%';

-- Note: Both Death Note records are intentionally retained
-- as they represent genuinely different titles — a 2006
-- Japanese anime series and a 2017 US live action film.
-- They share the same IMDB score and vote count because the
-- source scoring dataset applied the same score to both
-- entries. This is documented in the data quality section
-- of the findings report.


-- ============================================================
-- STEP 5: Final Master View Statistics
-- ============================================================
-- Summary statistics used in the findings report
-- ============================================================

SELECT
  COUNT(*)                                          AS total_unique_titles,
  COUNT(imdb_score)                                 AS titles_with_imdb,
  COUNT(rotten_tomatoes_score)                      AS titles_with_rt,
  ROUND(COUNT(imdb_score) * 100.0 / COUNT(*), 1)   AS pct_with_imdb,
  ROUND(COUNT(rotten_tomatoes_score) * 100.0 / COUNT(*), 1)
                                                    AS pct_with_rt,
  COUNT(*) - COUNT(imdb_score)                      AS titles_missing_imdb,
  COUNT(*) - COUNT(rotten_tomatoes_score)           AS titles_missing_rt
FROM `your-project-id.netflix_project.netflix_master_deduped`;

-- Results:
-- total_unique_titles:  8,800
-- titles_with_imdb:     4,163  (47.3%)
-- titles_with_rt:       2,268  (25.8%)
-- titles_missing_imdb:  4,995  (52.7%)
-- titles_missing_rt:    6,890  (74.2%)
