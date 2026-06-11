-- ============================================================
-- Netflix Content Library Analysis
-- Validation Queries — Data Quality Checks
-- Author: Geri Rusk
-- Tool: Google BigQuery
-- Dataset: your-project-id.netflix_project
-- ============================================================
-- Purpose:
-- These queries were run after uploading each cleaned CSV
-- to BigQuery to verify data integrity before analysis.
-- Run these against each table after upload to confirm
-- row counts, missing values, and data type accuracy.
-- ============================================================


-- ============================================================
-- TABLE: netflix_titles
-- ============================================================

-- Row count verification
-- Expected: approximately 8,807 rows
SELECT COUNT(*) AS total_rows
FROM `your-project-id.netflix_project.netflix_titles`;


-- Missing value check across key columns
SELECT
  COUNT(*) - COUNT(title_cleaned)         AS missing_title,
  COUNT(*) - COUNT(type_cleaned)          AS missing_type,
  COUNT(*) - COUNT(rating_cleaned)        AS missing_rating,
  COUNT(*) - COUNT(country_cleaned)       AS missing_country,
  COUNT(*) - COUNT(year_added)            AS missing_year_added,
  COUNT(*) - COUNT(director_cleaned)      AS missing_director
FROM `your-project-id.netflix_project.netflix_titles`;


-- Distinct values in type_cleaned
-- Expected: exactly 2 values — Movie and TV Show
SELECT
  type_cleaned,
  COUNT(*) AS count
FROM `your-project-id.netflix_project.netflix_titles`
GROUP BY type_cleaned
ORDER BY count DESC;


-- Distinct values in rating_cleaned
-- Used to identify any unexpected or inconsistent values
SELECT
  rating_cleaned,
  COUNT(*) AS count
FROM `your-project-id.netflix_project.netflix_titles`
GROUP BY rating_cleaned
ORDER BY count DESC;


-- Date range verification for year_added
-- Expected: 2008 to 2021 approximately
-- Any value of 1900 indicates a blank date that was
-- misread as zero by Excel during cleaning
SELECT
  MIN(year_added) AS earliest_year,
  MAX(year_added) AS latest_year
FROM `your-project-id.netflix_project.netflix_titles`;


-- Identify any remaining 1900 date errors
-- Expected: 0 rows (these should have been fixed before upload)
SELECT
  title_cleaned,
  date_added_clean,
  year_added
FROM `your-project-id.netflix_project.netflix_titles`
WHERE year_added = 1900
   OR year_added < 2000;


-- ============================================================
-- TABLE: netflix_scores
-- ============================================================

-- Row count verification
-- Expected: approximately 5,283 rows
-- NOTE: If this returns 1,048,575 the file was corrupted
-- by Excel row limits — re-upload from Google Sheets
SELECT COUNT(*) AS total_rows
FROM `your-project-id.netflix_project.netflix_scores`;


-- Missing value check
SELECT
  COUNT(*) - COUNT(title)             AS missing_title,
  COUNT(*) - COUNT(type)              AS missing_type,
  COUNT(*) - COUNT(imdb_score)        AS missing_imdb_score,
  COUNT(*) - COUNT(imdb_votes)        AS missing_imdb_votes
FROM `your-project-id.netflix_project.netflix_scores`;


-- IMDB score range validation
-- Expected: all values between 1.0 and 10.0
SELECT
  title,
  imdb_score
FROM `your-project-id.netflix_project.netflix_scores`
WHERE imdb_score < 1
   OR imdb_score > 10;


-- ============================================================
-- TABLE: netflix_rt
-- ============================================================

-- Row count verification
SELECT COUNT(*) AS total_rows
FROM `your-project-id.netflix_project.netflix_rt`;


-- Missing value check on key columns
SELECT
  COUNT(*) - COUNT(title)                   AS missing_title,
  COUNT(*) - COUNT(imdb_score)              AS missing_imdb_score,
  COUNT(*) - COUNT(rotten_tomatoes_score)   AS missing_rt_score,
  COUNT(*) - COUNT(hidden_gem_score)        AS missing_hidden_gem
FROM `your-project-id.netflix_project.netflix_rt`;

-- Note: rotten_tomatoes_score is expected to be missing
-- approximately 59% of the time — this is a known data
-- limitation documented in the findings report


-- ============================================================
-- MATCH CHECK — Title Join Verification
-- ============================================================
-- Run this after all three tables are uploaded to verify
-- how well the title column matches across datasets.
-- This determines how many titles will successfully join.
-- ============================================================

SELECT
  COUNT(*)                        AS total_titles,
  COUNT(ns.imdb_score)            AS matched_to_scores,
  COUNT(rt.rotten_tomatoes_score) AS matched_to_rt,
  COUNT(*) - COUNT(ns.imdb_score) AS unmatched_scores,
  COUNT(*) - COUNT(rt.rotten_tomatoes_score)
                                  AS unmatched_rt
FROM `your-project-id.netflix_project.netflix_titles` nt
LEFT JOIN `your-project-id.netflix_project.netflix_scores` ns
  ON LOWER(TRIM(nt.title_cleaned)) = LOWER(TRIM(ns.title))
LEFT JOIN `your-project-id.netflix_project.netflix_rt` rt
  ON LOWER(TRIM(nt.title_cleaned)) = LOWER(TRIM(rt.title));

-- Result from this project:
-- total_titles: 9,158
-- matched_to_scores: 4,163
-- matched_to_rt: 2,268
-- unmatched_scores: 4,995
-- unmatched_rt: 6,890
--
-- Note: The high unmatched_scores count reflects a coverage
-- gap between datasets — netflix_scores only covers 5,235
-- unique titles vs 8,798 in netflix_titles. This is not a
-- technical problem but a difference in dataset scope.
-- LEFT JOIN is used in the master view to preserve all titles.
