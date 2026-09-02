import { GoogleGenAI, Type } from '@google/genai';
import { HttpsError, onCall } from 'firebase-functions/v2/https';
import { defineSecret } from 'firebase-functions/params';

/**
 * The Gemini API key. Stored in Secret Manager and injected at runtime — it is
 * never present in the Flutter app, in source control, or in any client
 * response. The mobile client only ever invokes this callable.
 */
const GEMINI_API_KEY = defineSecret('GEMINI_API_KEY');

const CATEGORIES = [
  'water', 'roads', 'lighting', 'sanitation', 'health',
  'education', 'electricity', 'transport', 'other',
] as const;

const SEVERITIES = ['low', 'medium', 'high', 'critical'] as const;

/**
 * Turns a citizen's own words — in any language they speak — into the
 * structured record the priority engine can rank.
 *
 * Returns exactly the shape `ReportAnalysis` expects on the client.
 */
export const analyzeReport = onCall(
  {
    region: 'asia-south1',
    secrets: [GEMINI_API_KEY],
    enforceAppCheck: true,
    // A citizen files a handful of reports, not hundreds.
    maxInstances: 20,
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Sign in before filing a report.');
    }

    const transcript = String(request.data?.transcript ?? '').trim();
    if (!transcript) {
      throw new HttpsError('invalid-argument', 'Tell us what the problem is.');
    }
    if (transcript.length > 4000) {
      throw new HttpsError('invalid-argument', 'That report is too long.');
    }

    const ai = new GoogleGenAI({ apiKey: GEMINI_API_KEY.value() });

    const response = await ai.models.generateContent({
      model: 'gemini-3-flash',
      contents: [
        {
          role: 'user',
          parts: [
            {
              text:
                'A citizen in an Indian district has reported a civic problem ' +
                'in their own words. Classify it for a government priority ' +
                'queue. Be conservative: only mark severity high or critical ' +
                'when the report describes a total failure, a health risk, or ' +
                'a problem that has gone unaddressed for weeks.\n\n' +
                `Report: "${transcript}"`,
            },
          ],
        },
      ],
      config: {
        temperature: 0.1,
        responseMimeType: 'application/json',
        responseSchema: {
          type: Type.OBJECT,
          properties: {
            category: { type: Type.STRING, enum: [...CATEGORIES] },
            severity: { type: Type.STRING, enum: [...SEVERITIES] },
            title: {
              type: Type.STRING,
              description: 'A short English noun phrase naming the need, e.g. "Drinking Water".',
            },
            mentionedLocation: {
              type: Type.STRING,
              description: 'Any place named in the report, or an empty string.',
            },
            summary: {
              type: Type.STRING,
              description: 'One or two neutral sentences an official can act on.',
            },
            detectedLanguage: {
              type: Type.STRING,
              description: 'BCP-47 code of the language the citizen used.',
            },
          },
          required: ['category', 'severity', 'title', 'summary'],
          propertyOrdering: [
            'category', 'severity', 'title',
            'mentionedLocation', 'summary', 'detectedLanguage',
          ],
        },
      },
    });

    const text = response.text;
    if (!text) {
      throw new HttpsError('internal', 'Could not understand that report.');
    }

    const parsed = JSON.parse(text) as Record<string, string>;

    // Never trust the model's word for an enum — clamp to the known set.
    const category = (CATEGORIES as readonly string[]).includes(parsed.category)
      ? parsed.category
      : 'other';
    const severity = (SEVERITIES as readonly string[]).includes(parsed.severity)
      ? parsed.severity
      : 'medium';

    return {
      category,
      severity,
      title: parsed.title ?? 'Civic Issue',
      mentionedLocation: parsed.mentionedLocation ?? '',
      summary: parsed.summary ?? transcript,
      detectedLanguage: parsed.detectedLanguage ?? 'en',
    };
  },
);
