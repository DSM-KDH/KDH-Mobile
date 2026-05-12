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
    let totalRounds: Int
    let isReady: Bool
 
    // 현재 페이즈 진행도 (1.0 → 0.0으로 줄어드는 것을 반전: 진한색이 소비됨)
    // 원형 타이머: 진한색이 채워진 상태에서 시작 → 시간이 지나면 연한색이 확장
    // → "소비된 비율"을 진한색 호(arc)로 표현 → consumed = 1 - remaining
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
            // 배경 원 (연한색)
            Circle()
                .stroke(.red50, lineWidth: 7)
 
            // 진행 원: 시간이 지날수록 진한색이 채워짐
            Circle()
                .trim(from: 0, to: phaseProgress)
                .stroke(
                    .red400,
                    style: StrokeStyle(lineWidth: 7, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: phaseProgress)
 
            VStack(spacing: 2) {
                // 상단: 현재 페이즈 라벨 (몇 분 뛰는 타임인지)
                Text(phase.label)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(.gray600)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
 
                // 현재 페이즈 타이머 (큰 숫자)
                Text(phaseTimeString)
                    .font(.system(size: 30, weight: .bold, design: .monospaced))
                    .foregroundStyle(Color(white: 0.15))
 
                if isReady {
                    Text("탭하여 시작")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.gray600)
                } else {
                    // 하단: 전체 남은 시간 + 회차
                    HStack(spacing: 4) {
                        Text(totalRemainingString)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.gray600)
                        Text("·")
                            .font(.system(size: 10))
                            .foregroundStyle(.gray600)
                        Text("\(currentRound)/\(totalRounds)회")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.gray600)
                    }
                }
            }
        }
    }
}
