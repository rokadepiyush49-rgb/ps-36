import '../domain/data_source.dart';

/// Transcribed from `docs/SOURCES.md`, which is the source of truth.
///
/// Kept as structured data rather than rendered markdown so the same content
/// can drive the provenance sheets elsewhere in the app.
abstract final class MethodContent {
  static const sources = <DataSource>[
    DataSource(
      index: 1,
      name: 'SHRUG 2.2 (Development Data Lab)',
      url: 'https://www.devdatalab.org/shrug_download',
      licence: 'CC BY-NC-SA 4.0 — non-commercial',
      feeds: 'Population (factor P), SC/ST share and deprivation (factor E), '
          'amenity coverage (factor G). Pre-joins Census PCA, Village '
          'Directory, SECC 2012, Mission Antyodaya 2020 and PMGSY on one '
          'stable village ID.',
    ),
    DataSource(
      index: 2,
      name: 'SHRUG open-source village polygons',
      url: 'https://docs.devdatalab.org',
      licence: 'CC BY-NC-SA 4.0 — non-commercial',
      feeds: 'The only free complete village boundary set for India.',
      status: SourceStatus.notIngested,
      note: 'Coordinates in this build are approximate centroids.',
    ),
    DataSource(
      index: 3,
      name: 'BBMP Grievances 2020–2025 + ward information',
      url: 'https://data.opencity.in/dataset/bbmp-grievances-data',
      licence: 'Public Domain (Open Definition)',
      feeds: 'The urban half of the corpus is modelled on its category mix, '
          'ward distribution, text register and volume.',
    ),
    DataSource(
      index: 4,
      name: 'NFHS-5 district factsheets (2019–21)',
      url: 'https://rchiips.org/nfhs/factsheet_NFHS-5.shtml',
      licence: 'CC BY 4.0 / public domain',
      feeds: 'District baselines for improved water, sanitation and '
          'electricity (factor G).',
    ),
    DataSource(
      index: 5,
      name: 'LGD — Local Government Directory',
      url: 'https://lgdirectory.gov.in/',
      licence: 'GoI reference data',
      feeds: 'Crosswalk between LGD and Census 2011 identifiers.',
      status: SourceStatus.notIngested,
      note: 'See the LGD/Census code mismatch below.',
    ),
    DataSource(
      index: 6,
      name: 'Open Budgets India',
      url: 'https://openbudgetsindia.org/',
      licence: 'CC BY 4.0',
      feeds: 'Local-body allocation context for the money join.',
    ),
    DataSource(
      index: 7,
      name: 'Jal Jeevan Mission — Har Ghar Jal',
      url: 'https://ejalshakti.gov.in/jjmreport/JJMHarGharJal.aspx',
      licence: 'Public MIS, no stated open licence',
      feeds: 'Water-sector coverage. HTML scrape; district-level fallback if '
          'it fails.',
    ),
    DataSource(
      index: 8,
      name: '16th Finance Commission report',
      url: 'https://fincomindia.nic.in/',
      licence: 'GoI publication',
      feeds: 'Every permissibility rule in the budget engine — untied share, '
          'tied categories (water and sanitation), the road cap, the salary '
          'bar.',
    ),
    DataSource(
      index: 9,
      name: 'DARPG Comprehensive Guidelines for Handling Public Grievances',
      url: 'https://darpg.gov.in/',
      licence: 'GoI publication',
      feeds: '§2.5 — the exclusion this product exists to answer.',
    ),
    DataSource(
      index: 10,
      name: 'Bhuvan WMS (ISRO/NRSC)',
      url: 'https://bhuvan.nrsc.gov.in',
      licence: 'Not stated',
      feeds: 'Flood-hazard and water-body overlay.',
      status: SourceStatus.optional,
    ),
    DataSource(
      index: 11,
      name: 'OpenStreetMap',
      url: 'https://www.openstreetmap.org',
      licence: 'ODbL',
      feeds: 'Base map tiles, attributed in the map view.',
    ),
  ];

  static const rejected = <RejectedSource>[
    RejectedSource(name: 'PFMS', reason: 'Login-walled, no public API.'),
    RejectedSource(
      name: 'eGramSwaraj web services',
      reason: 'Explicitly government-to-government; states test against '
          'internal IPs.',
    ),
    RejectedSource(
      name: 'MPLADS',
      reason: 'Constituency crosswalk is not worth the cost.',
    ),
    RejectedSource(
      name: 'SBM',
      reason: 'Redundant with Mission Antyodaya.',
    ),
    RejectedSource(
      name: 'NITI Aspirational Districts dashboard',
      reason: 'No API, PDFs, SSL failures. District list hand-entered instead.',
    ),
    RejectedSource(
      name: 'SDG India Index',
      reason: 'State level only.',
    ),
    RejectedSource(
      name: 'CPGRAMS open data',
      reason: 'National year-wise totals, two columns.',
    ),
    RejectedSource(
      name: 'State GIS portals',
      reason: 'View-only WebGIS.',
    ),
  ];

  static const landmines = <Landmine>[
    Landmine(
      title: 'LGD codes are not Census 2011 codes',
      body: 'SHRUG, Census PCA, the Village Directory and all the polygons use '
          'Census 2011 codes. JJM, eGramSwaraj, Mission Antyodaya’s own '
          'portal, SBM and LGD use LGD codes. Building that crosswalk is the '
          'single biggest hidden time sink in projects of this shape.',
      status: 'Not performed in this build. Every geographic unit carries a '
          'null LGD code and every screen that would otherwise show one says '
          'so. BBMP ward-name fuzzy matching runs at 92.1%, and that rate is '
          'displayed rather than hidden.',
    ),
    Landmine(
      title: 'The BBMP schema constrains the product',
      body: 'The published file carries a grievance date and a status string, '
          'but no closure timestamp. Ward Name is free text and inconsistent '
          '(“Chamrajpet” against “Jnanabharathi Ward”), and 2025 is a partial '
          'year through 19 June.',
      status: 'Time-to-resolution is not computable from this data, so no SLA '
          'or resolution-time metric appears anywhere in this product. '
          'Category mix over time and reports per ward per quarter are fully '
          'supported, and those are what the impact figures show. Ward names '
          'are normalised with a token-set ratio at threshold 85.',
    ),
  ];

  static const corpusNote =
      'Every record shipped with this build is seeded and labelled. Urban '
      'records are modelled on the published BBMP distributions; rural records '
      'come from an incident model with per-block reporting-lag profiles. '
      'Coordinates are approximate centroids, hand-placed. Population, SC/ST '
      'share and infrastructure coverage are modelled from published district '
      'distributions and perturbed per unit: realistic, not real — and every '
      'screen that shows one shows its source beside it.';

  /// The single most important consequence, surfaced on the impact screens.
  static const noSlaNote =
      'No SLA or time-to-resolution metric appears in this product. The source '
      'grievance data has no closure timestamp, so that number is not '
      'computable and would have to be invented.';
}
