import 'models/media_asset.dart';
import 'models/recommendation.dart';
import 'models/wellness_session.dart';

const offlineEssentials = <MediaAsset>[
  MediaAsset(
    id: -9001,
    title: 'A two-minute breathing reset',
    mediaType: 'article',
    fileUrl: '',
    description: 'A short calming exercise stored on this device.',
    transcript:
        'Sit or stand somewhere safe. Let your shoulders soften. Breathe in gently for four counts, hold for two, then breathe out for six. Repeat four times. Stop if you feel uncomfortable and return to your normal breathing.',
  ),
  MediaAsset(
    id: -9002,
    title: 'Ground yourself with your five senses',
    mediaType: 'article',
    fileUrl: '',
    description: 'A no-data grounding activity for overwhelming moments.',
    transcript:
        'Name five things you can see, four things you can feel, three things you can hear, two things you can smell, and one thing you can taste. Take your time. There is no need to rush or get it perfect.',
  ),
  MediaAsset(
    id: -9003,
    title: 'When to seek urgent help',
    mediaType: 'article',
    fileUrl: '',
    description: 'A simple safety reminder available without internet.',
    transcript:
        'Serenity Hub is not an emergency service. If you or another person may be in immediate danger, contact local emergency services, go to the nearest health facility, or ask a trusted person nearby to stay with you and help you reach care.',
  ),
  MediaAsset(
    id: -9004,
    title: 'Thought record: situation, feeling, response',
    mediaType: 'article',
    fileUrl: '',
    description: 'A CBT-informed reflection prompt for non-urgent moments.',
    transcript:
        'Write the situation in one sentence. Name the feeling and rate its intensity from one to ten. Notice the automatic thought, then write one balanced alternative that is kind, realistic, and specific.',
  ),
  MediaAsset(
    id: -9005,
    title: 'Preparing for a first therapy session',
    mediaType: 'article',
    fileUrl: '',
    description:
        'A reviewer-friendly overview of informed consent, goals, and questions.',
    transcript:
        'A first session often covers confidentiality, consent, goals, history, current stressors, and what support would feel useful. You can ask about training, approach, fees, cancellation rules, and how progress will be reviewed.',
  ),
];

const offlineSessions = <WellnessSession>[
  WellnessSession(
    id: -9101,
    title: 'Grounding after a stressful moment',
    category: 'stress',
    description:
        'A brief stabilizing practice with clear limits and no clinical claims.',
    targetMood: 'overwhelmed',
    difficulty: 'beginner',
    estimatedDurationSeconds: 300,
    isFeatured: true,
    mediaAsset: MediaAsset(
      id: -9201,
      title: 'Grounding after a stressful moment',
      mediaType: 'article',
      fileUrl: '',
      description: 'Five minutes of orientation, breath, and sensory contact.',
      durationSeconds: 300,
      transcript:
          'Place both feet on the floor if that is comfortable. Look around and name three neutral objects. Let your exhale be slightly longer than your inhale. Notice one place in the body that feels steady enough, even if it is small.',
    ),
  ),
  WellnessSession(
    id: -9102,
    title: 'Sleep wind-down reflection',
    category: 'sleep',
    description:
        'A low-stimulation evening check-in for users who want a softer landing.',
    targetMood: 'tired',
    difficulty: 'beginner',
    estimatedDurationSeconds: 420,
    isFeatured: true,
    mediaAsset: MediaAsset(
      id: -9202,
      title: 'Sleep wind-down reflection',
      mediaType: 'article',
      fileUrl: '',
      description: 'A quiet review of needs, boundaries, and next steps.',
      durationSeconds: 420,
      transcript:
          'Write down anything your mind is trying to hold overnight. Circle what can wait until tomorrow. Choose one small comfort cue, such as dim light, water, or putting the phone away for ten minutes.',
    ),
  ),
  WellnessSession(
    id: -9103,
    title: 'Anxiety signal map',
    category: 'anxiety',
    description:
        'A psychoeducation exercise that separates sensations, thoughts, and actions.',
    targetMood: 'anxious',
    difficulty: 'beginner',
    estimatedDurationSeconds: 480,
    mediaAsset: MediaAsset(
      id: -9203,
      title: 'Anxiety signal map',
      mediaType: 'article',
      fileUrl: '',
      description: 'Notice patterns without judging or diagnosing them.',
      durationSeconds: 480,
      transcript:
          'Draw three columns: body signals, thoughts, and urges. Add one or two examples under each. Then add one supportive response you can try, such as slowing down, asking for help, or returning to the present environment.',
    ),
  ),
  WellnessSession(
    id: -9104,
    title: 'Compassionate self-talk practice',
    category: 'reflection',
    description:
        'A short practice for replacing harsh internal language with grounded support.',
    targetMood: 'discouraged',
    difficulty: 'beginner',
    estimatedDurationSeconds: 360,
    mediaAsset: MediaAsset(
      id: -9204,
      title: 'Compassionate self-talk practice',
      mediaType: 'article',
      fileUrl: '',
      description: 'Practice a realistic, kinder inner response.',
      durationSeconds: 360,
      transcript:
          'Write the harsh sentence exactly as it appears. Now rewrite it as if you were speaking to someone you respect. Keep it honest and specific: this is hard, and one next step is enough.',
    ),
  ),
];

final offlineRecommendation = Recommendation(
  headline: 'Review pick: calm, consent-aware support',
  categories: ['stress', 'anxiety', 'reflection'],
  sessions: [offlineSessions[0], offlineSessions[2]],
  media: [offlineEssentials[4], offlineEssentials[2]],
);
