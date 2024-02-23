//
//  Types.swift
//  TenaCity
//
//  Created by Shikhar Gupta on 2/21/24.
//

import Foundation

// User
struct User {
    let id: String
    let email: String
    let username: String
    let accountCreationDate: Date
    var userInvitedIDs: [String]
    var habitIDs: [String]
    var friendIDs: [String] // user ids
}

// Habit
struct Habit {
    let id: String
    let name: String
    let buildingID: String
    var dates: [Date]
    var streak: Int
    var note: String
    var isPublic: Bool
}

// Post
struct Post {
    let id: String
    let habitID: String
    let userID: String
    var votes: Int
    var description: String
    var interactedIDs: [String]
}

// Building
struct Building {
    let id: String
    var levelsIDs: [String] // Skin ids
}

// Skin
struct Skin {
    let id: String
    let url: String
}

// User Extension
extension User {
    var dictionary: [String: Any] {
        return [
            "id": id,
            "email": email,
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
            "isPublic": isPublic
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
