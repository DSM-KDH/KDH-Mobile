//
//  Untitled.swift
//  Runner
//
//  Created by hawon on 5/12/26.
//
import SwiftUI

struct IntervalTimerRunView: View {
    let totalMinutes: Int
 
    @State private var isReady: Bool = true
 
    // 전체 남은 시간(초)
    @State private var totalRemainingSeconds: Int = 0
 
    // 현재 페이즈
    @State private var currentPhase: IntervalPhase = .three
    // 현재 페이즈 남은 시간(초)
    @State private var phaseRemainingSeconds: Int = 0
 
    // 현재 회차 (1회 = 3분-1분-2분 = 6분 사이클)
    @State private var currentRound: Int = 1

    @State private var timer: Timer? = nil
    @StateObject private var soundPlayer = WatchTimerSoundPlayer(
        soundNames: ["interval_alarm", "finished"]
    )
 
    // 1사이클 = 6분 = 360초
    private let cycleDuration = 360
 
    private var totalInputSeconds: Int {
        totalMinutes*60
    }
 
    var body: some View {
        VStack(spacing: 14) {
            TimerCircleView(
                phaseRemainingSeconds: phaseRemainingSeconds,
                phase: currentPhase,
                totalRemainingSeconds: totalRemainingSeconds,
                totalInputSeconds: totalInputSeconds,
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
        .onAppear {
            totalRemainingSeconds = totalInputSeconds
            phaseRemainingSeconds = IntervalPhase.three.durationSeconds
        }
        .onDisappear {
            stopTimer()
            soundPlayer.stopAll()
        }
    }
 
    // MARK: - Timer Logic
    private func startTimer() {
        stopTimer()

        isReady = false
        currentPhase = .three
        phaseRemainingSeconds = currentPhase.durationSeconds
        totalRemainingSeconds = totalInputSeconds
 
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

                // 다음 페이즈로
                let nextPhase = currentPhase.next

                // run2 → run3 이면 새 회차
                if currentPhase == .two {
                    currentRound += 1
                }

                currentPhase = nextPhase
                phaseRemainingSeconds = nextPhase.durationSeconds
            }
        }
        timer?.tolerance = 0.1
    }
 
    private func resetTimer() {
        stopTimer()
        soundPlayer.stopAll()
        isReady = true
        currentPhase = .three
        phaseRemainingSeconds = IntervalPhase.three.durationSeconds
        totalRemainingSeconds = totalInputSeconds
        currentRound = 1
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
