# Business Goals & SMART Questions

This document outlines the five business goals and fifteen SMART questions that structured the Netflix Content Library Analysis. Each SMART question is Specific, Measurable, Action-oriented, Relevant, and Time-bound.

Every question was designed to be answerable using the available dataset columns and SQL queries in Google BigQuery. The chart or source that answers each question is referenced alongside it.

---

## Goal 1 — Content Quality Assessment

**Business Goal:**
Understand how Netflix's content library performs in terms of audience and critic perception, and identify which content types and genres consistently deliver high-quality ratings.

---

### Q1.1

> *What is the average and median IMDB score for Movies versus TV Shows on Netflix, and which content type has a higher percentage of titles scoring above 7.0?*

- **Answered by:** Chart 1 — TV Shows vs Movies Average IMDB Score (Tableau Dashboard 1)
- **SQL file:** 03_goal1_content_quality.sql
- **Key finding:** TV Shows average 7.05 vs Movies at 6.26 — a 0.8 point gap. TV Shows are more than twice as likely to score above 7.0 (55.5% vs 24.7%).

---

### Q1.2

> *Which 10 titles have the highest IMDB scores and which have the lowest, and what do they have in common in terms of type, genre, or country?*

- **Answered by:** Top 10 and Bottom 10 BigQuery result tables
- **SQL file:** 03_goal1_content_quality.sql
- **Key finding:** All top 10 titles are TV Shows with strong international representation from India, South Korea, and Japan. The bottom 10 is dominated by Movies (8 of 10), with India and the UAE appearing most frequently.

---

### Q1.3

> *Is there a relationship between the number of IMDB votes a title receives and its IMDB score — do more widely-watched titles tend to rate higher?*

- **Answered by:** Chart 2 — Content Popularity vs Average IMDB Score (Tableau Dashboard 1)
- **SQL file:** 03_goal1_content_quality.sql
- **Key finding:** Strong positive correlation confirmed. Titles with 500k+ votes average 8.23 vs 6.43 for titles with under 10k votes. 74.8% of scored content falls in the lowest engagement tier.

---

## Goal 2 — Content Strategy by Genre

**Business Goal:**
Identify which genres are over- or under-represented relative to their IMDB performance, to inform future content investment decisions.

---

### Q2.1

> *What are the 5 most-produced genres on Netflix, and what is the average IMDB score for each — are the most-produced genres also the highest-rated?*

- **Answered by:** Chart 3 — Genre Volume vs Average IMDB Score (Tableau Dashboard 1)
- **SQL file:** 04_goal2_genre_strategy.sql
- **Key finding:** Netflix's most produced genres are not its highest rated. International Movies (1,224 titles, 6.20 avg) and Dramas (1,056 titles, 6.38 avg) dominate volume but score below average. Every TV genre outperforms every Movie genre in the top 15.

---

### Q2.2

> *Which genres have the highest average IMDB score but the fewest titles — representing potential underinvested opportunities for Netflix?*

- **Answered by:** Chart 4 — Highest Rated Underproduced Genres (Tableau Dashboard 1)
- **SQL file:** 04_goal2_genre_strategy.sql
- **Key finding:** Korean TV Shows lead all genres at 7.47 average IMDB with only 72 titles. TV Thrillers (7.39, 37 titles) and Anime Series (7.28, 100 titles) similarly show strong quality with limited catalogue depth. All 15 highest rated genres are TV formats.

---

## Goal 3 — Global Content Reach

**Business Goal:**
Evaluate the geographic diversity of Netflix's content library and determine whether international content performs differently than US-produced content.

---

### Q3.1

> *Which 10 countries produce the most Netflix content, and how does their average IMDB score compare to US-produced content?*

- **Answered by:** Chart 5 — Content Quality by Country World Map (Tableau Dashboard 2)
- **SQL file:** 05_goal3_global_reach.sql
- **Key finding:** The United States produces 1,617 titles — more than 3x the second largest producer India at 485. However South Korea (7.25) and Japan (7.10) significantly outperform the US average of 6.58 despite having far fewer titles.

---

### Q3.2

> *What percentage of Netflix's library is non-US content, and has that percentage grown or shrunk between 2016 and 2021?*

- **Answered by:** Chart 6 — International vs US Content Growth 2015–2021 (Tableau Dashboard 2)
- **SQL file:** 05_goal3_global_reach.sql
- **Key finding:** International content grew from 27.8% of additions in 2015 to a peak of 60.8% in 2018 — coinciding with Netflix's 2016 expansion into 130 new countries. Between 2016 and 2020 international titles consistently represented over half of all new content added annually.

---

### Q3.3

> *Which country outside the United States produces the highest average IMDB score, with at least 20 titles to ensure statistical reliability?*

- **Answered by:** Chart 5 — Content Quality by Country World Map (Tableau Dashboard 2)
- **SQL file:** 05_goal3_global_reach.sql
- **Key finding:** South Korea ranks first at 7.25, followed by Japan at 7.10. Notably Lebanon (6.86) ranks 4th and Egypt (6.81) ranks 6th — both outperforming the United States which ranks 9th despite producing over 1,600 titles.

---

## Goal 4 — Critic vs Audience Alignment

**Business Goal:**
Determine whether content maturity ratings correlate with IMDB scores, and whether critic scores (Rotten Tomatoes) and audience scores (IMDB) tell the same story.

---

### Q4.1

> *Is there a meaningful difference in average IMDB score between TV-MA rated content and family-friendly content (G, PG, TV-G, TV-Y), and which rating category performs best?*

