import ActivityKit
import SwiftUI
import WidgetKit

private let kRed  = Color(red: 0.78, green: 0.18, blue: 0.18)
private let kPink = Color(red: 0.98, green: 0.91, blue: 0.91)

// MARK: - Live Activity Widget

@available(iOS 16.1, *)
struct RoutineCreationLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RoutineCreationAttributes.self) { context in
            // ── 잠금 화면 / 배너 ────────────────────────────────────────
            LockScreenView(state: context.state)

        } dynamicIsland: { context in
            DynamicIsland {
                // ── Dynamic Island 확장 뷰 ───────────────────────────────
                DynamicIslandExpandedRegion(.leading) {
                    StatusIcon(status: context.state.status)
                        .padding(.leading, 6)
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(context.state.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(kRed)
                        ProgressBar(progress: context.state.progress)
                        Text(remainingLabel(context.state))
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                    }
                    .padding(.trailing, 6)
                }
            } compactLeading: {
                StatusIcon(status: context.state.status)
            } compactTrailing: {
                Text(percentLabel(context.state))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(kRed)
                    .monospacedDigit()
            } minimal: {
                StatusIcon(status: context.state.status)
            }
            .keylineTint(kRed)
        }
    }
}

// MARK: - Lock Screen View

@available(iOS 16.1, *)
private struct LockScreenView: View {
    let state: RoutineCreationAttributes.ContentState

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                StatusIcon(status: state.status)
                VStack(alignment: .leading, spacing: 2) {
                    Text(state.title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(kRed)
                    Text(state.message)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(percentLabel(state))
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(kRed)
                    .monospacedDigit()
            }
            ProgressBar(progress: state.progress)
            if state.status == "loading" {
                Text(remainingLabel(state))
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(kPink)
        .cornerRadius(16)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }
}

// MARK: - Progress Bar

private struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.5))
                    .frame(height: 6)
                RoundedRectangle(cornerRadius: 4)
                    .fill(kRed)
                    .frame(
                        width: geo.size.width * CGFloat(min(max(progress, 0), 1)),
                        height: 6
                    )
                    .animation(.easeOut(duration: 0.4), value: progress)
            }
        }
        .frame(height: 6)
    }
}

// MARK: - Status Icon

@available(iOS 16.1, *)
private struct StatusIcon: View {
    let status: String

    var body: some View {
        switch status {
        case "success":
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(.green)
        case "failure":
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 22))
                .foregroundColor(.red)
        default:
            ProgressView()
                .progressViewStyle(.circular)
                .tint(kRed)
                .scaleEffect(0.85)
                .frame(width: 22, height: 22)
        }
    }
}

// MARK: - Helpers

private func percentLabel(_ state: RoutineCreationAttributes.ContentState) -> String {
    switch state.status {
    case "success": return "100%"
    case "failure": return "실패"
    default:        return "\(Int(state.progress * 100))%"
    }
}

private func remainingLabel(_ state: RoutineCreationAttributes.ContentState) -> String {
    let s = state.remainingSeconds
    guard s > 0 else { return "거의 완료됐어요" }
    if s < 60 { return "약 \(s)초 남았어요" }
    let m = s / 60, r = s % 60
    return r == 0 ? "약 \(m)분 남았어요" : "약 \(m)분 \(r)초 남았어요"
}
