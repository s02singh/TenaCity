//
//  Types.swift
//  TenaCity
//
//  Created by Shikhar Gupta on 2/21/24.
//

import Foundation

// User
struct User: Hashable {
    let id: String
    let email: String
    let password: String
    let username: String
    let accountCreationDate: Date
    var userInvitedIDs: [String]
    var habitIDs: [String]
    var friendIDs: [String] // user ids
}

// Habit
struct Habit: Hashable {
    let id: String
    let name: String
    let buildingID: String
    var dates: [Date]
    var streak: Int
    var note: [String: String]
    var contributions: [String: Any]
    var isPublic: Bool
    var goal: Int           // # of progress user wants on habit
    var progress: Int       // # of progress towards goal for the day, resets daily
    var identifier: String  // eg. "Steps", "Hours", "etc"
}

// Post
struct Post: Hashable {
    let id: String
    let habitID: String
    let userID: String
    var votes: Int
    var description: String
    var interactedIDs: [String]
}

// Building
struct Building: Hashable {
    let id: String
    let name: String
    var levelsIDs: [String] // Skin ids
}

// Skin
struct Skin: Hashable {
    let id: String
    let url: String
}

let habitNames = ["Steps", "Distance", "Calories", "Gym Time", "Outside Time"]
let habitIdentifiers = ["Steps", "Miles", "Calories", "Minutes", "Minutes"]
let habitIcons = ["figure.walk", "figure.run", "flame.fill", "iphone", "message.fill"]

// User Extension
extension User {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "email": email,
            "password": password,
            "username": username,
            "accountCreationDate": accountCreationDate,
            "userInvitedIDs": userInvitedIDs,
            "habitIDs": habitIDs,
            "friendIDs": friendIDs
        ]
    }
}

// Habit Extension
extension Habit {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "name": name,
            "buildingID": buildingID,
            "dates": dates,
            "streak": streak,
            "note": note,
            "isPublic": isPublic,
            "goal": goal,
            "progress": progress,
            "identifier": identifier
        ]
    }
}

// Post Extension
extension Post {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "habitID": habitID,
            "userID": userID,
            "votes": votes,
            "description": description,
            "interactedIDs": interactedIDs
        ]
    }
}

// Building Extension
extension Building {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "name": name,
            "levelsIDs": levelsIDs
        ]
    }
}

// Skin Extension
extension Skin {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "url": url
        ]
    }
}