- **Answered by:** Q4.1 BigQuery result table
- **SQL file:** 06_goal4_critic_audience.sql
- **Key finding:** TV ratings from TV-MA to TV-Y span only 0.16 IMDB points — content maturity has virtually no relationship with quality for TV content on Netflix. All Movie rating categories (R, PG-13, PG) score below every TV rating category. R-rated Movies averaging 6.16 contradicts the assumption that mature content equals higher quality.

---

### Q4.2

> *For titles where both an IMDB score and a Rotten Tomatoes score exist, how often do they agree — defined as both being above or both being below their respective quality thresholds?*

- **Answered by:** Chart 8 — Critics vs Audience Agreement Rate (Tableau Dashboard 2)
- **SQL file:** 06_goal4_critic_audience.sql
- **Key finding:** Critics and audiences agree 70.4% of the time across 1,058 titles with both scores available. The 29.6% disagreement rate (313 titles) represents meaningful differences in how critics and audiences evaluate certain content types. Thresholds used: IMDB 7.0 and RT 70.

---

### Q4.3

> *Which genres show the biggest gap between critic scores (Rotten Tomatoes) and audience scores (IMDB), and in which direction does the gap go?*

- **Answered by:** Chart 7 — Critic vs Audience Score Gap by Genre (Tableau Dashboard 2)
- **SQL file:** 06_goal4_critic_audience.sql
- **Key finding:** Stand-Up Comedy has the largest critic-audience gap at +14.26 (critics rate much higher). LGBTQ Movies (+11.50) and Documentaries (+11.41) also skew toward critics. Sci-Fi & Fantasy (-7.54), TV Dramas (-7.36), and Comedies (-6.21) favor audiences over critics.

---

## Goal 5 — Library Growth & Quality Trends Over Time

**Business Goal:**
Analyze how Netflix's content volume and average quality ratings have changed year over year, to identify whether growth periods impacted content quality.

---

### Q5.1

> *How many titles were added to Netflix each year between 2015 and 2021, broken down by Movies and TV Shows, and which year had the largest single-year increase?*

- **Answered by:** Chart 9 — Netflix Titles Added Per Year by Type (Tableau Dashboard 3)
- **SQL file:** 07_goal5_trends_over_time.sql
- **Key finding:** Content grew from 82 titles added in 2015 to a peak of 2,013 in 2019 — a 2,354% increase. The largest single-year percentage growth was 2016 (+423%) coinciding with Netflix's global expansion. TV Show percentage gradually grew from 31.7% to 33.7% of annual additions.

---

### Q5.2

> *Did the average IMDB score of Netflix content added each year increase or decrease between 2015 and 2021 — and if it changed, by how much?*

- **Answered by:** Chart 10 — Average IMDB Score Stability 2015–2021 and Chart 12 — Quality Floor Deterioration (Tableau Dashboard 3)
- **SQL file:** 07_goal5_trends_over_time.sql
- **Key finding:** Average quality held remarkably stable — changing only 0.02 points (6.54 to 6.52) despite 2,354% volume growth. However minimum scores worsened significantly from 4.4 in 2015 to 1.5 in 2020, a 2.9 point deterioration indicating Netflix introduced more low quality content at the bottom of its catalogue while maintaining its average.

---

### Q5.3

> *What is the average gap between a title's original release year and the year it was added to Netflix, and has that gap changed over time — suggesting Netflix is licensing older or newer content?*

- **Answered by:** Chart 11 — Content Age Gap Over Time (Tableau Dashboard 3)
- **SQL file:** 07_goal5_trends_over_time.sql
- **Key finding:** The average gap grew from 1.3 years in 2015 to 5.7 years in 2021. Netflix increasingly licensed older back catalogue content as it scaled. Maximum gaps exceeding 75 years confirm Netflix actively acquires archival and classic content alongside contemporary productions. This back-catalogue strategy likely contributed to quality stability despite volume growth.

---

## Chart Reference Table

| Chart | Title | SMART Question | Dashboard |
|---|---|---|---|
| Chart 1 | TV Shows vs Movies Average IMDB Score | Q1.1 | Dashboard 1 |
| Chart 2 | Content Popularity vs Average IMDB Score | Q1.3 | Dashboard 1 |
| Chart 3 | Genre Volume vs Average IMDB Score | Q2.1 | Dashboard 1 |
| Chart 4 | Highest Rated Underproduced Genres | Q2.2 | Dashboard 1 |
| Chart 5 | Content Quality by Country — World Map | Q3.1 & Q3.3 | Dashboard 2 |
| Chart 6 | International vs US Content Growth | Q3.2 | Dashboard 2 |
| Chart 7 | Critic vs Audience Score Gap by Genre | Q4.3 | Dashboard 2 |
| Chart 8 | Critics vs Audience Agreement Rate | Q4.2 | Dashboard 2 |
| Chart 9 | Netflix Titles Added Per Year by Type | Q5.1 | Dashboard 3 |
| Chart 10 | Average IMDB Score Stability 2015–2021 | Q5.2 | Dashboard 3 |
| Chart 11 | Content Age Gap Over Time | Q5.3 | Dashboard 3 |
| Chart 12 | Quality Floor Deterioration 2015–2021 | Q5.2 supplementary | Dashboard 3 |
| Table | Top 10 Highest Rated Titles | Q1.2 | BigQuery result |
| Table | Bottom 10 Lowest Rated Titles | Q1.2 | BigQuery result |
| Table | Average IMDB Score by Content Rating | Q4.1 | BigQuery result |
