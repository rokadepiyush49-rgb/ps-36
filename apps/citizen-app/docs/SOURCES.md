# Data sources

Every dataset used or planned, with its URL, licence and exactly what it feeds.
Also rendered in the running application at `/method`.

## In use

| # | Dataset | URL | Licence | Feeds |
|---|---|---|---|---|
| 1 | SHRUG 2.2 (Development Data Lab) | https://www.devdatalab.org/shrug_download | **CC BY-NC-SA 4.0 — non-commercial** | Population (factor P), SC/ST share and deprivation (factor E), amenity coverage (factor G). Pre-joins Census PCA, Village Directory, SECC 2012, Mission Antyodaya 2020 and PMGSY on one stable village ID. |
| 2 | SHRUG open-source village polygons | https://docs.devdatalab.org | Same | The only free complete village boundary set for India. Not yet ingested — coordinates in this build are approximate centroids. |
| 3 | BBMP Grievances 2020–2025 + ward information | https://data.opencity.in/dataset/bbmp-grievances-data | **Public Domain (Open Definition)** | The urban half of the corpus is modelled on its category mix, ward distribution, text register and volume. |
| 4 | NFHS-5 district factsheets (2019–21) | https://rchiips.org/nfhs/factsheet_NFHS-5.shtml | CC BY 4.0 / public domain | District baselines for improved water, sanitation and electricity (factor G). |
| 5 | LGD — Local Government Directory | https://lgdirectory.gov.in/ | GoI reference data | **Not ingested.** See the landmine below. |
| 6 | Open Budgets India | https://openbudgetsindia.org/ | CC BY 4.0 | Local-body allocation context for the money join. |
| 7 | Jal Jeevan Mission — Har Ghar Jal | https://ejalshakti.gov.in/jjmreport/JJMHarGharJal.aspx | Public MIS, no stated open licence | Water-sector coverage. HTML scrape; district-level fallback if it fails. |
| 8 | 16th Finance Commission report | https://fincomindia.nic.in/ | GoI publication | Every permissibility rule in `src/lib/budget.ts` — untied share, tied categories (a) water and (b) sanitation, the road cap, the salary bar. |
| 9 | DARPG Comprehensive Guidelines for Handling Public Grievances (F.No. S-15/21/2021-PG-DARPG(e-7085), 23 Aug 2024) | https://darpg.gov.in/ | GoI publication | §2.5 — the exclusion this product exists to answer. |
| 10 | Bhuvan WMS (ISRO/NRSC) | https://bhuvan.nrsc.gov.in | Not stated | Optional flood-hazard / water-body overlay. One config line in MapLibre. |
| 11 | OpenStreetMap | https://www.openstreetmap.org | ODbL | Base map tiles, attributed in the UI. |

## Deliberately not used, with reasons

**PFMS** — login-walled, no public API. **eGramSwaraj web services** — explicitly
government-to-government, states test against internal IPs. **MPLADS** — constituency crosswalk
is not worth the cost. **SBM** — redundant with Mission Antyodaya. **NITI Aspirational Districts
dashboard** — no API, PDFs, SSL failures; the district list is hand-entered instead. **SDG India
Index** — state level only. **CPGRAMS open data** — national year-wise totals, two columns.
**State GIS portals** — view-only WebGIS.

## Two landmines

### 1. LGD codes ≠ Census 2011 codes

SHRUG, Census PCA, the Village Directory and all the polygons use **Census 2011** codes. JJM,
eGramSwaraj, Mission Antyodaya's own portal, SBM and LGD use **LGD** codes. Building that
crosswalk is the single biggest hidden time sink in projects of this shape.

**Mitigations, in order:** use SHRUG's *Location Names and Additional Keys* module, which carries
Census keys plus name strings; take Mission Antyodaya *through SHRUG* rather than through the MA
portal, which removes the biggest join from the critical path; fuzzy-match on names within a
district as a last resort (expect 85–92% at village level) **and display the match rate in the
UI**; never attempt a national crosswalk.

**Status in this build:** not performed. Every geo unit carries `lgd_code: null`, the UI says so
on every screen that would otherwise show one, and BBMP ward-name fuzzy matching runs at **92.1%**
with the rate displayed. Honesty about coverage is a strength in a civic-tech pitch.

### 2. The BBMP schema constrains the product

Header row, verified:

```
Complaint ID, Category, Sub Category, Grievance Date, Ward Name,
Grievance Status, Staff Remarks, Staff Name
```

Sample row: `20437520, Road Maintenance(Engg), Road cutting, 2023-12-31 11:29:00, Chamrajpet, Closed, Closed, Umesh/AEE`

Three consequences, designed around rather than papered over:

1. **No closure timestamp.** There is a grievance date and a status string. Time-to-resolution
   is *not computable* from this data, so **no SLA or time-to-resolution metric appears anywhere
   in this product**. Category mix over time and reports per ward per quarter are fully
   supported, and those are what the impact screen shows.
2. **`Ward Name` is free text and inconsistent** (`Chamrajpet` vs `Jnanabharathi Ward`).
   Normalised with a token-set ratio at threshold 85, and the match rate is on screen.
3. **2025 is a partial year** (through 19 June). Any trend chart over the raw file must be
   annotated or it shows a decline that does not exist.

## Provenance of the shipped corpus

Every record is **seeded and labelled** (`is_seeded: true`, visible badge):

- `provenance: "bbmp_pattern_derived"` — urban, modelled on the published BBMP distributions.
- `provenance: "synthetic_rural"` — rural, generated from an incident model with per-block
  reporting-lag profiles.

Coordinates are approximate centroids, hand-placed. Population, SC/ST share and infrastructure
coverage are modelled from published district distributions and perturbed per unit: realistic,
not real, and every screen that shows one shows its source beside it.
