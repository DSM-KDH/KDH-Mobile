#if os(watchOS)
import SwiftUI

struct MetronomeRunView: View {
    let bpm: Int
    let totalSeconds: Int

    @State private var isReady = true
    @State private var totalRemainingSeconds = 0
    @State private var secondTimer: Timer?
    @State private var beatTimer: Timer?
    @StateObject private var soundPlayer = WatchTimerSoundPlayer(
        soundNames: ["metronome", "finished"]
    )

    var body: some View {
        VStack(spacing: 14) {
            MetronomeTimerCircleView(
                bpm: bpm,
                totalRemainingSeconds: totalRemainingSeconds,
                totalInputSeconds: totalSeconds,
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
        }
        .onDisappear {
            stopTimers()
            soundPlayer.stopAll()
        }
    }

    private func startTimer() {
        guard bpm > 0, totalSeconds > 0 else { return }
        stopTimers()

        isReady = false
        totalRemainingSeconds = totalSeconds

        let beatInterval = 60.0 / Double(bpm)
        beatTimer = Timer.scheduledTimer(withTimeInterval: beatInterval, repeats: true) { _ in
            soundPlayer.play("metronome")
        }
        beatTimer?.tolerance = min(beatInterval * 0.1, 0.05)
        soundPlayer.play("metronome")

        secondTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            totalRemainingSeconds -= 1

            if totalRemainingSeconds <= 0 {
                stopTimers()
                soundPlayer.play("finished")
                isReady = true
            }
        }
        secondTimer?.tolerance = 0.1
    }

    private func resetTimer() {
        stopTimers()
        soundPlayer.stopAll()
        isReady = true
        totalRemainingSeconds = totalSeconds
    }

    private func stopTimers() {
        secondTimer?.invalidate()
        beatTimer?.invalidate()
        secondTimer = nil
        beatTimer = nil
    }
}

private struct MetronomeTimerCircleView: View {
    let bpm: Int
    let totalRemainingSeconds: Int
    let totalInputSeconds: Int
    let isReady: Bool

    private var progress: CGFloat {
        guard totalInputSeconds > 0 else { return 0 }
        let consumed = totalInputSeconds - max(totalRemainingSeconds, 0)
        return CGFloat(consumed) / CGFloat(totalInputSeconds)
    }

    private var timerText: String {
        let h = max(totalRemainingSeconds, 0) / 3600
        let m = (max(totalRemainingSeconds, 0) % 3600) / 60
        let s = max(totalRemainingSeconds, 0) % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    private var fixedTotalText: String {
        let h = totalInputSeconds / 3600
        let m = (totalInputSeconds % 3600) / 60
        let s = totalInputSeconds % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        ZStack {
            Circle().stroke(.red50, lineWidth: 5)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(.red400, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: progress)

            VStack(spacing: 2) {
                Text("\(bpm) BPM")
                    .font(.system(size: 10))
                    .foregroundStyle(.gray600)

                Text(timerText)
                    .font(.system(size: 30, weight: .bold, design: .monospaced))
                    .foregroundStyle(.gray800)

                if isReady {
                    Text("탭하여 시작")
                        .font(.system(size: 10))
                        .foregroundStyle(.gray600)
                } else {
                    Text("\(fixedTotalText)")
                        .font(.system(size: 10))
                        .foregroundStyle(.gray600)
                }
            }
        }
    }
}
#endif
