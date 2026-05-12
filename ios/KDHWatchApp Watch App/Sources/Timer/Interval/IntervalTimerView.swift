//
//  Untitled.swift
//  Runner
//
//  Created by hawon on 5/12/26.
//
import SwiftUI
 
struct IntervalTimerView: View {
    @State private var selectedTotalMinutes: Int = 20
    @State private var navigateToTimer = false

    private let minuteRange = Array(3...359)

    private func displayLabel(_ total: Int) -> String {
        let h = total / 60
        let m = total % 60
        if h > 0 && m > 0 { return "\(h)시간 \(m)분" }
        if h > 0 { return "\(h)시간" }
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
 
                Button {
                    navigateToTimer = true
                } label: {
                    Text("시작하기")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.background)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(.red200)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 8)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            .background(Color.background)
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
        case .three:  return 180
        case .one: return 60
        case .two:  return 120
        }
    }
 
    var label: String {
        switch self {
        case .three:  return "3:00"
        case .one: return "1:00"
        case .two:  return "2:00"
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
