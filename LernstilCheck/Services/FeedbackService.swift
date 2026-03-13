// FeedbackService.swift
import Foundation
import Supabase

enum FeedbackService {
    /// Deinen Client holst du dir aus deinem Provider
    static var client: SupabaseClient { SupabaseClientProvider.shared }

    /// Eintrag in die Tabelle `feedback` schreiben
    static func submit(_ rec: FeedbackRecord) async throws {
        try await client.database
            .from("feedback")
            .insert(rec)       // <-- nutzt CodingKeys für snake_case
            .execute()
    }
}
