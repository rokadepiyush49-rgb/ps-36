import { initializeApp } from 'firebase-admin/app';

initializeApp();

export { analyzeReport } from './analyzeReport';
export { computePriority } from './computePriority';
export { clusterDemand } from './clusterDemand';
export { submitVerification } from './submitVerification';
