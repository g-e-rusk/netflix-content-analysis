-- ============================================================
-- Netflix Content Library Analysis
-- Goal 5: Library Growth & Quality Trends Over Time
-- Author: Geri Rusk
-- Tool: Google BigQuery
-- Dataset: your-project-id.netflix_project
-- ============================================================
-- Business Goal:
-- Analyze how Netflix's content volume and average quality
-- ratings have changed year over year, to identify whether
-- growth periods impacted content quality.
-- ============================================================
-- Note on data range:
-- Analysis is limited to years 2015-2021 because:
--   - Pre-2015 data has very few titles and is not
--     representative of Netflix's streaming strategy
--   - 2021 data is a partial year in this dataset
--     and should not be compared directly to full years
--   - 10 titles with no date_added value are excluded
--     (their year_added field is NULL)
-- ============================================================


-- ------------------------------------------------------------
-- Q5.1 Content Added Per Year by Type
-- ------------------------------------------------------------
-- SMART Question:
-- How many titles were added to Netflix each year between
-- 2015 and 2021, broken down by Movies and TV Shows, and
-- which year had the largest single-year increase?
-- ------------------------------------------------------------

SELECT
  year_added,
  type_cleaned,
  COUNT(*)                        AS title_count
FROM `your-project-id.netflix_project.netflix_master_deduped`
WHERE year_added IS NOT NULL
  AND year_added BETWEEN 2015 AND 2021
GROUP BY year_added, type_cleaned
ORDER BY year_added ASC, type_cleaned ASC;

-- Results saved as: SQL_Analysis_Goal5_Q5.1
--
-- Key findings (totals per year):
-- Year | Movies | TV Shows | Total  | YoY Growth | TV Show %
-- 2015 |     56 |       26 |     82 | Baseline   |   31.7%
-- 2016 |    253 |      176 |    429 | +423%      |   41.0%
-- 2017 |    839 |      349 |  1,188 | +177%      |   29.4%
-- 2018 |  1,235 |      412 |  1,647 | +39%       |   25.0%
-- 2019 |  1,422 |      591 |  2,013 | +22%       |   29.4%
-- 2020 |  1,284 |      595 |  1,879 | -7%        |   31.7%
-- 2021 |    992 |      504 |  1,496 | -21%       |   33.7%
--
-- Key observation: Netflix grew explosively from 82 titles
-- in 2015 to a peak of 2,013 in 2019 — a 2,354% increase
-- in four years. The largest single-year growth was 2016
-- (+423%) coinciding with Netflix's global expansion.
-- TV Show percentage gradually grew from 31.7% to 33.7%,
-- suggesting a slow strategic rebalancing toward the content
-- format that consistently scores higher.


-- ------------------------------------------------------------
-- Q5.2 Average IMDB Score Per Year Added
-- ------------------------------------------------------------
-- SMART Question:
-- Did the average IMDB score of Netflix content added each
-- year increase or decrease between 2015 and 2021 — and if
-- it changed, by how much?
-- ------------------------------------------------------------

SELECT
  year_added,
  COUNT(imdb_score)               AS scored_titles,
  ROUND(AVG(imdb_score), 2)       AS avg_imdb_score,
  ROUND(MIN(imdb_score), 2)       AS min_score,
  ROUND(MAX(imdb_score), 2)       AS max_score
FROM `your-project-id.netflix_project.netflix_master_deduped`
WHERE year_added IS NOT NULL
  AND year_added BETWEEN 2015 AND 2021
  AND imdb_score IS NOT NULL
GROUP BY year_added
ORDER BY year_added ASC;

-- Results saved as: SQL_Analysis_Goal5_Q5.2
--
-- Key findings:
-- Year | Scored | Avg IMDB | Min  | Max
-- 2015 |     33 |    6.54  |  4.4 |  8.3
-- 2016 |    129 |    6.81  |  3.8 |  9.0
-- 2017 |    358 |    6.50  |  2.1 |  9.0
-- 2018 |    595 |    6.48  |  1.7 |  8.8
-- 2019 |    768 |    6.61  |  2.3 |  9.3
-- 2020 |  1,088 |    6.57  |  1.5 |  9.3
-- 2021 |    916 |    6.52  |  1.8 |  9.6
--
-- Key observation: Average quality held remarkably stable
-- despite 2,354% volume growth. Net change from 2015 to 2021
-- was only 0.02 points (6.54 to 6.52). However minimum scores
-- worsened significantly from 4.4 in 2015 to 1.5 in 2020 —
-- a 2.9 point deterioration. Netflix maintained its average
-- quality floor while simultaneously introducing more low
-- quality content at the bottom of its catalogue as volume
-- scaled. Maximum scores also increased slightly, suggesting
-- Netflix continued adding prestige content even as it added
-- more low-quality content.


-- ------------------------------------------------------------
-- Q5.3 Gap Between Release Year and Netflix Addition Year
-- ------------------------------------------------------------
-- SMART Question:
-- What is the average gap between a title's original release
-- year and the year it was added to Netflix, and has that
-- gap changed over time — suggesting Netflix is licensing
-- older or newer content?
-- ------------------------------------------------------------
-- Note: WHERE year_added >= release_year filters out a small
-- number of anomalous records where a title appears to have
-- been added to Netflix before its official release year.
-- These are likely data entry errors in the source dataset.
-- ------------------------------------------------------------

SELECT
  year_added,
  ROUND(AVG(year_added - release_year), 1)
                                  AS avg_years_gap,
  MIN(year_added - release_year)  AS min_gap,
  MAX(year_added - release_year)  AS max_gap,
  COUNT(*)                        AS title_count
FROM `your-project-id.netflix_project.netflix_master_deduped`
WHERE year_added IS NOT NULL
  AND year_added BETWEEN 2015 AND 2021
  AND release_year IS NOT NULL
  AND year_added >= release_year
GROUP BY year_added
ORDER BY year_added ASC;

-- Results saved as: SQL_Analysis_Goal5_Q5.3
--
-- Key findings:
-- Year | Avg Gap | Min | Max | Titles
-- 2015 |     1.3 |   0 |  23 |     82
-- 2016 |     3.0 |   0 |  43 |    427
-- 2017 |     3.9 |   0 |  75 |  1,187
-- 2018 |     4.1 |   0 |  93 |  1,644
-- 2019 |     5.3 |   0 |  64 |  2,009
-- 2020 |     4.7 |   0 |  66 |  1,876
-- 2021 |     5.7 |   0 |  76 |  1,496
--
-- Key observation: The average gap grew from 1.3 years in
-- 2015 to 5.7 years in 2021. In 2015 Netflix added content
-- released just 1.3 years earlier — essentially current.
-- By 2021 it was adding content 5.7 years old on average.
-- Maximum gaps exceeding 75 years in every year from 2017
-- onwards confirm Netflix actively acquires archival and
-- classic content alongside contemporary productions.
-- This back-catalogue strategy likely contributed to quality
-- stability despite volume growth, as older content has
-- already demonstrated audience appeal over time.
