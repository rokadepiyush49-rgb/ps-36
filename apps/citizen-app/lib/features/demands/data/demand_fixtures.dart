import '../../../shared/models/demand_enums.dart';
import '../domain/demand.dart';
import '../domain/demand_cluster.dart';
import '../domain/demands_repository.dart';

/// Fixture data lifted straight from the Stitch designs so the mock build shows
/// the same figures the designs were reviewed with.
abstract final class DemandFixtures {
  static final DateTime _now = DateTime(2026, 8, 22);

  /// The five factors and their scores from "Why is this ranked #2?".
  static const waterScoreBreakdown = <PriorityFactor>[
    PriorityFactor(
      label: 'People affected',
      score: 94,
      explanation: '4,281 residents across 7 habitations depend on this source.',
    ),
    PriorityFactor(
      label: 'Infrastructure gap',
      score: 91,
      explanation: 'No alternative piped supply within 3km.',
    ),
    PriorityFactor(
      label: 'Equity index',
      score: 88,
      explanation: 'Ward ranks in the bottom quintile for civic spending.',
    ),
    PriorityFactor(
      label: 'Severity',
      score: 86,
      explanation: 'Complete failure of the only drinking water source.',
    ),
    PriorityFactor(
      label: 'Duration unaddressed',
      score: 71,
      explanation: 'Reported first 62 days ago with no allocation.',
    ),
  ];

  /// The seven-node timeline, with "Prioritised" as the active node.
  static final waterTimeline = <TimelineEvent>[
    TimelineEvent(
      status: DemandStatus.reported,
      state: TimelineState.complete,
      at: DateTime(2026, 6, 12),
    ),
    TimelineEvent(
      status: DemandStatus.verified,
      state: TimelineState.complete,
      at: DateTime(2026, 6, 15),
    ),
    TimelineEvent(
      status: DemandStatus.clustered,
      state: TimelineState.complete,
      at: DateTime(2026, 6, 20),
    ),
    const TimelineEvent(
      status: DemandStatus.prioritised,
      state: TimelineState.active,
      note: 'Ranked #2 for upcoming block grant.',
    ),
    const TimelineEvent(status: DemandStatus.funded, state: TimelineState.upcoming),
    const TimelineEvent(
        status: DemandStatus.inProgress, state: TimelineState.upcoming),
    const TimelineEvent(
        status: DemandStatus.citizenVerified, state: TimelineState.upcoming),
  ];

  static Demand get waterDemand => Demand(
        id: 'demand-water-0417',
        code: 'YDG-WTR-0417',
        title: 'Drinking Water Source Failure',
        description:
            'The only functioning handpump serving the habitation has been dry '
            'for two months. Residents walk 3km to the next source.',
        transcript:
            'Our village has not had a functioning drinking water source for '
            'the last two months.',
        reporterId: 'mock-uid',
        category: DemandCategory.water,
        severity: Severity.high,
        status: DemandStatus.prioritised,
        ward: 'Ward 4',
        district: 'Yadgir',
        latitude: 16.7700,
        longitude: 77.1376,
        distanceKm: 2.0,
        clusterId: 'cluster-water-0417',
        supporterCount: 41,
        rank: 2,
        totalRanked: 214,
        priorityScore: 86.4,
        scoreBreakdown: waterScoreBreakdown,
        timeline: waterTimeline,
        createdAt: DateTime(2026, 6, 12),
      );

  static Demand get roadDemand => Demand(
        id: 'demand-road-0221',
        code: 'YDG-ROD-0221',
        title: 'Approach Road Repair',
        description:
            'Large potholes forming after recent rains on the Main Bazaar '
            'approach road.',
        reporterId: 'mock-uid',
        category: DemandCategory.roads,
        severity: Severity.medium,
        status: DemandStatus.clustered,
        ward: 'Main Bazaar',
        district: 'Yadgir',
        latitude: 16.7620,
        longitude: 77.1290,
        distanceKm: 0.5,
        supporterCount: 28,
        rank: 1,
        totalRanked: 214,
        priorityScore: 91.2,
        createdAt: DateTime(2026, 8, 15),
        timeline: <TimelineEvent>[
          TimelineEvent(
            status: DemandStatus.reported,
            state: TimelineState.complete,
            at: DateTime(2026, 8, 15),
          ),
          TimelineEvent(
            status: DemandStatus.verified,
            state: TimelineState.complete,
            at: DateTime(2026, 8, 17),
          ),
          const TimelineEvent(
              status: DemandStatus.clustered, state: TimelineState.active),
          const TimelineEvent(
              status: DemandStatus.prioritised, state: TimelineState.upcoming),
          const TimelineEvent(
              status: DemandStatus.funded, state: TimelineState.upcoming),
          const TimelineEvent(
              status: DemandStatus.inProgress, state: TimelineState.upcoming),
          const TimelineEvent(
              status: DemandStatus.citizenVerified, state: TimelineState.upcoming),
        ],
      );

