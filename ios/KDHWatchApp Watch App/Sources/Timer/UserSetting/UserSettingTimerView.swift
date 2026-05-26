#if os(watchOS)
import SwiftUI

struct UserSettingTimerView: View {
    @State private var timerCount: Int = 1
    @State private var intervalSeconds: [Int] = [0, 0, 0, 0, 0]
    @State private var repeatHours: Int = 0
    @State private var repeatMinutes: Int = 20
    @State private var navigateToRun = false

    private var repeatTotalSeconds: Int {
        (repeatHours * 60 + repeatMinutes) * 60
    }

    private var isValid: Bool {
        guard timerCount > 0 else { return false }
        guard repeatTotalSeconds > 0 else { return false }
        let active = Array(intervalSeconds.prefix(timerCount))
        guard active.allSatisfy({ $0 > 0 }) else { return false }
        return repeatTotalSeconds >= active.reduce(0, +)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("사용자 설정 타이머")
                            .font(.kdf(.body3))
                            .foregroundStyle(.gray800)
                            .padding(.top, 6)

                        Text("몇 개의 타이머로 나눌까요?")
                            .font(.kdf(.caption1))
                            .foregroundStyle(.gray800)

                        Stepper {
                            HStack {
                                Text("\(timerCount)개")
                                    .font(.kdf(.body5))
                                    .foregroundStyle(.gray800)
                            }
                            .padding(.horizontal, 12)
                            .frame(height: 34)
                        } onIncrement: {
                            timerCount = min(timerCount + 1, 5)
                        } onDecrement: {
                            timerCount = max(timerCount - 1, 1)
                        }
                        .tint(.red200)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(.red200, lineWidth: 1)
                        )

                        Text("각 타이머 별 시간을 설정해주세요")
                            .font(.kdf(.caption1))
                            .foregroundStyle(.gray800)
                            .padding(.top, 4)

                        VStack(spacing: 8) {
                            ForEach(0..<timerCount, id: \.self) { idx in
                                let seconds = intervalSeconds[safe: idx] ?? 0
                                HStack(spacing: 8) {
                                    Text("\(idx + 1)번")
                                        .font(.kdf(.caption2))
                                        .foregroundStyle(.gray800)
                                        .frame(width: 22, alignment: .leading)

                                    HStack(spacing: 8) {
                                        Button("-30초") {
                                            intervalSeconds[idx] = max(intervalSeconds[idx] - 30, 0)
                                        }
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(.gray700)
                                        .buttonStyle(.plain)

                                        Text(durationLabel(for: seconds))
                                            .font(.kdf(.caption4))
                                            .foregroundStyle(seconds > 0 ? Color.gray800 : Color.gray400)

                                        Button("+30초") {
                                            intervalSeconds[idx] = min(intervalSeconds[idx] + 30, 24 * 3600 - 1)
                                        }
                                        .font(.system(size: 11, weight: .semibold))
                                        .foregroundStyle(.red400)
                                        .buttonStyle(.plain)
                                    }
                                    .padding(.horizontal, 10)
                                    .frame(height: 30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(seconds > 0 ? Color.red200 : Color.clear, lineWidth: 1)
                                    )
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.gray50)
                                    )
                                    Spacer()
                                }
                            }
                        }

                        Text("타이머를 몇 시간동안 반복할까요?")
                            .font(.kdf(.caption1))
                            .foregroundStyle(.gray800)
                            .padding(.top, 6)

                        RepeatTimeWheel(
                            hour: $repeatHours,
                            minute: $repeatMinutes
                        )
                    }
                    .padding(.horizontal, 10)
                    .padding(.bottom, 8)
                }

                TimerStartButton(
                    isEnabled: isValid,
                    action: { navigateToRun = true }
                )
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
            .background(Color.background)
            .environment(\.colorScheme, .light)
            .navigationDestination(isPresented: $navigateToRun) {
                UserSettingTimerRunView(
                    intervals: Array(intervalSeconds.prefix(timerCount)),
                    totalSeconds: repeatTotalSeconds
                )
            }
            .onChange(of: timerCount) { _, _ in
                syncIntervalCount()
            }
        }
    }

    private func syncIntervalCount() {
        if intervalSeconds.count < timerCount {
            intervalSeconds += Array(repeating: 0, count: timerCount - intervalSeconds.count)
        } else if intervalSeconds.count > timerCount {
            intervalSeconds = Array(intervalSeconds.prefix(timerCount))
        }
    }

    private func durationLabel(for seconds: Int) -> String {
        guard seconds > 0 else { return "시간" }
        let h = seconds / 3600
        let m = (seconds % 3600) / 60
        let s = seconds % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }
}

private struct RepeatTimeWheel: View {
    @Binding var hour: Int
    @Binding var minute: Int

    var body: some View {
        HStack(spacing: 6) {
            Picker("시", selection: $hour) {
                ForEach(0..<24, id: \.self) { h in Text("\(h)").tag(h) }
            }
            .pickerStyle(.wheel)
            .frame(width: 44, height: 96)

            Text("시간").font(.kdf(.caption4))

            Text("-").font(.kdf(.caption4)).foregroundStyle(.gray500)

            Picker("분", selection: $minute) {
                ForEach(0..<60, id: \.self) { m in Text("\(m)").tag(m) }
            }
            .pickerStyle(.wheel)
            .frame(width: 44, height: 96)

            Text("분").font(.kdf(.caption4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.red50.opacity(0.5))
        )
    }
}

private extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
#endif
