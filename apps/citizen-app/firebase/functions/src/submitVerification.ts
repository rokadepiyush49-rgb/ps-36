import { getFirestore } from 'firebase-admin/firestore';
import { HttpsError, onCall } from 'firebase-functions/v2/https';

/**
 * Records a citizen's or field officer's verdict on completed work.
 *
 * Verification is the only step that decides whether public money actually
 * fixed anything, so it is written server-side: the client cannot mark its own
 * demand verified, and a "still broken" answer reopens the demand rather than
 * quietly closing it.
 */
export const submitVerification = onCall(
  { region: 'asia-south1', enforceAppCheck: true },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in to verify work.');
    }

    const demandId = String(request.data?.demandId ?? '');
    const isFixed = Boolean(request.data?.isFixed);
    const kind = request.data?.kind === 'field' ? 'field' : 'citizen';

    if (!demandId) {
      throw new HttpsError('invalid-argument', 'Which demand is this about?');
    }

    const db = getFirestore();
    const demandRef = db.collection('demands').doc(demandId);
    const demand = await demandRef.get();

    if (!demand.exists) {
      throw new HttpsError('not-found', 'That demand no longer exists.');
    }
    if (demand.data()?.status !== 'inProgress') {
      throw new HttpsError(
        'failed-precondition',
        'This demand is not awaiting verification yet.',
      );
    }

    await db.collection('verifications').add({
      demandId,
      verifierId: request.auth.uid,
      kind,
      isFixed,
      checklist: request.data?.checklist ?? [],
      photoUrls: request.data?.photoUrls ?? [],
      at: new Date(),
    });

    // A field officer's sign-off alone does not close a demand; the citizens
    // who reported it get the final say.
    if (isFixed && kind === 'citizen') {
      await demandRef.update({ status: 'citizenVerified' });
    } else if (!isFixed) {
      await demandRef.update({ status: 'funded', reopenedAt: new Date() });
    }

    return { ok: true };
  },
);