  static Demand get lightingDemand => Demand(
        id: 'demand-light-0108',
        code: 'YDG-LGT-0108',
        title: 'Street Lighting Installation',
        description: 'Dark stretch near the market needs lights.',
        reporterId: 'mock-uid',
        category: DemandCategory.lighting,
        severity: Severity.medium,
        status: DemandStatus.reported,
        ward: 'Sector B',
        district: 'Yadgir',
        latitude: 16.7550,
        longitude: 77.1410,
        distanceKm: 1.2,
        supporterCount: 9,
        createdAt: DateTime(2026, 8, 19),
      );

  /// "Funded & Fixed" card on the portal, and the one awaiting verification.
  static Demand get streetlightFixed => Demand(
        id: 'demand-light-0044',
        code: 'YDG-LGT-0044',
        title: 'Streetlight Installation',
        description: 'Dark alleyway near the market needed lights.',
        reporterId: 'mock-uid',
        category: DemandCategory.lighting,
        severity: Severity.low,
        status: DemandStatus.inProgress,
        ward: 'Ward 2',
        district: 'Yadgir',
        supporterCount: 34,
        createdAt: DateTime(2026, 7, 20),
        timeline: <TimelineEvent>[
          TimelineEvent(
            status: DemandStatus.reported,
            state: TimelineState.complete,
            at: DateTime(2026, 7, 20),
          ),
          TimelineEvent(
            status: DemandStatus.verified,
            state: TimelineState.complete,
            at: DateTime(2026, 7, 22),
          ),
          TimelineEvent(
            status: DemandStatus.clustered,
            state: TimelineState.complete,
            at: DateTime(2026, 7, 25),
          ),
          TimelineEvent(
            status: DemandStatus.prioritised,
            state: TimelineState.complete,
            at: DateTime(2026, 7, 28),
          ),
          TimelineEvent(
            status: DemandStatus.funded,
            state: TimelineState.complete,
            at: DateTime(2026, 8, 2),
          ),
          const TimelineEvent(
            status: DemandStatus.inProgress,
            state: TimelineState.active,
            note: 'Contractor has marked the work complete. Awaiting your check.',
          ),
          const TimelineEvent(
              status: DemandStatus.citizenVerified, state: TimelineState.upcoming),
        ],
      );

  static Demand get potholeDemand => Demand(
        id: 'demand-road-0318',
        code: 'YDG-ROD-0318',
        title: 'Pothole filling on Main St.',
        description: 'Large potholes forming after recent rains.',
        reporterId: 'mock-uid',
        category: DemandCategory.roads,
        severity: Severity.medium,
        status: DemandStatus.verified,
        ward: 'Main Street',
        district: 'Yadgir',
        supporterCount: 12,
        createdAt: DateTime(2026, 8, 15),
      );

  static List<Demand> get nearby =>
      <Demand>[roadDemand, waterDemand, lightingDemand];

  static List<Demand> get mine =>
      <Demand>[waterDemand, potholeDemand, streetlightFixed];

  static DemandCluster get waterCluster => const DemandCluster(
        id: 'cluster-water-0417',
        code: 'YDG-WTR-0417',
        title: 'Drinking Water Source Failure',
        category: DemandCategory.water,
        reportCount: 41,
        peopleAffected: 4281,
        mergedDuplicates: 6,
        habitationsAffected: 7,
        rank: 2,
        totalRanked: 214,
        centroidLat: 16.7700,
        centroidLng: 77.1376,
      );

  static const pulse = CommunityPulse(
    activeDemands: 41,
    peopleAffected: 4281,
    underReview: 12,
    funded: 3,
  );

  static DateTime get today => _now;
}
