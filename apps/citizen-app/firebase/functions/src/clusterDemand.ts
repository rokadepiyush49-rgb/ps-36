import { getFirestore, GeoPoint } from 'firebase-admin/firestore';
import { onDocumentCreated } from 'firebase-functions/v2/firestore';

/** Two reports of the same category within this radius are the same problem. */
const CLUSTER_RADIUS_M = 800;

function haversineMetres(a: GeoPoint, b: GeoPoint): number {
  const R = 6_371_000;
  const toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(b.latitude - a.latitude);
  const dLng = toRad(b.longitude - a.longitude);
  const lat1 = toRad(a.latitude);
  const lat2 = toRad(b.latitude);

  const h =
    Math.sin(dLat / 2) ** 2 +
    Math.sin(dLng / 2) ** 2 * Math.cos(lat1) * Math.cos(lat2);
  return 2 * R * Math.asin(Math.sqrt(h));
}

/**
 * Merges a new report into an existing cluster, or opens a new one.
 *
 * This is what makes "You are not alone." true: forty people reporting the
 * same dry handpump become one demand with the weight of forty, instead of
 * forty tickets that each look ignorable.
 */
export const clusterDemand = onDocumentCreated(
  { document: 'demands/{demandId}', region: 'asia-south1' },
  async (event) => {
    const snapshot = event.data;
    if (!snapshot) return;

    const demand = snapshot.data();
    const geo: GeoPoint | undefined = demand.geo;
    if (!geo) return;

    const db = getFirestore();

    const candidates = await db
      .collection('clusters')
      .where('district', '==', demand.district)
      .where('category', '==', demand.category)
      .where('open', '==', true)
      .get();

    const match = candidates.docs.find((doc) => {
      const centroid: GeoPoint | undefined = doc.data().centroid;
      return centroid && haversineMetres(centroid, geo) <= CLUSTER_RADIUS_M;
    });

    if (match) {
      await match.ref.update({
        demandIds: [...(match.data().demandIds ?? []), snapshot.id],
        reportCount: (match.data().reportCount ?? 0) + 1,
      });
      await snapshot.ref.update({
        clusterId: match.id,
        status: 'clustered',
      });
      return;
    }

    const cluster = await db.collection('clusters').add({
      code: demand.code,
      title: demand.title,
      category: demand.category,
      district: demand.district,
      centroid: geo,
      demandIds: [snapshot.id],
      reportCount: 1,
      mergedDuplicates: 0,
      habitationsAffected: 1,
      peopleAffected: 0,
      open: true,
      createdAt: new Date(),
    });

    await snapshot.ref.update({ clusterId: cluster.id });
  },
);
