import ActivityKit
import Flutter
import Foundation

@available(iOS 16.1, *)
class LiveActivityHandler {
    private static var currentActivity: Activity<RoutineCreationAttributes>?

    static func handle(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as? [String: Any]
        switch call.method {
        case "startActivity":  startActivity(args: args, result: result)
        case "updateActivity": updateActivity(args: args, result: result)
        case "endActivity":    endActivity(result: result)
        default:               result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Start

    private static func startActivity(args: [String: Any]?, result: @escaping FlutterResult) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            result(nil)
            return
        }
        let state = makeContentState(from: args)
        do {
            let activity = try Activity.request(
                attributes: RoutineCreationAttributes(),
                contentState: state,
                pushType: nil
            )
            currentActivity = activity
            result(activity.id)
        } catch {
            result(FlutterError(code: "START_FAILED",
                                message: error.localizedDescription,
                                details: nil))
        }
    }

    // MARK: - Update

    private static func updateActivity(args: [String: Any]?, result: @escaping FlutterResult) {
        guard let activity = currentActivity else { result(nil); return }
        let state = makeContentState(from: args)
        Task {
            await activity.update(using: state)
            result(nil)
        }
    }

    // MARK: - End

    private static func endActivity(result: @escaping FlutterResult) {
        guard let activity = currentActivity else { result(nil); return }
        Task {
            await activity.end(dismissalPolicy: .immediate)
            currentActivity = nil
            result(nil)
        }
    }

    // MARK: - Helper

    private static func makeContentState(
        from args: [String: Any]?
    ) -> RoutineCreationAttributes.ContentState {
        RoutineCreationAttributes.ContentState(
            status:           args?["status"]           as? String ?? "loading",
            title:            args?["title"]            as? String ?? "AI 루틴 생성 중",
            message:          args?["message"]          as? String ?? "",
            progress:         args?["progress"]         as? Double ?? 0.0,
            remainingSeconds: args?["remainingSeconds"] as? Int    ?? 0
        )
    }
}
