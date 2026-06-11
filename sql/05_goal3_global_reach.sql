-- ============================================================
-- Netflix Content Library Analysis
-- Goal 3: Global Content Reach
-- Author: Geri Rusk
-- Tool: Google BigQuery
-- Dataset: your-project-id.netflix_project
-- ============================================================
-- Business Goal:
-- Evaluate the geographic diversity of Netflix's content
-- library and determine whether international content performs
-- differently than US-produced content.
-- ============================================================
-- Note on methodology:
-- The country_cleaned column can contain multiple countries
-- per title (e.g. "United States, United Kingdom").
-- CROSS JOIN UNNEST(SPLIT()) is used to split these into
-- individual rows so each country can be counted separately.
-- Rows where country is Unknown are excluded from all
-- country-level analyses to avoid skewing results.
-- ============================================================


-- ------------------------------------------------------------
-- Q3.1 Top 10 Producing Countries vs Average IMDB Score
-- ------------------------------------------------------------
-- SMART Question:
-- Which 10 countries produce the most Netflix content, and
-- how does their average IMDB score compare to US-produced
-- content?
-- ------------------------------------------------------------

SELECT
  country,
  COUNT(*)                        AS title_count,
  ROUND(AVG(imdb_score), 2)       AS avg_imdb_score
FROM (
  SELECT
    TRIM(country_split)           AS country,
    imdb_score
  FROM `your-project-id.netflix_project.netflix_master_deduped`
  CROSS JOIN UNNEST(SPLIT(country_cleaned, ',')) AS country_split
  WHERE imdb_score IS NOT NULL
    AND country_cleaned IS NOT NULL
    AND TRIM(country_split) != 'Unknown'
)
GROUP BY country
ORDER BY title_count DESC
LIMIT 10;

-- Results saved as: SQL_Analysis_Goal3_Q3.1
--
-- Key findings:
-- Rank | Country        | Titles | Avg IMDB | vs US
--   1  | United States  | 1,617  |   6.58   | Baseline
--   2  | India          |   485  |   6.36   | -0.22
--   3  | United Kingdom |   295  |   6.87   | +0.29
--   4  | France         |   177  |   6.45   | -0.13
--   5  | Canada         |   174  |   6.51   | -0.07
--   6  | Japan          |   166  |   7.10   | +0.52
--   7  | Spain          |   133  |   6.48   | -0.10
--   8  | South Korea    |   124  |   7.25   | +0.67
--   9  | Germany        |    96  |   6.58   | +0.00
--  10  | China          |    83  |   6.75   | +0.17
--
-- Key observation: The US dominates volume at 1,617 titles
-- but ranks 3rd in quality among its own top 10 producers.
-- South Korea (7.25) and Japan (7.10) significantly outperform
-- the US despite having far fewer titles — volume does not
-- equal quality.


-- ------------------------------------------------------------
-- Q3.2 International vs US Content Percentage Over Time
-- ------------------------------------------------------------
-- SMART Question:
-- What percentage of Netflix's library is non-US content,
-- and has that percentage grown or shrunk between 2016
-- and 2021?
-- ------------------------------------------------------------

SELECT
  year_added,
  COUNT(*)                                                                AS total_titles,
  COUNTIF(country_cleaned NOT LIKE '%United States%')                    AS international_titles,
  COUNTIF(country_cleaned LIKE '%United States%')                        AS us_titles,
  ROUND(
    COUNTIF(country_cleaned NOT LIKE '%United States%') * 100.0
    / COUNT(*), 1
  )                                                                       AS pct_international
FROM `your-project-id.netflix_project.netflix_master_deduped`
WHERE year_added IS NOT NULL
  AND year_added BETWEEN 2015 AND 2022
  AND country_cleaned IS NOT NULL
  AND country_cleaned != 'Unknown'
GROUP BY year_added
ORDER BY year_added ASC;

-- Results saved as: SQL_Analysis_Goal3_Q3.2
--
-- Key findings:
-- Year | Total | International | US    | % International
-- 2015 |    79 |            22 |    57 |   27.8%
-- 2016 |   410 |           207 |   203 |   50.5%
-- 2017 | 1,122 |           661 |   461 |   58.9%
-- 2018 | 1,528 |           929 |   599 |   60.8%
-- 2019 | 1,856 |         1,000 |   856 |   53.9%
-- 2020 | 1,771 |           943 |   828 |   53.2%
-- 2021 | 1,138 |           512 |   626 |   45.0%
--
-- Key observation: Netflix's global pivot is clearly visible.
-- International content grew from 27.8% in 2015 to a peak
-- of 60.8% in 2018 — coinciding with Netflix's 2016 expansion
-- into 130 new countries. The 2021 drop to 45% likely reflects
-- a partial year in the dataset, not a strategic reversal.


-- ------------------------------------------------------------
-- Q3.3 Highest Rated Country With at Least 20 Titles
-- ------------------------------------------------------------
-- SMART Question:
-- Which country outside the United States produces the highest
-- average IMDB score, with at least 20 titles to ensure
-- statistical reliability?
-- ------------------------------------------------------------

SELECT
  country,
  COUNT(*)                        AS title_count,
  ROUND(AVG(imdb_score), 2)       AS avg_imdb_score
FROM (
  SELECT
    TRIM(country_split)           AS country,
    imdb_score
  FROM `your-project-id.netflix_project.netflix_master_deduped`
  CROSS JOIN UNNEST(SPLIT(country_cleaned, ',')) AS country_split
  WHERE imdb_score IS NOT NULL
    AND country_cleaned IS NOT NULL
    AND TRIM(country_split) != 'Unknown'
)
GROUP BY country
HAVING COUNT(*) >= 20
ORDER BY avg_imdb_score DESC
LIMIT 15;

-- Results saved as: SQL_Analysis_Goal3_Q3.3
--
-- Key findings:
-- Rank | Country        | Titles | Avg IMDB
--   1  | South Korea    |   124  |   7.25
--   2  | Japan          |   166  |   7.10
--   3  | United Kingdom |   295  |   6.87
--   4  | Lebanon        |    23  |   6.86
--   5  | Australia      |    65  |   6.82
--   6  | Egypt          |    25  |   6.81
--   7  | China          |    83  |   6.75
--   8  | Taiwan         |    38  |   6.64
--   9  | United States  | 1,617  |   6.58
--  10  | Germany        |    96  |   6.58
--
-- Key observation: South Korea leads all countries at 7.25.
-- Notably Lebanon (4th, 6.86) and Egypt (6th, 6.81) both
-- outperform the United States which ranks 9th despite
-- producing over 1,600 titles. Middle Eastern content
-- markets are significantly underinvested relative to their
-- quality output.
