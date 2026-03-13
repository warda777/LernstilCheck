// FeedbackRecord.swift
import Foundation

/// Gemeinsames Modell für App <-> Supabase
struct FeedbackRecord: Codable {
    let klarheit: Int
    let design: Int
    let nuetzen: Int               // achte auf die Schreibweise
    let kommentar: String
    let deviceId: String?
    let appVersion: String?

    enum CodingKeys: String, CodingKey {
        case klarheit, design, nuetzen, kommentar
        case deviceId   = "device_id"      // Spaltenname in Supabase
        case appVersion = "app_version"    // Spaltenname in Supabase
    }
}
