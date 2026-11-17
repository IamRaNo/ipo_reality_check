# The IPO Reality Check

**Do IPO listing-day gains predict better 1-year returns than Nifty50?**

## Overview

When a new stock lists on the exchange, investors often assume that a strong first day signals strong returns ahead. This project tests that assumption using Indian IPO data. It compares what an investor earns by buying a newly listed stock on its listing day against investing in the Nifty50 index on the same day, over the following year.

## Business Problem

> If an investor buys a new stock on listing day, will it return better profit after 1 year compared to investing in Nifty50 stocks?

### Sub-Problems

| # | Question | Technique |
|---|----------|-----------|
| 1 | Do IPOs with a high listing-day return beat the Nifty50 over the next 1 year? | Cohort Analysis |
| 2 | If a new stock is up a lot after its first month, should an investor sell or keep holding? | Correlation Analysis |
| 3 | Do strong subscription, a high listing-day pop and market conditions on listing day predict better 1-year returns? | Regression |

## Data

| Dataset | Description |
|---------|-------------|
| IPO data | 302 IPOs listed between 2019 and 2025: issue price, listing-day prices, listing-day change, issue size and subscription levels |
| Stock prices | Daily open, high, low, close and volume for each of the 302 companies (about 251,000 rows) |
| Nifty50 | Daily index prices, used as the benchmark |
| India VIX | Daily volatility index, used as a measure of market condition |

## Tools

Python (Pandas, NumPy, SciPy, Statsmodels, scikit-learn, Matplotlib, Seaborn) and MySQL.

## Methodology

**1. Data standardization (Python)**
- Converted all dates to a single format and renamed columns consistently across the four datasets.
- Dropped columns that were not needed and rounded prices to two decimals.
- Checked for missing values and duplicate company-date records.
- Confirmed that the IPO and price datasets cover the same 302 companies.
- Verified the reported listing-day change against a manual calculation. All 302 records matched.

**2. Data preparation (MySQL)**
- Loaded the cleaned data into MySQL.
- For each IPO, calculated the return from the listing-day opening price to the closing price one year later.
- Calculated the Nifty50 return over the same dates, and defined excess return as IPO return minus Nifty50 return.
- Used window functions to calculate each stock's first-month return and its return over the rest of the year.
- Joined listing-day growth, subscription, India VIX and Nifty50 listing-day movement into one table for modelling.

**3. Analysis (Python)**: described below.

## Analysis and Results

### 1. Listing-day pop vs. Nifty50 (Cohort Analysis)
- IPOs were split into two cohorts: **high** listing-day growth (top 25%, 74 IPOs) and **low** (remaining 220 IPOs).
- Returns were compared with the Nifty50 over the same 1-year window for each IPO, overall and year by year.
- The year 2020 behaved differently from the other years, so the test was repeated without it.
- A Mann-Whitney U test on excess return found no significant difference between the cohorts (p = 0.94, and p = 0.91 without 2020).

| Cohort | IPOs | Median IPO return (1 year) | Median Nifty50 return (same period) |
|--------|------|----------------------------|-------------------------------------|
| High listing-day growth | 74 | -5.44% | 8.23% |
| Low listing-day growth | 220 | 0.44% | 8.38% |

Average IPO returns were higher than the Nifty50 in both cohorts (24.6% and 17.9% against about 11% and 10%). This is driven by a small number of very large winners, which is why medians are used as the main measure.

### 2. First-month gain vs. the rest of the year (Correlation Analysis)
- Compared each stock's first-month profit with its profit over the rest of the year (301 IPOs).
- Outliers were identified with the IQR (Tukey) rule, and the analysis was repeated without them.
- Spearman correlation was 0.01 on the full data and 0.04 after removing outliers, so there is no meaningful relationship.

### 3. Predicting 1-year excess return (Regression)
- Model: OLS regression with robust (HC3) standard errors on 292 IPOs.
- Target: 1-year excess return over Nifty50.
- Features: log of subscription, listing-day growth, India VIX on listing day and Nifty50 return on listing day.
- Features were standardized so coefficients are comparable, and the multicollinearity check (VIF) was close to 1 for all of them.
- The four features together explain about 2% of the variation (R² = 0.022, F-test p = 0.45), and none is individually significant (p-values between 0.17 and 0.97).
- A cross-validated Random Forest also failed to predict excess return on unseen data (negative R²).

## Key Findings

1. **The typical IPO did not beat the Nifty50.** The median 1-year IPO return was between -5.4% and 0.4% across the two cohorts, compared with about 8% for the Nifty50.
2. **A high listing-day jump does not signal better returns.** High and low listing-day cohorts showed no statistically significant difference in excess return.
3. **A strong first month says little about what follows.** First-month profit and later profit are essentially uncorrelated, so a strong first month alone is not a reason to sell or hold.
4. **Subscription levels and market conditions on listing day do not predict 1-year excess return.**


## Note

This project analyses historical data for educational and portfolio purposes. It is not financial advice.
