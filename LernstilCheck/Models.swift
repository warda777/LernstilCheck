import Foundation

enum Lernstil: String, CaseIterable {
    case visuell = "Visuell"
    case auditiv = "Auditiv"
    case kinaesthetisch = "Kinästhetisch"
}

struct Question: Identifiable {
    let id = UUID()
    let text: String
    let category: Lernstil
}

let questions: [Question] = [
    Question(text: "Ich merke mir Inhalte am besten mit Grafiken oder Skizzen.", category: .visuell),
    Question(text: "Erklärungen anhören hilft mir beim Lernen.", category: .auditiv),
    Question(text: "Durch Ausprobieren/Anfassen lerne ich am meisten.", category: .kinaesthetisch),
    Question(text: "Mindmaps und Diagramme geben mir schnell Überblick.", category: .visuell),
    Question(text: "Podcasts/Vorträge funktionieren für mich gut.", category: .auditiv),
    Question(text: "Prototypen bauen oder Dinge nachmachen hilft mir.", category: .kinaesthetisch),
    Question(text: "Mit Bildern/Infografiken verstehe ich Konzepte besser.", category: .visuell),
    Question(text: "Lautes Mitsprechen/Erklären festigt Wissen.", category: .auditiv)
]

final class QuizState: ObservableObject {
    @Published var answers: [Int?] = Array(repeating: nil, count: questions.count)

    func isAnswered(_ idx: Int) -> Bool { answers[idx] != nil }

    func score() -> [Lernstil: Int] {
        var dict: [Lernstil: Int] = [.visuell: 0, .auditiv: 0, .kinaesthetisch: 0]
        for (i, val) in answers.enumerated() {
            guard let v = val else { continue }
            dict[questions[i].category, default: 0] += v
        }
        return dict
    }

    struct Result {
        let top: [Lernstil]
        let totals: [Lernstil: Int]
        var isTie: Bool { top.count > 1 }
    }

    func result() -> Result {
        let totals = score()
        let maxVal = totals.values.max() ?? 0
        let top = totals.filter { $0.value == maxVal }.map { $0.key }
        return Result(top: top, totals: totals)
    }

    var allAnswered: Bool { answers.allSatisfy { $0 != nil } }

    func reset() {
        answers = Array(repeating: nil, count: questions.count)
    }
}
