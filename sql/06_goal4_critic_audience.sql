-- ============================================================
-- Netflix Content Library Analysis
-- Goal 4: Critic vs Audience Alignment
-- Author: Geri Rusk
-- Tool: Google BigQuery
-- Dataset: your-project-id.netflix_project
-- ============================================================
-- Business Goal:
-- Determine whether content maturity ratings correlate with
-- IMDB scores, and whether critic scores (Rotten Tomatoes)
-- and audience scores (IMDB) tell the same story.
-- ============================================================
-- Note on data coverage:
-- Rotten Tomatoes scores are only available for 2,268 of
-- 8,800 titles (25.8%). All analyses involving RT scores
-- are based on this subset and results should be interpreted
-- with that coverage limitation in mind.
-- ============================================================


-- ------------------------------------------------------------
-- Q4.1 Content Rating vs Average IMDB Score
-- ------------------------------------------------------------
-- SMART Question:
-- Is there a meaningful difference in average IMDB score
-- between TV-MA rated content and family-friendly content
-- (G, PG, TV-G, TV-Y), and which rating category performs best?
-- ------------------------------------------------------------
-- Note: Ratings Unknown, Not Rated, UR, and NR are excluded
-- as they do not represent meaningful content classification.
-- ------------------------------------------------------------

SELECT
  rating_cleaned,
  COUNT(*)                                                                AS title_count,
  ROUND(AVG(imdb_score), 2)                                              AS avg_imdb_score,
  ROUND(
    COUNT(CASE WHEN imdb_score > 7.0 THEN 1 END) * 100.0
    / COUNT(imdb_score), 1
  )                                                                       AS pct_above_7
FROM `your-project-id.netflix_project.netflix_master_deduped`
WHERE imdb_score IS NOT NULL
  AND rating_cleaned IS NOT NULL
  AND rating_cleaned NOT IN ('Unknown', 'Not Rated', 'UR', 'NR')
GROUP BY rating_cleaned
ORDER BY avg_imdb_score DESC;

-- Results saved as: SQL_Analysis_Goal4_Q4.1
--
-- Key findings:
-- Rating  | Titles | Avg IMDB | % Above 7.0
-- TV-MA   | 1,814  |   6.63   |   38.0%
-- TV-14   | 1,003  |   6.61   |   41.9%
-- TV-PG   |   316  |   6.56   |   34.5%
-- TV-Y7   |   121  |   6.53   |   35.5%
-- TV-Y    |   120  |   6.47   |   33.3%
-- PG-13   |   126  |   6.38   |   24.6%
-- TV-G    |   102  |   6.34   |   27.5%
-- R       |   228  |   6.16   |   21.5%
-- PG      |    76  |   6.08   |   13.2%
--
-- Key observation: TV ratings from TV-MA to TV-Y span only
-- 0.16 IMDB points — content maturity has virtually no
-- relationship with quality for TV content on Netflix.
-- All Movie rating categories (R, PG-13, PG) score below
-- every TV rating category, reinforcing the consistent
-- TV vs Movie quality divide found throughout this analysis.
-- R-rated Movies averaging 6.16 contradicts the assumption
-- that mature content equals higher quality content.


-- ------------------------------------------------------------
-- Q4.2 IMDB vs Rotten Tomatoes Agreement Rate
-- ------------------------------------------------------------
-- SMART Question:
-- For titles where both an IMDB score and a Rotten Tomatoes
-- score exist, how often do they agree — defined as both
-- being above or both being below their respective averages?
-- ------------------------------------------------------------
-- Methodology:
-- Agreement is defined as both scores being on the same side
-- of their respective quality thresholds:
--   IMDB threshold: 7.0 (out of 10)
--   RT threshold: 70 (out of 100)
-- A title where IMDB >= 7.0 AND RT >= 70 = Agree (both good)
-- A title where IMDB < 7.0 AND RT < 70 = Agree (both poor)
-- Any other combination = Disagree
-- ------------------------------------------------------------

