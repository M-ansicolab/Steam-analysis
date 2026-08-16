# Project B — Steam Pricing, Discounting & Discovery — metrics.md

**Data source:** `win7guru/steam-dataset-2024` (GitHub, forked from `NewbieIndieGameDev/steam-insights`),
a public SQL-export mirror of the well-known Fronkon Games "Steam Games Dataset". Scrape date: October 2024.
Tables loaded: `games`, `genres`, `tags`, `reviews`, `steamspy_insights`, `categories`.
Loaded into `steam.db` (SQLite) via `build_db.py`. Raw row counts after cleaning:
games=140,082 · genres=353,339 · tags=1,744,632 · reviews=140,082 · steamspy=140,077 · categories=522,582.

---

## Layer 1 — Market structure (`sql/01_market_structure.sql`)

- **Catalog composition:** Indie is the dominant genre tag at **86,425 games (61.7% of the catalog)**,
  followed by Action (52,753), Adventure (50,835), Casual (48,633). RPG, Strategy, Simulation each ~24-25K.
- **Pricing:** of 140,082 games, **76,247 have a valid paid price** (mean €8.32, min €0.49, max €199.99 after
  excluding bundle-like outliers). Price quartiles: Q1 ≤ €2.39, Q2 ≤ €4.99, Q3 ≤ €9.99, Q4 up to €199.99 —
  **half the paid catalog is priced under €5.**
- **Free vs paid:** 24.0% of the catalog (33,661 games) is free-to-play; 76.0% (106,421) is paid.
- **Release cadence — the headline finding:** releases grew from **395 games in 2009 to 22,022 in 2024**,
  a ~56x increase. The steepest jump is 2013→2014 (494→1,649, coinciding with Steam Greenlight's ramp-up)
  and releases have kept accelerating every year since 2019. **This alone is the core strategic fact for
  an indie publisher: the market is dramatically more crowded than it was even 5 years ago.**
- **Genre crowding (last-2-years share vs all-time share):** Free To Play is gaining share fastest
  (7.59% all-time → 8.26% of 2023-24 releases). Utility/creative genres (Education, Audio/Video Production,
  Design & Illustration) are shrinking as a share of new releases — those authors seem to be leaving Steam
  as a distribution channel for games specifically.

## Layer 2 — Price & review relationships (`analysis_layers_2_3_5.py`)

Analysis base: 48,525 paid games (price >€0, <€150, ≥10 reviews).

- **Price vs. review score:** r = **0.123** (p < .001) — weak positive. Price barely predicts perceived quality.
- **Price vs. log(review volume):** r = **0.389** (p < .001) — moderate positive, and notably **stronger** than
  the score relationship. **This is the "they diverge" finding the brief flagged:** higher-priced games don't
  get much better reviews, but they do get more reviews (bigger games, bigger launches, more marketing reach —
  price here is a proxy for production scale, not quality).
- **Price-point clustering (psychological pricing):** top price points are €4.99 (4,550 games), €0.99 (3,388),
  €3.99 (3,103), €9.99 (2,452), €1.99 (2,348) — classic `.99` clustering dominates; round numbers like €10/€20
  barely register versus the €X.99 equivalents.
- **Price tier vs. review volume (median):**

  | Tier | N games | Avg review score | Median review volume |
  |---|---|---|---|
  | €0–5 | 22,395 | 6.29 | 36 |
  | €5–10 | 12,199 | 6.56 | 56 |
  | €10–20 | 10,228 | 6.75 | 140 |
  | €20–40 | 3,006 | 6.83 | 492 |
  | €40+ | 697 | 6.69 | 995 |

  Review volume scales much faster than review score across tiers — consistent with the correlation finding.

## Layer 3 — Discount analysis (`analysis_layers_2_3_5.py`)

- Data caveat logged explicitly: SteamSpy's `owners_range` is coarse (85% of games fall in the single
  "0–20,000 owners" bucket), so we use the **mean** of the bucket midpoint as a rough reach proxy, not median.
- **Discount depth vs. reach proxy (mean owners midpoint):**

  | Discount depth | N games | Mean owners proxy | Avg review score |
  |---|---|---|---|
  | 0% (no discount at snapshot) | 85,008 | 104,287 | — |
  | 1–10% | 123 | 41,545 | 4.2 |
  | 11–25% | 700 | 80,521 | 5.2 |
  | 26–50% | 1,633 | 113,953 | 5.3 |
  | 51–75% | 1,938 | 156,690 | 5.0 |
  | 76–100% | 1,489 | 174,053 | 5.3 |

