import { getFirestore } from 'firebase-admin/firestore';
import { onDocumentWritten } from 'firebase-functions/v2/firestore';

/**
 * The five published factors, and the weights the ranking uses.
 *
 * These are deliberately fixed and public: the citizen-facing "Why is this
 * ranked #2?" screen renders exactly these numbers, and an official cannot
 * move a demand up the queue by hand — only fund down it.
 */
export const PRIORITY_WEIGHTS = {
  peopleAffected: 0.30,
  infrastructureGap: 0.22,
  equityIndex: 0.20,
  severity: 0.18,
  durationUnaddressed: 0.10,
} as const;

const SEVERITY_SCORE: Record<string, number> = {
  low: 25, medium: 55, high: 86, critical: 97,
};

interface Factors {
  peopleAffected: number;
  infrastructureGap: number;
  equityIndex: number;
  severity: number;
  durationUnaddressed: number;
}

/** Each factor is normalised to 0–100 before weighting. */
export function scoreOf(factors: Factors): number {
  return (
    factors.peopleAffected * PRIORITY_WEIGHTS.peopleAffected +
    factors.infrastructureGap * PRIORITY_WEIGHTS.infrastructureGap +
    factors.equityIndex * PRIORITY_WEIGHTS.equityIndex +
    factors.severity * PRIORITY_WEIGHTS.severity +
    factors.durationUnaddressed * PRIORITY_WEIGHTS.durationUnaddressed
  );
}

export function factorsFor(demand: FirebaseFirestore.DocumentData): Factors {
  const supporters: number = demand.supporterCount ?? 0;
  const ageDays =
    (Date.now() - (demand.createdAt?.toMillis?.() ?? Date.now())) / 86_400_000;

  return {
    // Saturating curve: the 200th supporter should not count as much as the 2nd.
    peopleAffected: Math.min(100, Math.round(100 * (1 - Math.exp(-supporters / 60)))),
    infrastructureGap: demand.infrastructureGap ?? 50,
    equityIndex: demand.equityIndex ?? 50,
    severity: SEVERITY_SCORE[demand.severity as string] ?? 55,
    durationUnaddressed: Math.min(100, Math.round((ageDays / 90) * 100)),
  };
}

/**
 * Recomputes the score for a demand and re-ranks its district.
 *
 * Ranking is a server concern only: `rank`, `priorityScore` and
 * `scoreBreakdown` are all blocked from client writes by the security rules.
 */
export const computePriority = onDocumentWritten(
  { document: 'demands/{demandId}', region: 'asia-south1' },
  async (event) => {
    const after = event.data?.after;
    if (!after?.exists) return;

    const demand = after.data()!;
    const factors = factorsFor(demand);
    const score = scoreOf(factors);

    const db = getFirestore();
    await after.ref.update({
      priorityScore: score,
      scoreBreakdown: [
        { label: 'People affected', score: factors.peopleAffected },
        { label: 'Infrastructure gap', score: factors.infrastructureGap },
        { label: 'Equity index', score: factors.equityIndex },
        { label: 'Severity', score: factors.severity },
        { label: 'Duration unaddressed', score: factors.durationUnaddressed },
      ],
    });

    // Re-rank the district. Fine at district scale; if a district ever grows
    // past a few thousand open demands, move this to a scheduled batch.
    const district = demand.district;
    if (!district) return;

    const open = await db
      .collection('demands')
      .where('district', '==', district)
      .where('status', 'in', ['reported', 'verified', 'clustered', 'prioritised'])
      .orderBy('priorityScore', 'desc')
      .get();

    const batch = db.batch();
    open.docs.forEach((doc, index) => {
      batch.update(doc.ref, { rank: index + 1, totalRanked: open.size });
    });
    await batch.commit();
  },
);
