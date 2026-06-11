# Netflix Content Library Analysis

A complete end-to-end data analysis project examining Netflix's content library across 8,800 titles. This project covers the full analyst workflow from raw data acquisition through cleaning, SQL analysis, and interactive data visualization.

---

## Project Overview

This project was completed as a portfolio piece demonstrating core data analyst skills. The analysis examines Netflix's content library to uncover strategic insights about content quality, genre performance, global reach, critic versus audience alignment, and library growth trends from 2015 to 2021.

The analysis is structured around five business goals and fifteen SMART questions, each answered through SQL queries in Google BigQuery and visualized in an interactive Tableau Public dashboard.

---

## Tools & Technologies

| Tool | Purpose |
|---|---|
| Microsoft Excel | Initial data profiling and exploration |
| Google Sheets | Data cleaning and UTF-8 CSV preparation |
| Google BigQuery | SQL analysis and data transformation |
| Tableau Public | Interactive dashboard and data visualization |
| GitHub | Version control and portfolio hosting |

---

## Datasets

Three publicly available datasets from Kaggle were used in this project:

| Dataset | Rows | Key Fields |
|---|---|---|
| netflix_titles.csv | 8,807 | title, type, country, date_added, rating, listed_in |
| Netflix_TV_Shows_and_Movies.csv | 5,283 | title, imdb_score, imdb_votes, runtime |
| netflix-rotten-tomatoes-metacritic-imdb.csv | 15,480 | title, rotten_tomatoes_score, hidden_gem_score, genre |

After cleaning and deduplication the master dataset contains **8,800 unique titles**.

---

## Business Goals

| Goal | Description |
|---|---|
| Goal 1 — Content Quality Assessment | Understand how Netflix content performs in terms of audience and critic perception |
| Goal 2 — Content Strategy by Genre | Identify which genres are over- or under-represented relative to their IMDB performance |
| Goal 3 — Global Content Reach | Evaluate geographic diversity and whether international content performs differently |
| Goal 4 — Critic vs Audience Alignment | Determine whether content ratings correlate with scores and whether critics and audiences agree |
| Goal 5 — Library Growth & Quality Trends | Analyze how content volume and quality ratings have changed year over year |

See [SMART_questions.md](SMART_questions.md) for all fifteen SMART questions and their corresponding charts.

---

## Key Findings

- **TV Shows significantly outperform Movies** — averaging 7.05 vs 6.26 on IMDB, a 0.8 point gap that appeared consistently across every angle of analysis
- **Korean TV Shows are Netflix's highest rated genre** — averaging 7.47 IMDB with only 72 titles, representing a clear underinvestment opportunity
- **Netflix's global pivot is visible in the data** — international content grew from 27.8% of additions in 2015 to a peak of 60.8% in 2018
- **Quality held stable despite explosive growth** — average IMDB score changed only 0.02 points despite a 2,354% increase in content volume between 2015 and 2019
- **Popular content rates far better than obscure content** — titles with 500k+ IMDB votes average 8.23 vs 6.43 for titles with under 10k votes
- **Critics and audiences agree more than expected** — 70.4% alignment across 1,058 titles with both IMDB and Rotten Tomatoes scores

---

## Interactive Dashboard

The complete interactive dashboard is published on Tableau Public and consists of three pages:

- Dashboard 1 — Content Quality & Genre Strategy
- Dashboard 2 — Global Reach & Critic vs Audience Alignment
- Dashboard 3 — Library Growth & Quality Trends Over Time

