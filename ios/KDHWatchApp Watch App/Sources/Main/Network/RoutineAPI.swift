//
//  RoutineAPI.swift
//  Runner
//
//  Created by hawon on 5/11/26.
//
import Moya
import Alamofire

enum RoutineAPI {
    case routines(date: String, accessToken: String)
    case updateCompletion(exerciseId: Int, completed: Bool, accessToken: String)
}

extension RoutineAPI: TargetType {
    var baseURL: URL {
        guard
            let base = Bundle.main.object(
                forInfoDictionaryKey: "KDHApiBaseURL"
            ) as? String,
            !base.isEmpty,
            let url = URL(string: base)
        else {
            fatalError("KDHApiBaseURL 설정 오류")
        }
        return url
    }

    var path: String {
        switch self {
        case .routines:
            return "/routines"
        case let .updateCompletion(exerciseId, _, _):
            return "/routines/exercises/\(exerciseId)/completion"
        }
    }

    var method: Moya.Method {
        switch self {
        case .routines:
            return .get
        case .updateCompletion:
            return .patch
        }
    }

    var task: Task {
        switch self {
        case let .routines(date, _):
            return .requestParameters(parameters: ["date": date], encoding: URLEncoding.queryString)
        case let .updateCompletion(_, completed, _):
            return .requestParameters(
                parameters: ["completed": completed],
                encoding: URLEncoding.queryString
            )
        }
    }

    var headers: [String : String]? {
        switch self {
        case let .routines(_, accessToken):
            return [
                "Accept": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
        case let .updateCompletion(_, _, accessToken):
            return [
                "Accept": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
        }
    }

    var sampleData: Data { Data() }
}
