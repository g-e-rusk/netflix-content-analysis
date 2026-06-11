-- ============================================================
-- Netflix Content Library Analysis
-- Goal 1: Content Quality Assessment
-- Author: Geri Rusk
-- Tool: Google BigQuery
-- Dataset: your-project-id.netflix_project
-- ============================================================
-- Business Goal:
-- Understand how Netflix's content library performs in terms
-- of audience and critic perception, and identify which content
-- types and genres consistently deliver high-quality ratings.
-- ============================================================


-- ------------------------------------------------------------
-- Q1.1 Average and Median IMDB Score by Content Type
-- ------------------------------------------------------------
-- SMART Question:
-- What is the average and median IMDB score for Movies versus
-- TV Shows on Netflix, and which content type has a higher
-- percentage of titles scoring above 7.0?
-- ------------------------------------------------------------

SELECT
  type_cleaned,
  ROUND(AVG(imdb_score), 2)                                              AS avg_imdb_score,
  ROUND(
    COUNT(CASE WHEN imdb_score > 7.0 THEN 1 END) * 100.0
    / COUNT(imdb_score), 1
  )                                                                       AS pct_above_7,
  COUNT(imdb_score)                                                       AS titles_with_scores,
  COUNT(*)                                                                AS total_titles
FROM `your-project-id.netflix_project.netflix_master_deduped`
WHERE imdb_score IS NOT NULL
GROUP BY type_cleaned
ORDER BY avg_imdb_score DESC;

-- Results:
-- TV Shows average 7.05 with 55.5% of titles scoring above 7.0
-- Movies average 6.26 with 24.7% of titles scoring above 7.0
-- TV Shows outperform Movies by 0.8 IMDB points on average
-- TV Shows are more than twice as likely to score above 7.0


-- ------------------------------------------------------------
-- Q1.2 Top 10 Highest Rated Titles on Netflix
-- ------------------------------------------------------------
-- SMART Question:
-- Which 10 titles have the highest IMDB scores and which have
-- the lowest, and what do they have in common in terms of
-- type, genre, or country?
-- ------------------------------------------------------------

SELECT
  title_cleaned,
  type_cleaned,
  country_cleaned,
  listed_in,
  imdb_score,
  imdb_votes
FROM `your-project-id.netflix_project.netflix_master_deduped`
WHERE imdb_score IS NOT NULL
ORDER BY imdb_score DESC
LIMIT 10;

-- Results saved as: SQL_Analysis_Goal1_Q1.2.1
-- Key observation: All top 10 titles are TV Shows
-- Strong international representation — India, South Korea, Japan


-- ------------------------------------------------------------
-- Q1.2 Bottom 10 Lowest Rated Titles on Netflix
-- ------------------------------------------------------------

SELECT
  title_cleaned,
  type_cleaned,
  country_cleaned,
  listed_in,
  imdb_score,
  imdb_votes
FROM `your-project-id.netflix_project.netflix_master_deduped`
WHERE imdb_score IS NOT NULL
ORDER BY imdb_score ASC
LIMIT 10;

-- Results saved as: SQL_Analysis_Goal1_Q1.2.2
-- Key observation: Bottom 10 dominated by Movies (8 of 10)
-- India and UAE appear most frequently
-- Several titles have very low vote counts (under 400)
-- indicating limited statistical reliability


-- ------------------------------------------------------------
-- Duplicate Detection Query
-- ------------------------------------------------------------
-- Note: During Q1.2 analysis a duplicate record was noticed
-- in the top 10 results. The following query was used to
-- identify the full scope of duplicate records in the dataset.
-- ------------------------------------------------------------

SELECT
  title_cleaned,
  type_cleaned,
  COUNT(*) AS occurrence_count
FROM `your-project-id.netflix_project.netflix_master`
WHERE imdb_score IS NOT NULL
GROUP BY title_cleaned, type_cleaned
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;

-- Result: 159 duplicate records identified across the dataset
-- Resolution: Created a deduplicated view using ROW_NUMBER()
-- retaining the record with the highest IMDB vote count per
-- duplicate group as the most statistically reliable version


