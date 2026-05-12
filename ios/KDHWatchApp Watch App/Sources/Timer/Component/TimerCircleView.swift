//
//  Untitled.swift
//  Runner
//
//  Created by hawon on 5/12/26.
//
import SwiftUI

struct TimerCircleView: View {
    let phaseRemainingSeconds: Int       // 현재 페이즈 남은 시간
    let phase: IntervalPhase             // 현재 페이즈
    let totalRemainingSeconds: Int       // 전체 남은 시간
    let totalInputSeconds: Int           // 전체 입력 시간
    let currentRound: Int
    let isReady: Bool

    private var phaseProgress: CGFloat {
        guard phase.durationSeconds > 0 else { return 0 }
        let consumed = phase.durationSeconds - phaseRemainingSeconds
        return CGFloat(consumed) / CGFloat(phase.durationSeconds)
    }
 
    private var phaseTimeString: String {
        let m = phaseRemainingSeconds / 60
        let s = phaseRemainingSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }
 
    private var totalRemainingString: String {
        let h = totalRemainingSeconds / 3600
        let m = (totalRemainingSeconds % 3600) / 60
        let s = totalRemainingSeconds % 60
        if h > 0 {
            return String(format: "%d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }
 
    var body: some View {
        ZStack {
            Circle()
                .stroke(.red50, lineWidth: 5)

            Circle()
                .trim(from: 0, to: phaseProgress)
                .stroke(
                    .red400,
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: phaseProgress)
 
            VStack(spacing: 2) {
                Text(phase.label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.gray600)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)

                Text(phaseTimeString)
                    .font(.system(size: 30, weight: .bold, design: .monospaced))
                    .foregroundStyle(.gray800)
 
                if isReady {
                    Text("탭하여 시작")
                        .font(.system(size: 10, weight: .regular))
                        .foregroundStyle(.gray600)
                } else {
                    HStack(spacing: 4) {
                        Text(totalRemainingString)
                            .font(.system(size: 10, weight: .regular))
                            .foregroundStyle(.gray600)
                        Text("·")
                            .font(.system(size: 10))
                            .foregroundStyle(.gray600)
                        Text("\(currentRound)회")
                            .font(.system(size: 10, weight: .regular))
                            .foregroundStyle(.gray600)
                    }
                }
            }
        }
    }
}
