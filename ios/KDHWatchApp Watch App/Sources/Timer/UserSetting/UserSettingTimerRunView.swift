#if os(watchOS)
import SwiftUI

struct UserSettingTimerRunView: View {
    let intervals: [Int]
    let totalSeconds: Int

    @State private var isReady: Bool = true
    @State private var totalRemainingSeconds: Int = 0
    @State private var phaseRemainingSeconds: Int = 0
    @State private var currentPhaseIndex: Int = 0
    @State private var currentRound: Int = 1
    @State private var timer: Timer? = nil
    @StateObject private var soundPlayer = WatchTimerSoundPlayer(
        soundNames: ["interval_alarm", "finished"]
    )

    private var safeIntervals: [Int] {
        intervals.filter { $0 > 0 }
    }

    var body: some View {
        VStack(spacing: 14) {
            UserSettingTimerCircleView(
                phaseRemainingSeconds: phaseRemainingSeconds,
                phaseDurationSeconds: safeIntervals[safe: currentPhaseIndex] ?? 1,
                phaseLabel: phaseLabel,
                totalRemainingSeconds: totalRemainingSeconds,
                currentRound: currentRound,
                isReady: isReady
            )
            .frame(width: 160, height: 160)
            .onTapGesture {
                if isReady { startTimer() }
            }

            Button {
                resetTimer()
            } label: {
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isReady ? .gray300 : .red400)
                    .padding(10)
                    .background(isReady ? .gray50 : .red100)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(white: 0.98))
        .environment(\.colorScheme, .light)
        .onAppear {
            totalRemainingSeconds = totalSeconds
            phaseRemainingSeconds = safeIntervals.first ?? 0
        }
        .onDisappear {
            stopTimer()
            soundPlayer.stopAll()
        }
    }

    private var phaseLabel: String {
        let sec = safeIntervals[safe: currentPhaseIndex] ?? 0
        let m = sec / 60
        let s = sec % 60
        return String(format: "%d:%02d", m, s)
    }

    private func startTimer() {
        guard !safeIntervals.isEmpty else { return }
        stopTimer()

        isReady = false
        totalRemainingSeconds = totalSeconds
        currentPhaseIndex = 0
        currentRound = 1
        phaseRemainingSeconds = safeIntervals[0]

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            totalRemainingSeconds -= 1
            phaseRemainingSeconds -= 1

            if totalRemainingSeconds <= 0 {
                stopTimer()
                soundPlayer.play("finished")
                isReady = true
                return
            }

            if phaseRemainingSeconds <= 0 {
                soundPlayer.play("interval_alarm")
                if currentPhaseIndex == safeIntervals.count - 1 {
                    currentPhaseIndex = 0
                    currentRound += 1
                } else {
                    currentPhaseIndex += 1
                }
                phaseRemainingSeconds = safeIntervals[currentPhaseIndex]
            }
        }
        timer?.tolerance = 0.1
    }

    private func resetTimer() {
        stopTimer()
        soundPlayer.stopAll()
        isReady = true
        currentPhaseIndex = 0
        phaseRemainingSeconds = safeIntervals.first ?? 0
        totalRemainingSeconds = totalSeconds
        currentRound = 1
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

private struct UserSettingTimerCircleView: View {
    let phaseRemainingSeconds: Int
    let phaseDurationSeconds: Int
    let phaseLabel: String
    let totalRemainingSeconds: Int
    let currentRound: Int
    let isReady: Bool

    private var phaseProgress: CGFloat {
        guard phaseDurationSeconds > 0 else { return 0 }
        let consumed = phaseDurationSeconds - phaseRemainingSeconds
        return CGFloat(consumed) / CGFloat(phaseDurationSeconds)
    }

    private var phaseTimeString: String {
        let m = max(phaseRemainingSeconds, 0) / 60
        let s = max(phaseRemainingSeconds, 0) % 60
        return String(format: "%02d:%02d", m, s)
    }

    private var totalRemainingString: String {
        let h = max(totalRemainingSeconds, 0) / 3600
        let m = (max(totalRemainingSeconds, 0) % 3600) / 60
        let s = max(totalRemainingSeconds, 0) % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            Circle().stroke(.red50, lineWidth: 5)
            Circle()
                .trim(from: 0, to: phaseProgress)
                .stroke(.red400, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: phaseProgress)

            VStack(spacing: 2) {
                Text(phaseLabel)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.gray600)
                Text(phaseTimeString)
                    .font(.system(size: 30, weight: .bold, design: .monospaced))
                    .foregroundStyle(.gray800)

                if isReady {
                    Text("탭하여 시작")
                        .font(.system(size: 10))
                        .foregroundStyle(.gray600)
                } else {
                    HStack(spacing: 4) {
                        Text(totalRemainingString).font(.system(size: 10)).foregroundStyle(.gray600)
                        Text("·").font(.system(size: 10)).foregroundStyle(.gray600)
                        Text("\(currentRound)회").font(.system(size: 10)).foregroundStyle(.gray600)
                    }
                }
            }
        }
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
#endif
