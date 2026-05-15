//
//  UsersResponse.swift
//  Runner
//
//  Created by hawon on 5/12/26.
//
struct ProfileResponse: Decodable {
    let id: Int
    let heightCm: Double
    let weightKg: Double
    let gender: String
    let recordedAt: String
    let nextReminderAt: String
}

struct UserResponse: Decodable {
    let name: String
    let profileImage: String
}