**View the dashboard:** [Tableau Public Dashboards](https://public.tableau.com/app/profile/geri.rusk/viz/NetflixContentLibraryAnalysis-GeriRusk/QualityGenre#1)

Use the tab bar at the bottom of the dashboard to navigate between the three pages.

---

## Repository Structure

```
netflix-content-analysis/
│
├── README.md                          
├── SMART_questions.md                 
│
├── data/
│   └── cleaned/
│       ├── netflix_titles_final_cleaned.csv
│       ├── netflix_scores_final_cleaned.csv
│       └── netflix_rt_final_cleaned.csv
│
├── sql/
│   ├── 01_validation_queries.sql      
│   ├── 02_master_view.sql             
│   ├── 03_goal1_content_quality.sql   
│   ├── 04_goal2_genre_strategy.sql    
│   ├── 05_goal3_global_reach.sql      
│   ├── 06_goal4_critic_audience.sql   
│   └── 07_goal5_trends_over_time.sql  
│
├── results/
│   ├── viz_content_type_quality.csv
│   ├── viz_popularity_tiers.csv
│   ├── viz_genre_production.csv
│   ├── viz_high_rated_genres.csv
│   ├── viz_country_quality.csv
│   ├── viz_international_growth.csv
│   ├── viz_country_ranking.csv
│   ├── viz_rating_quality.csv
│   ├── viz_critic_agreement.csv
│   ├── viz_critic_audience_gap.csv
│   ├── viz_content_growth.csv
│   ├── viz_quality_over_time.csv
│   └── viz_release_gap.csv
│
├── report/
│   └── Netflix_Analysis_Findings_Report.docx
│
└── screenshots/
    ├── dashboards/
    │   ├── dashboard_1_quality_genre.png
    │   ├── dashboard_2_global_critics.png
    │   └── dashboard_3_trends.png
    └── courses/
        └── google_data_analytics_certificate.png
        
```

---

## SQL Files

| File | Contents |
|---|---|
| 01_validation_queries.sql | Data quality checks run after each CSV upload to BigQuery |
| 02_master_view.sql | Three-table LEFT JOIN master view and deduplication logic |
| 03_goal1_content_quality.sql | Q1.1, Q1.2, Q1.3 — content type and popularity analysis |
| 04_goal2_genre_strategy.sql | Q2.1, Q2.2 — genre volume vs quality analysis |
| 05_goal3_global_reach.sql | Q3.1, Q3.2, Q3.3 — country and international growth analysis |
| 06_goal4_critic_audience.sql | Q4.1, Q4.2, Q4.3 — content rating and critic alignment analysis |
| 07_goal5_trends_over_time.sql | Q5.1, Q5.2, Q5.3 — library growth and quality trend analysis |

> **Note:** BigQuery project IDs in all SQL files have been replaced with `your-project-id` for privacy. Substitute your own BigQuery project ID to run these queries in your environment.

---

## Data Cleaning Summary

The following data quality issues were identified and resolved prior to analysis:

- **159 duplicate records** identified and resolved using ROW_NUMBER() window function in BigQuery, retaining the record with the highest IMDB vote count per duplicate group
- **10 titles** had no recorded date_added value — left blank for NULL handling, excluded from time-based analyses only
- **Director column** had 30% missing values — filled with Unknown placeholder
- **Country column** had 9% missing values — filled with Unknown placeholder
- **Age certification** in netflix_scores had 43% missing values — primary rating column from netflix_titles used instead
- **Rotten Tomatoes scores** missing for 59% of titles — used where available with coverage noted in all analyses
- **Non-Latin character titles** caused BigQuery encoding issues — resolved by saving all CSV files in UTF-8 format
- **Netflix_TV_Shows_and_Movies.csv** was corrupted by Excel row limits during initial cleaning — re-cleaned using Google Sheets to preserve all 5,283 rows

---

## Data Limitations

- IMDB scores are available for only 47.3% of titles — analyses involving scores may reflect a bias toward more widely known content
- Rotten Tomatoes scores are available for only 25.8% of titles — critic vs audience comparisons are based on a subset of the library
- Dataset covers content through approximately mid-2021 — 2021 figures represent a partial year
- Title matching across datasets was performed on the title text column — minor title variations may have caused some titles not to match correctly across sources
- Country field represents production country not viewership geography

---

## Certifications

Courses completed during and alongside this project:

- Google Data Analytics Professional Certificate — [In Progress]

---

## Contact

Geri Rusk  
[https://www.linkedin.com/in/geri-e-rusk/](https://www.linkedin.com/in/geri-e-rusk/) 