- **Explicit correlational caveat (per the brief's Layer 5 rigor requirement):** deeper discounts correlate
  with higher apparent reach, but this is a **single cross-sectional snapshot**, not before/after data. Older,
  established back-catalog titles both (a) accumulate more owners over time and (b) get discounted more deeply
  in periodic sales — game **age** is a plausible confound for both variables. **We cannot claim discounting
  causes higher ownership from this data alone**; a real test would need the same game's owner count before
  and after a specific sale event (not available in this snapshot dataset).

## Layer 4 — Discovery & market gap analysis (`analysis_layer4_gaps.py`)

Restricted to games released 2021+ (current market), 9 core genres × top 60 tags, ≥5 reviewed games per
combination, `review_score > 0` (0 = "no user reviews yet" in Steam's schema, excluded as non-signal).

- 540 genre×tag combinations analyzed. Combo `n_games` distribution: p25=383, p50=1,042, p75=2,085.
- **34 underserved-but-well-received combinations found** (avg review score ≥ 60th percentile, supply ≤ 25th
  percentile). Top candidates:

  | Genre + Tag | N games | Avg review score | Median reviews |
  |---|---|---|---|
  | Racing + Pixel Graphics | 74 | 7.04 | 29.5 |
  | Sports + Retro | 128 | 7.02 | 48.5 |
  | RPG + Psychological Horror | 345 | 6.97 | 78 |
  | Strategy + Visual Novel | 269 | 6.93 | 61 |
  | Racing + Retro | 122 | 6.91 | 44 |
  | Strategy + Controller (support) | 328 | 6.88 | 36 |
  | Strategy + Difficult | 354 | 6.88 | 56.5 |
  | RPG + Difficult | 254 | 6.88 | 133.5 |

- **Most saturated combos for contrast:** Indie+Singleplayer (15,129 games), Indie+Indie (12,743),
  Casual+Casual (11,391), Adventure+Adventure (11,125) — all near or slightly below the median review
  score despite huge supply. **Being in the most crowded lane doesn't buy you a quality edge; it just buys
  you more competitors.**

## Layer 5 — Statistical rigour (`analysis_layers_2_3_5.py`)

Controlled OLS regression: `log(1 + total_reviews) ~ price + C(primary_genre) + release_year`

- N = 48,000, **R² = 0.237**
- `price` coefficient = **+0.0761** (p < .001) — holding genre and release year fixed, each additional €1
  of price is associated with ~7.9% more reviews (exp(0.0761)-1), consistent with price acting as a scale
  proxy rather than a quality proxy (ties back to Layer 2).
- `release_year` coefficient = **-0.157** (p < .001) — newer games have systematically fewer reviews at the
  same price and genre, which is expected (less time on the market to accumulate reviews) and is a reminder
  that release-year needs to stay in the model as a control, not be read as a "declining game quality" trend.
- **What we are NOT claiming:** R²=0.237 means price/genre/year jointly explain under a quarter of the
  variance in review volume — marketing spend, publisher backing, storefront placement, and word-of-mouth
  (all unobserved here) clearly matter more. This is correlational evidence about market structure, not a
  causal pricing model.

## Layer 6 — Recommendation

For an indie studio choosing a genre/price/timing strategy from this data:

> **Target Strategy + Visual Novel or RPG + Psychological Horror** (both show above-median reception with
> well below-median supply — 269 and 345 existing titles respectively vs. a market median of ~1,042 per
> combination). **Price at €9.99–€14.99** (the €10–20 tier shows a strong jump in median review volume
> — 140 vs. 56 in the €5–10 tier — without a proportional drop in review score). **Avoid leading with
> Indie+Singleplayer or Casual+Casual** as your primary positioning tags — they're the two most saturated
> combinations in the dataset (12,700+ and 11,400+ competing titles) with no reception advantage to show for it.
> On discounting: treat periodic discounting as a reach/visibility tool consistent with the broader catalog
> pattern, but do not expect it alone to substitute for genre/tag positioning — the discount-depth-to-reach
> relationship in this data is confounded with game age and cannot be read as causal.

---
*Every number above was produced by a script in this folder — see `sql/01_market_structure.sql`,
`analysis_layers_2_3_5.py`, `analysis_layer4_gaps.py`. Re-run any of them against `steam.db` to reproduce.*