-- ------------------------------------------------------------
-- Deduplicated Master View Creation
-- ------------------------------------------------------------
-- Note: BigQuery Sandbox does not support UPDATE or DELETE.
-- Deduplication was handled at the view level using the
-- ROW_NUMBER() window function. This approach is non-
-- destructive and preserves all source data.
-- ------------------------------------------------------------

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
  rt_genre
FROM ranked
WHERE row_num = 1;


-- ------------------------------------------------------------
-- Deduplication Verification Queries
-- ------------------------------------------------------------

-- Verify overall row count dropped to expected level
SELECT
  COUNT(*)                        AS total_rows,
  COUNT(imdb_score)               AS rows_with_imdb,
  COUNT(rotten_tomatoes_score)    AS rows_with_rt
FROM `your-project-id.netflix_project.netflix_master_deduped`;

-- Result: 8,800 total rows — confirmed deduplication worked

-- Verify specific known duplicate (Death Note) is now single
SELECT
  title_cleaned,
  type_cleaned,
  imdb_score,
  imdb_votes,
  country_cleaned
FROM `your-project-id.netflix_project.netflix_master_deduped`
WHERE LOWER(title_cleaned) LIKE '%death note%';

-- Result: Two records correctly retained as distinct entries:
-- Death Note (TV Show) — Japan — 2006 anime series
-- Death Note (Movie)   — United States — 2017 live action film
-- These are genuinely different titles sharing the same name


-- ------------------------------------------------------------
-- Q1.3 Relationship Between IMDB Votes and IMDB Score
-- ------------------------------------------------------------
-- SMART Question:
-- Is there a relationship between the number of IMDB votes a
-- title receives and its IMDB score — do more widely-watched
-- titles tend to rate higher?
-- ------------------------------------------------------------

-- Detailed breakdown by title
SELECT
  title_cleaned,
  type_cleaned,
  imdb_score,
  imdb_votes,
  CASE
    WHEN imdb_votes >= 500000 THEN '1. Very Popular (500k+)'
    WHEN imdb_votes >= 100000 THEN '2. Popular (100k-500k)'
    WHEN imdb_votes >= 10000  THEN '3. Moderate (10k-100k)'
    ELSE                           '4. Limited (under 10k)'
  END AS popularity_tier
FROM `your-project-id.netflix_project.netflix_master_deduped`
WHERE imdb_score IS NOT NULL
  AND imdb_votes IS NOT NULL
ORDER BY imdb_votes DESC;

-- Result: 3,910 rows returned
-- Saved as: IMDB_Scores_IMDB_Votes (Google Sheet)


-- Summary aggregation by popularity tier
SELECT
  CASE
    WHEN imdb_votes >= 500000 THEN '1. Very Popular (500k+)'
    WHEN imdb_votes >= 100000 THEN '2. Popular (100k-500k)'
    WHEN imdb_votes >= 10000  THEN '3. Moderate (10k-100k)'
    ELSE                           '4. Limited (under 10k)'
  END AS popularity_tier,
  COUNT(*)                        AS title_count,
  ROUND(AVG(imdb_score), 2)       AS avg_imdb_score
FROM `your-project-id.netflix_project.netflix_master_deduped`
WHERE imdb_score IS NOT NULL
  AND imdb_votes IS NOT NULL
GROUP BY popularity_tier
ORDER BY popularity_tier ASC;

-- Results saved as: SQL_Analysis_Goal1_Q1.3
--
-- Key findings:
-- Tier                    | Titles | Avg IMDB
-- Very Popular (500k+)    |    16  |   8.23
-- Popular (100k-500k)     |   175  |   7.45
-- Moderate (10k-100k)     |   814  |   6.78
-- Limited (under 10k)     | 2,905  |   6.43
--
-- Strong positive correlation confirmed between popularity
-- and quality. 74.8% of scored content falls in the lowest
-- engagement tier. Netflix's most-watched content significantly
-- outperforms its catalogue average.
