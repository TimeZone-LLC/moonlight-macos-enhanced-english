//
//  MLStreamPolicy.h
//  Moonlight for macOS
//
//  Pure decisions for stream pacing and audio buffering. No AppKit, no state, so the
//  rules can be exercised outside the app.
//

#pragma once

#include <stdbool.h>

typedef struct {
    int timingBufferLevel;          // 0 low, 1 standard, 2 high
    int framePacingMode;            // 0 legacy pacing, 1 default
    int smoothnessLatencyMode;      // 0 low latency, 1 balanced, 2 smoothness first, 3 custom
    int responsivenessBias;         // 0 to 2
    bool prioritizeResponsiveness;
    bool enableVsync;
    bool compatibilityMode;
    bool sdrCompatibilityWorkaround;
    bool tenBitVideo;
    bool enhancedRenderer;
    bool streamIsLocal;             // STREAM_CFG_LOCAL: host reached over the local network
    double displayRefreshRate;      // 0 when unknown
    int streamFrameRate;
    int frameQueueTargetOverride;   // below 0 when left automatic
} MLPacingPolicyInput;

enum {
    MLStreamPolicyAudioModeDirect = 0,
    MLStreamPolicyAudioModeEnhanced = 1,
};

static inline int MLClampPendingFrames(int value) {
    return value < 0 ? 0 : (value > 3 ? 3 : value);
}

// How many decoded frames the pull renderer leaves queued each display tick.
static inline int MLDesiredPendingFrames(const MLPacingPolicyInput *in) {
    if (in->frameQueueTargetOverride >= 0) {
        return MLClampPendingFrames(in->frameQueueTargetOverride);
    }

    int target = 1;
    switch (in->timingBufferLevel) {
        case 0: target = 0; break;
        case 2: target = 2; break;
        default: target = 1; break;
    }

    if (in->framePacingMode == 0) {
        if (target > 1) {
            target = 1;
        }
        if (in->smoothnessLatencyMode == 0) {
            target = 0;
        }
    }

    // On the local network a frame never has to wait for a late sibling, so the default
    // balanced profile presents frames as they arrive instead of parking one per tick.
    if (in->streamIsLocal && in->smoothnessLatencyMode == 1) {
        target = 0;
    }

    if (in->responsivenessBias >= 2) {
        target -= 2;
    } else if (in->responsivenessBias >= 1 || in->prioritizeResponsiveness) {
        target -= 1;
    }

    if (in->enableVsync && target < 1) {
        target = 1;
    }
    if (in->compatibilityMode && target < 1) {
        target = 1;
    }
    if (in->sdrCompatibilityWorkaround && !in->tenBitVideo) {
        target += 1;
    }
    if (in->enhancedRenderer && !in->enableVsync && !in->compatibilityMode) {
        target -= 1;
    }

    if (in->displayRefreshRate > 0 && in->displayRefreshRate < (double)in->streamFrameRate * 0.90) {
        if (in->compatibilityMode || in->enableVsync) {
            if (target < 1) {
                target = 1;
            }
        } else {
            target -= 1;
        }
    }

    return MLClampPendingFrames(target);
}

// Playout ring depth for the audio renderer. Direct mode on the local network runs a
// shorter ring because packet arrival jitter there is a fraction of a 5 ms frame.
static inline int MLAudioRingBufferDurationMs(int audioOutputMode, bool streamIsLocal) {
    switch (audioOutputMode) {
        case MLStreamPolicyAudioModeEnhanced:
            return 60;
        case MLStreamPolicyAudioModeDirect:
            return streamIsLocal ? 30 : 55;
        default:
            return 80;
    }
}
