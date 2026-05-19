import ActivityKit
import Foundation

@available(iOS 16.1, *)
public struct RoutineCreationAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        /// "loading" | "success" | "failure"
        var status: String
        var title: String
        var message: String
        /// 0.0 ~ 1.0
        var progress: Double
        /// 남은 예상 시간 (초)
        var remainingSeconds: Int
    }
}