SELECT
  COUNT(*)                                                                AS titles_with_both_scores,
  COUNTIF(
    (imdb_score >= 7.0 AND rotten_tomatoes_score >= 70)
    OR (imdb_score < 7.0 AND rotten_tomatoes_score < 70)
  )                                                                       AS scores_agree,
  COUNTIF(
    (imdb_score >= 7.0 AND rotten_tomatoes_score < 70)
    OR (imdb_score < 7.0 AND rotten_tomatoes_score >= 70)
  )                                                                       AS scores_disagree,
  ROUND(
    COUNTIF(
      (imdb_score >= 7.0 AND rotten_tomatoes_score >= 70)
      OR (imdb_score < 7.0 AND rotten_tomatoes_score < 70)
    ) * 100.0 / COUNT(*), 1
  )                                                                       AS pct_agreement
FROM `your-project-id.netflix_project.netflix_master_deduped`
WHERE imdb_score IS NOT NULL
  AND rotten_tomatoes_score IS NOT NULL;

-- Results:
-- titles_with_both_scores | scores_agree | scores_disagree | pct_agreement
--          1,058          |     745      |       313       |    70.4%
--
-- Key observation: Critics and audiences agree on Netflix
-- content quality 70.4% of the time — more than expected.
-- The 29.6% disagreement rate (313 titles) represents
-- meaningful differences in how critics and audiences evaluate
-- certain content types. This disagreement is explored in
-- detail in Q4.3 at the genre level.


-- ------------------------------------------------------------
-- Q4.3 Critic vs Audience Score Gap by Genre
-- ------------------------------------------------------------
-- SMART Question:
-- Which genres show the biggest gap between critic scores
-- (Rotten Tomatoes) and audience scores (IMDB), and in
-- which direction does the gap go?
-- ------------------------------------------------------------
-- Methodology:
-- IMDB scores are on a 0-10 scale.
-- RT scores are on a 0-100 scale.
-- To compare them, IMDB scores are multiplied by 10 to bring
-- them to the same 0-100 scale as RT scores.
-- Gap = AVG(RT score) - AVG(IMDB score * 10)
-- Positive gap = Critics rate higher than audiences
-- Negative gap = Audiences rate higher than critics
-- ------------------------------------------------------------

SELECT
  genre,
  COUNT(*)                        AS title_count,
  ROUND(AVG(imdb_score), 2)       AS avg_imdb_score,
  ROUND(AVG(rotten_tomatoes_score), 2)
                                  AS avg_rt_score,
  ROUND(
    AVG(rotten_tomatoes_score) - AVG(imdb_score * 10), 2
  )                               AS critic_vs_audience_gap
FROM (
  SELECT
    TRIM(genre_split)             AS genre,
    imdb_score,
    rotten_tomatoes_score
  FROM `your-project-id.netflix_project.netflix_master_deduped`
  CROSS JOIN UNNEST(SPLIT(listed_in, ',')) AS genre_split
  WHERE imdb_score IS NOT NULL
    AND rotten_tomatoes_score IS NOT NULL
)
GROUP BY genre
HAVING COUNT(*) >= 10
ORDER BY critic_vs_audience_gap DESC
LIMIT 15;

-- Results saved as: SQL_Analysis_Goal4_Q4.3
--
-- Key findings (selected):
-- Genre               | IMDB | RT Score | Gap
-- Stand-Up Comedy     | 7.05 |   84.77  | +14.26 (Critics higher)
-- LGBTQ Movies        | 6.68 |   78.33  | +11.50 (Critics higher)
-- Documentaries       | 7.06 |   82.06  | +11.41 (Critics higher)
-- Independent Movies  | 6.29 |   69.46  | + 6.55 (Critics higher)
-- Comedies            | 6.05 |   54.30  | - 6.21 (Audiences higher)
-- TV Dramas           | 7.09 |   63.55  | - 7.36 (Audiences higher)
-- Sci-Fi & Fantasy    | 6.10 |   53.42  | - 7.54 (Audiences higher)
--
-- Key observation: The largest divergences occur at genre
-- level rather than platform level. Critics significantly
-- over-rate Stand-Up Comedy, LGBTQ Movies, and Documentaries.
-- Audiences are more enthusiastic about Sci-Fi, TV Dramas,
-- and Comedies than critics. Netflix faces different
-- optimization challenges depending on whether it targets
-- critical acclaim or audience satisfaction.
