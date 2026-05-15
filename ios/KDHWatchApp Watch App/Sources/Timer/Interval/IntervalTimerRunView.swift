//
//  Untitled.swift
//  Runner
//
//  Created by hawon on 5/12/26.
//
import SwiftUI
import AVFoundation

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
    @State private var audioPlayer: AVAudioPlayer?
 
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
        .onDisappear { timer?.invalidate() }
    }
 
    // MARK: - Timer Logic
    private func startTimer() {
        isReady = false
        currentPhase = .three
        phaseRemainingSeconds = currentPhase.durationSeconds
        totalRemainingSeconds = totalInputSeconds
 
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            guard totalRemainingSeconds > 0 else {
                timer?.invalidate()
                playFinishedSound()
                isReady = true
                return
            }

            totalRemainingSeconds -= 1
            phaseRemainingSeconds -= 1

            if phaseRemainingSeconds <= 0 {
                playPhaseChangeSound()

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
    }
 
    private func resetTimer() {
        timer?.invalidate()
        isReady = true
        currentPhase = .three
        phaseRemainingSeconds = IntervalPhase.three.durationSeconds
        totalRemainingSeconds = totalInputSeconds
        currentRound = 1
    }
    // interval_alarm.mp3 파일을 프로젝트에 추가해야 함
    // interval_finished.mp3 파일을 프로젝트에 추가해야 함
    private func playFinishedSound() {
        guard let url = Bundle.main.url(
            forResource: "finished",
            withExtension: "mp3"
        ) else {
            print("[Sound] interval_finished.mp3 파일 없음")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("[Sound] 완료 사운드 재생 실패: \(error)")
        }
    }
    private func playPhaseChangeSound() {
        guard let url = Bundle.main.url(
            forResource: "interval_alarm",
            withExtension: "mp3"
        ) else {
            print("[Sound] interval_alarm.mp3 파일 없음")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("[Sound] 재생 실패: \(error)")
        }
    }
}
