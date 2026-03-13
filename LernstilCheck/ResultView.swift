import SwiftUI
import ConfettiSwiftUI

struct ResultView: View {
    @EnvironmentObject var quiz: QuizState
    @EnvironmentObject var app: AppState
    @Environment(\.dismiss) private var dismiss

    @Binding var index: Int

    // Callback, den der Host (QuizView) liefern kann,
    // um nach dem Sheet-Pop die Navigation auf Home zu bringen.
    var onGoHome: (() -> Void)? = nil
    @State private var goHomeAfterDismiss = false

    @State private var confetti = 0

    private func color(for s: Lernstil) -> Color {
        switch s {
        case .visuell:        return .blue
        case .auditiv:        return .teal
        case .kinaesthetisch: return .purple
        }
    }

    /// Max-Punkte je Stil = (Anzahl Fragen der Kategorie) × 5
    private var maxPerStyle: [Lernstil: Int] {
        var dict: [Lernstil: Int] = [:]
        for s in Lernstil.allCases {
            let questionCount = questions.filter { $0.category == s }.count
            dict[s] = questionCount * 5
        }
        return dict
    }

    var body: some View {
        let result: QuizState.Result = quiz.result()

        ZStack {
            LinearGradient(
                colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.9)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerCard(result)
                    scoresCard(result)
                    tipsList(result)
                }
                .padding(20)
                .foregroundColor(.white)
                // Platz, damit die fixen Bottom-Buttons nichts überdecken
                .padding(.bottom, 120)
            }
        }
        .onAppear {
            app.store(result)
            confetti += 1
        }
        .confettiCannon(trigger: $confetti, num: 80)
        .tint(.white)
        .onDisappear {
            if goHomeAfterDismiss { onGoHome?() }
        }

        // FIXE Bottom-Leiste (bleibt unten beim Scrollen)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack {
                // Neu starten
                Button {
                    quiz.reset()
                    index = 0
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                        Text("Neu starten").fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                Spacer(minLength: 0)

                // Startseite
                Button {
                    goHomeAfterDismiss = true
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Text("Startseite").fontWeight(.semibold)
                        Image(systemName: "house.fill")
                    }
                    .foregroundColor(.black)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: .black.opacity(0.2), radius: 8, y: 3)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 14)
            .background(.ultraThinMaterial)
        }
    }

    // MARK: - Teil-Views

    @ViewBuilder
    private func headerCard(_ r: QuizState.Result) -> some View {
        let topJoined = r.top.map(\.rawValue).joined(separator: " & ")

        VStack(alignment: .leading, spacing: 8) {
            Text("Dein Ergebnis")
                .font(.system(size: 34, weight: .bold))

            if r.isTie {
                Text("Mischtyp: \(topJoined)")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
            } else if let first = r.top.first {
                Text("Dominant: \(first.rawValue)")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
            }

            HStack {
                ForEach(r.top, id: \.self) { s in
                    Text(s.rawValue)
                        .font(.footnote).bold()
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(color(for: s).opacity(0.25))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(color(for: s).opacity(0.8), lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.top, 4)
        }
        .padding(20)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func scoresCard(_ r: QuizState.Result) -> some View {
        let styles = Array(Lernstil.allCases)

        VStack(alignment: .leading, spacing: 12) {
            Text("Punktestände")
                .font(.headline)

            ForEach(styles, id: \.self) { s in
                let value = r.totals[s] ?? 0
                let maxV  = max(maxPerStyle[s] ?? 1, 1)
                ScoreBar(label: s.rawValue, value: value, max: maxV, tint: color(for: s))
            }
        }
        .padding(20)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func tipsList(_ r: QuizState.Result) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(r.top, id: \.self) { s in
                VStack(alignment: .leading, spacing: 8) {
                    Text("Tipps für \(s.rawValue)")
                        .font(.headline)
                    Text(tips(for: s))
                }
                .padding(16)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    private func tips(for style: Lernstil) -> String {
        switch style {
        case .visuell:
            return "Nutze Skizzen, Mindmaps, Diagramme, Farbcodes und Karteikarten mit Bildern."
        case .auditiv:
            return "Erkläre laut, nimm Sprachmemos auf, lerne mit Podcasts, tausche dich in Lerngruppen aus."
        case .kinaesthetisch:
            return "Lerne durch Nachmachen, Modelle/Prototypen, Hands-on-Übungen und Bewegungs-Pausen."
        }
    }
}

// MARK: - ScoreBar

struct ScoreBar: View {
    let label: String
    let value: Int
    let max: Int
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label).bold()
                Spacer()
                Text("\(value)/\(max)")
                    .foregroundColor(.white.opacity(0.9))
            }
            GeometryReader { geo in
                let progress: CGFloat = max == 0 ? 0 : CGFloat(value) / CGFloat(max)
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.18))
                    Capsule()
                        .fill(tint)
                        .frame(width: geo.size.width * progress)
                        .animation(.easeInOut(duration: 0.6), value: progress)
                }
            }
            .frame(height: 10)
        }
    }
}
