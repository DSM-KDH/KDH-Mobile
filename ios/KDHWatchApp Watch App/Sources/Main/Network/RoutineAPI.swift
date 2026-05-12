//
//  RoutineAPI.swift
//  Runner
//
//  Created by hawon on 5/11/26.
//
import Moya
import Alamofire

enum WatchRoutineTarget {
    case routines(baseURL: URL, date: String, accessToken: String)
}

extension WatchRoutineTarget: TargetType {
    var baseURL: URL {
        switch self {
        case let .routines(baseURL, _, _):
            return baseURL
        }
    }

    var path: String { "/routines" }

    var method: Moya.Method { .get }

    var task: Task {
        switch self {
        case let .routines(_, date, _):
            return .requestParameters(parameters: ["date": date], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String : String]? {
        switch self {
        case let .routines(_, _, accessToken):
            return [
                "Accept": "application/json",
                "Authorization": "Bearer \(accessToken)"
            ]
        }
    }

    var sampleData: Data { Data() }
}
