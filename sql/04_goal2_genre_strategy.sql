-- ============================================================
-- Netflix Content Library Analysis
-- Goal 2: Content Strategy by Genre
-- Author: Geri Rusk
-- Tool: Google BigQuery
-- Dataset: your-project-id.netflix_project
-- ============================================================
-- Business Goal:
-- Identify which genres are over- or under-represented
-- relative to their IMDB performance, to inform future
-- content investment decisions.
-- ============================================================
-- Note on methodology:
-- The listed_in column contains multiple genres per title
-- (e.g. "Dramas, International Movies, Thrillers").
-- CROSS JOIN UNNEST(SPLIT()) is used to split these into
-- individual rows so each genre can be analyzed separately.
-- This means one title can contribute to multiple genre counts.
-- ============================================================


-- ------------------------------------------------------------
-- Q2.1 Most Produced Genres vs Average IMDB Score
-- ------------------------------------------------------------
-- SMART Question:
-- What are the 5 most-produced genres on Netflix, and what is
-- the average IMDB score for each — are the most-produced
-- genres also the highest-rated?
-- ------------------------------------------------------------

SELECT
  genre,
  COUNT(*)                        AS title_count,
  ROUND(AVG(imdb_score), 2)       AS avg_imdb_score
FROM (
  SELECT
    TRIM(genre_split)             AS genre,
    imdb_score
  FROM `your-project-id.netflix_project.netflix_master_deduped`
  CROSS JOIN UNNEST(SPLIT(listed_in, ',')) AS genre_split
  WHERE imdb_score IS NOT NULL
)
GROUP BY genre
ORDER BY title_count DESC
LIMIT 15;

-- Results saved as: SQL_Analysis_Goal2_Q2.1
--
-- Key findings:
-- Genre                  | Count | Avg IMDB
-- International Movies   | 1,224 |   6.20
-- Dramas                 | 1,056 |   6.38
-- International TV Shows |   713 |   7.15
-- Comedies               |   704 |   5.96
-- TV Dramas              |   441 |   7.23
-- TV Comedies            |   345 |   6.99
-- Action & Adventure     |   303 |   6.02
-- Romantic Movies        |   294 |   6.08
-- Independent Movies     |   287 |   6.35
-- Documentaries          |   277 |   6.96
-- Crime TV Shows         |   273 |   7.25
-- Thrillers              |   251 |   6.00
-- Kids TV                |   236 |   6.62
-- Stand-Up Comedy        |   232 |   6.65
-- Docuseries             |   211 |   7.24
--
-- Key observation: Netflix's most produced genres are NOT its
-- highest rated ones. Every TV genre outperforms every Movie
-- genre in the top 15. Comedies has the worst quality ratio —
-- 704 titles averaging only 5.96.


-- ------------------------------------------------------------
-- Q2.2 High Rated but Underproduced Genres
-- ------------------------------------------------------------
-- SMART Question:
-- Which genres have the highest average IMDB score but the
-- fewest titles — representing potential underinvested
-- opportunities for Netflix?
-- ------------------------------------------------------------
-- Note: Minimum threshold of 20 titles applied to ensure
-- statistical reliability. Genres with fewer than 20 titles
-- are excluded as their averages are not meaningful.
-- ------------------------------------------------------------

SELECT
  genre,
  COUNT(*)                        AS title_count,
  ROUND(AVG(imdb_score), 2)       AS avg_imdb_score
FROM (
  SELECT
    TRIM(genre_split)             AS genre,
    imdb_score
  FROM `your-project-id.netflix_project.netflix_master_deduped`
  CROSS JOIN UNNEST(SPLIT(listed_in, ',')) AS genre_split
  WHERE imdb_score IS NOT NULL
)
GROUP BY genre
HAVING COUNT(*) >= 20
ORDER BY avg_imdb_score DESC
LIMIT 15;

-- Results saved as: SQL_Analysis_Goal2_Q2.2
--
-- Key findings:
-- Genre                  | Count | Avg IMDB | Opportunity
-- Korean TV Shows        |    72 |   7.47   | Highest rated, underinvested
-- TV Thrillers           |    37 |   7.39   | High score, very small
-- Anime Series           |   100 |   7.28   | Strong, room to grow
-- Romantic TV Shows      |   177 |   7.25   | Well-sized, could expand
-- Crime TV Shows         |   273 |   7.25   | High volume AND quality
-- Docuseries             |   211 |   7.24   | Strong performer
-- TV Dramas              |   441 |   7.23   | Large and strong
-- TV Action & Adventure  |   117 |   7.21   | Underinvested vs quality
-- British TV Shows       |   106 |   7.20   | Quality niche
-- Science & Nature TV    |    42 |   7.15   | High score, very small
--
-- Key observation: All 15 highest rated genres with at least
-- 20 titles are TV formats. Not a single Movie genre appears
-- in the top 15 — confirming a consistent platform-wide
-- quality advantage for TV content over Movie content.
-- Korean TV Shows at 7.47 with only 72 titles represents
-- the clearest underinvestment opportunity.
