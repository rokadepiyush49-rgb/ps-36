import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/failure.dart';
import '../../../core/providers.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/speech_service.dart';
import '../../../shared/models/demand_enums.dart';
import '../../demands/domain/demand.dart';
import '../../demands/domain/demand_cluster.dart';
import '../domain/report_draft.dart';

/// Everything the Report screen needs to render, in one immutable value.
@immutable
class ReportState {
  const ReportState({
    this.draft = const ReportDraft(),
    this.isListening = false,
    this.isAnalyzing = false,
    this.isSearchingCluster = false,
    this.isSubmitting = false,
    this.similarCluster,
    this.submitted,
    this.error,
    this.speechAvailable = true,
  });

  final ReportDraft draft;
  final bool isListening;
  final bool isAnalyzing;

  /// Drives the "Finding similar requests in this area…" banner.
  final bool isSearchingCluster;
  final bool isSubmitting;

  /// Non-null once a matching cluster is found — routes to "You are not alone".
  final DemandCluster? similarCluster;
  final Demand? submitted;
  final Failure? error;
  final bool speechAvailable;

  bool get isBusy => isAnalyzing || isSearchingCluster || isSubmitting;

  ReportState copyWith({
    ReportDraft? draft,
    bool? isListening,
    bool? isAnalyzing,
    bool? isSearchingCluster,
    bool? isSubmitting,
    DemandCluster? similarCluster,
    Demand? submitted,
    Failure? error,
    bool? speechAvailable,
    bool clearError = false,
    bool clearCluster = false,
  }) =>
      ReportState(
        draft: draft ?? this.draft,
        isListening: isListening ?? this.isListening,
        isAnalyzing: isAnalyzing ?? this.isAnalyzing,
        isSearchingCluster: isSearchingCluster ?? this.isSearchingCluster,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        similarCluster:
            clearCluster ? null : (similarCluster ?? this.similarCluster),
        submitted: submitted ?? this.submitted,
        error: clearError ? null : (error ?? this.error),
        speechAvailable: speechAvailable ?? this.speechAvailable,
      );
}

/// Orchestrates the report flow: listen → transcribe → analyse (Gemini,
/// server-side) → pin location → look for a cluster → submit.
class ReportController extends Notifier<ReportState> {
  @override
  ReportState build() {
    ref.onDispose(() => ref.read(speechServiceProvider).stop());
    return const ReportState();
  }

  void setChannel(ReportChannel channel) {
    state = state.copyWith(draft: state.draft.copyWith(channel: channel));
  }

  Future<void> toggleListening() async {
    final speech = ref.read(speechServiceProvider);

    if (state.isListening) {
      await speech.stop();
      state = state.copyWith(isListening: false);
      if (state.draft.hasTranscript) await analyze();
      return;
    }

    final available = await speech.initialize();
    if (!available) {
      state = state.copyWith(
        speechAvailable: false,
        error: const PermissionFailure(
          'Microphone access is unavailable. You can type the request instead.',
        ),
      );
      return;
    }

    state = state.copyWith(
      isListening: true,
      clearError: true,
      draft: state.draft.copyWith(transcript: '', channel: ReportChannel.voice),
    );

    await speech.listen(
      onResult: (text) {
        state = state.copyWith(draft: state.draft.copyWith(transcript: text));
      },
      onDone: () async {
        if (!state.isListening) return;
        state = state.copyWith(isListening: false);
        if (state.draft.hasTranscript) await analyze();
      },
    );
  }

  void updateTranscript(String text) {
    state = state.copyWith(
      draft: state.draft.copyWith(transcript: text),
      clearError: true,
    );
  }

  /// Sends the transcript to the `analyzeReport` callable. The Gemini key lives
  /// in Cloud Functions; nothing model-related is on the device.
  Future<void> analyze() async {
    if (!state.draft.hasTranscript) return;
    state = state.copyWith(isAnalyzing: true, clearError: true);
    try {
      final analysis = await ref.read(reportRepositoryProvider).analyze(
            transcript: state.draft.transcript,
            photoPaths: state.draft.photoPaths,
          );
      state = state.copyWith(
        isAnalyzing: false,
        draft: state.draft.copyWith(
          analysis: analysis,
          locationLabel: state.draft.locationLabel.isEmpty
              ? analysis.mentionedLocation
              : state.draft.locationLabel,
        ),
      );
    } on Failure catch (failure) {
      state = state.copyWith(isAnalyzing: false, error: failure);
    }
  }

  Future<void> useCurrentLocation() async {
    state = state.copyWith(clearError: true);
    try {
      final position = await ref.read(locationServiceProvider).currentPosition();
      state = state.copyWith(
        draft: state.draft.copyWith(
          latitude: position.latitude,
          longitude: position.longitude,
          locationLabel: position.label,
        ),
      );
      await _searchForCluster();
    } on Failure catch (failure) {
      state = state.copyWith(error: failure);
    }
  }

  void setLocation({
    required double latitude,
    required double longitude,
    required String label,
  }) {
    state = state.copyWith(
      draft: state.draft.copyWith(
        latitude: latitude,
        longitude: longitude,
        locationLabel: label,
      ),
    );
    unawaited(_searchForCluster());
  }

  void addPhotos(List<String> paths) {
    state = state.copyWith(
      draft: state.draft.copyWith(
        photoPaths: <String>[...state.draft.photoPaths, ...paths],
      ),
    );
  }

  void removePhoto(int index) {
    final next = <String>[...state.draft.photoPaths]..removeAt(index);
    state = state.copyWith(draft: state.draft.copyWith(photoPaths: next));
  }

  /// The "Finding similar requests in this area…" step. If a cluster comes
  /// back, the UI offers "You are not alone" before filing a duplicate.
  Future<void> _searchForCluster() async {
    final draft = state.draft;
    final analysis = draft.analysis;
    if (analysis == null || !draft.hasLocation) return;

    state = state.copyWith(isSearchingCluster: true, clearCluster: true);
    try {
      final cluster = await ref.read(demandsRepositoryProvider).findSimilarCluster(
            category: analysis.category,
            latitude: draft.latitude!,
            longitude: draft.longitude!,
          );
      state = state.copyWith(isSearchingCluster: false, similarCluster: cluster);
    } on Failure catch (failure) {
      state = state.copyWith(isSearchingCluster: false, error: failure);
    }
  }

  Future<Demand?> submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      state = state.copyWith(
        error: const AuthFailure('Please sign in before filing a report.'),
      );
      return null;
    }
    if (!state.draft.canSubmit) {
      state = state.copyWith(
        error: const ValidationFailure(
          'Add what the problem is and where it is before submitting.',
        ),
      );
      return null;
    }

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final demand =
          await ref.read(reportRepositoryProvider).submit(state.draft, user.uid);
      state = state.copyWith(isSubmitting: false, submitted: demand);
      return demand;
    } on Failure catch (failure) {
      state = state.copyWith(isSubmitting: false, error: failure);
      return null;
    }
  }

  void reset() => state = const ReportState();

  void dismissError() => state = state.copyWith(clearError: true);
}

final reportControllerProvider =
    NotifierProvider.autoDispose<ReportController, ReportState>(
  ReportController.new,
);
