//
//  Untitled.swift
//  Runner
//
//  Created by hawon on 5/12/26.
//
import SwiftUI
 
struct IntervalTimerView: View {
    // 3분~359분 (5시간 59분) 을 "총 분" 단위 하나로 관리
    @State private var selectedTotalMinutes: Int = 20
    @State private var navigateToTimer = false
 
    // 3...359
    private let minuteRange = Array(3...359)
 
    // 표시용: 총 분 → "Xh Ym" or "Ym"
    private func displayLabel(_ total: Int) -> String {
        let h = total / 60
        let m = total % 60
        if h > 0 && m > 0 { return "\(h)시간 \(m)분" }
        if h > 0           { return "\(h)시간" }
        return "\(m)분"
    }
 
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("타이머를 반복 시간")
                    .lineLimit(1)
                    .font(.kdf(.body5))
                    .foregroundStyle(.gray800)
                    .padding(.top, 14)
                    .padding(.horizontal, 8)
 
                // 단일 컬럼 wheel picker
                // watchOS 네이티브 스크롤·스냅 그대로 사용
                Picker("시간 선택", selection: $selectedTotalMinutes) {
                    ForEach(minuteRange, id: \.self) { min in
                        Text(displayLabel(min))
                            .font(.system(size: 15, weight: .medium))
                            .tag(min)
                    }
                }
                .pickerStyle(.wheel)
                .environment(\.colorScheme, .light)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 4)
 
                // 시작하기 버튼
                Button {
                    navigateToTimer = true
                } label: {
                    Text("시작하기")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color(red: 1.0, green: 0.45, blue: 0.45))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 10)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            .background(Color(white: 0.98))
            .navigationDestination(isPresented: $navigateToTimer) {
                IntervalTimerRunView(
                    totalMinutes: selectedTotalMinutes
                )
            }
        }
    }
}

// 1회 = 3분 - 1분 - 2분 = 6분
enum IntervalPhase: Int, CaseIterable {
    case three = 0
    case one = 1
    case two = 2
 
    var durationSeconds: Int {
        switch self {
        case .three:  return 180  // 3분
        case .one: return 60   // 1분
        case .two:  return 120  // 2분
        }
    }
 
    var label: String {
        switch self {
        case .three:  return "03:00"
        case .one: return "01:00"
        case .two:  return "02:00"
        }
    }

    var next: IntervalPhase {
        switch self {
        case .three:  return .one
        case .one: return .two
        case .two:  return .three
        }
    }
}
