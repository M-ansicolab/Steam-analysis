# Project B — Steam Pricing, Discounting & Discovery

**Business question:** For an indie publisher, what pricing, discount, and release-timing strategy
maximizes players and revenue?

## Status: data loaded, all 6 layers run on real data, dashboard built.

## Data
Real Steam catalog export (`win7guru/steam-dataset-2024` on GitHub, mirroring the well-known
"Fronkon Games Steam Games Dataset" — the same one referenced on Kaggle). Pulled directly, not
synthetic. 140,082 games with genres, tags, reviews, and SteamSpy ownership/discount estimates.

## Project structure
```
project_b/
├── data/                       raw CSVs (unzipped from GitHub source)
├── build_db.py                 cleans + loads everything into steam.db (SQLite)
├── steam.db                    the database — query it directly
├── run_sql.py                  generic runner: python3 run_sql.py sql/<file>.sql
├── sql/
│   └── 01_market_structure.sql Layer 1 — pure SQL (genre dist, price dist, cadence, saturation)
├── analysis_layers_2_3_5.py    Layer 2 (price/review), Layer 3 (discounts), Layer 5 (regression)
├── analysis_layer4_gaps.py     Layer 4 — market gap / tag saturation analysis
├── metrics.md                  every real number produced, with the query/script that made it
├── dashboard/app.py            Streamlit dashboard (4 tabs, see below)
└── requirements.txt
```

## How to reproduce
```bash
pip install -r requirements.txt
python3 build_db.py                        # builds steam.db from data/*.csv
python3 run_sql.py sql/01_market_structure.sql
python3 analysis_layers_2_3_5.py
python3 analysis_layer4_gaps.py
cd dashboard && streamlit run app.py        # opens the interactive dashboard
```

## Key findings (full detail + numbers in `metrics.md`)
1. **Market crowding is the headline fact:** releases went from 395/year (2009) to 22,022/year (2024) — a
   ~56x increase. Any pricing/positioning strategy has to account for a radically more saturated market than
   5 years ago.
2. **Price predicts scale, not quality:** price↔review-score correlation is weak (r=0.12); price↔review-volume
   is moderate (r=0.39). Higher price buys reach/visibility more than it buys reception.
3. **Discounting's relationship to reach is confounded with game age** — flagged explicitly rather than
   overclaimed. This is the "I can't claim causality here because X" moment the brief asked for.
4. **Concrete market gaps identified:** Strategy+Visual Novel, RPG+Psychological Horror, Racing+Pixel Graphics
   are above-median reception, well below-median supply. Indie+Singleplayer and Casual+Casual are the most
   saturated combos with no reception edge to show for the crowding.
5. **Recommendation with numbers:** target an underserved genre+tag combo, price €9.99–14.99 (the tier where
   median review volume jumps from 56 to 140 without a proportional score drop), and don't lead with the two
   most saturated positioning tags in the dataset.

## What's next / possible extensions
- Join in a Steam player-count time series (if you want the temporal component the original brief mentioned)
  to move beyond the cross-sectional discount analysis and get closer to a real before/after read.
- Swap the primary-genre heuristic for a proper multi-label model if you want to stop collapsing games to one genre.
- Deploy `dashboard/app.py` to Streamlit Community Cloud for a live portfolio link.
