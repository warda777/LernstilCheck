import SwiftUI

// Feedback-Modell
struct FeedbackEntry: Identifiable {
    let id = UUID()
    let date = Date()
    var klarheit: Int
    var design: Int
    var nuetzen: Int
    var kommentar: String
}

// Globale App-Daten
final class AppState: ObservableObject {

    // Ergebnisse
    @Published var lastResult: QuizState.Result?         // <— WICHTIG: verschachtelter Typ
    @Published var history: [QuizState.Result] = []

    // Feedbacks
    @Published var feedbacks: [FeedbackEntry] = []

    func store(_ r: QuizState.Result) {
        lastResult = r
        history.append(r)
    }

    func addFeedback(_ f: FeedbackEntry) {
        feedbacks.append(f)
    }
}
