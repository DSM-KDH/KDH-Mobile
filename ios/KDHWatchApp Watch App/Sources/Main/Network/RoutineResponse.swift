//
//  RoutineResponse.swift
//  Runner
//
//  Created by hawon on 5/11/26.
//
struct RoutineResponse: Decodable {
    let date: String
    let workouts: [Workout]
}

struct Workout: Decodable {
    let exerciseId: Int
    let sectionName: String
    let exerciseName: String
    let repsTime: String
    let completed: Bool
}
