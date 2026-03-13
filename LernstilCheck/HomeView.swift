import SwiftUI

struct HomeView: View {
    @EnvironmentObject var app: AppState
    @StateObject private var quiz = QuizState()
    @State private var route: Int? = nil

    // MARK: Charts-Daten
    private var donutSegments: [Segment] {
        guard let r = app.lastResult else { return [] }
        return [
            Segment(value: Double(r.totals[.visuell] ?? 0),        color: .blue,   label: "Visuell"),
            Segment(value: Double(r.totals[.auditiv] ?? 0),        color: .teal,   label: "Auditiv"),
            Segment(value: Double(r.totals[.kinaesthetisch] ?? 0), color: .purple, label: "Kinästhetisch")
        ]
    }

    // MARK: Hintergrund
    private var background: some View {
        LinearGradient(colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.9)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
        .ignoresSafeArea()
    }

    // MARK: Hero
    private var hero: some View {
        Card {
            VStack(spacing: 10) {
                Text("Lernstil-Check")
                    .font(.system(size: 32, weight: .bold))
                    .multilineTextAlignment(.center)
                Text("Wähle deinen Test – und sieh dir zuletzt erzielte Ergebnisse an.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    // MARK: Letztes Ergebnis
    @ViewBuilder
    private var lastResultCard: some View {
        if app.lastResult != nil {
            Card {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Letztes Ergebnis")
                        .font(.headline)

                    DonutChart(segments: donutSegments)
                        .frame(height: 170)

                    DonutLegend(segments: donutSegments)
                        .padding(.top, 2)

                    if !app.history.isEmpty {
                        HistoryBars()
                            .frame(height: 96)
                            .padding(.top, 6)
                    }
                }
            }
        }
    }

    struct DonutLegend: View {
        let segments: [Segment]
        var body: some View {
            HStack(spacing: 12) {
                ForEach(segments) { s in
                    HStack(spacing: 6) {
                        Circle().fill(s.color).frame(width: 10, height: 10)
                        Text(s.label)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial.opacity(0.35))
                    .clipShape(Capsule())
                }
                Spacer(minLength: 0)
            }
        }
    }

    // MARK: Body
    var body: some View {
        ZStack {
            background

            ScrollView {
                VStack(spacing: 20) {
                    hero

                    // Unsichtbare Links (nur über 'route' aktiv)
                    NavigationLink(destination: QuizView().environmentObject(quiz),
                                   tag: 1, selection: $route) { EmptyView() }.hidden()

                    NavigationLink(
                        destination:
                            FeedbackView(onHome: { route = nil })
                                .environmentObject(app),
                        tag: 3, selection: $route
                    ) { EmptyView() }.hidden()

                    // Aktionen
                    CardButton(style: .primary, icon: "bolt.fill",
                               title: "Schnelltest (8 Fragen)",
                               action: { route = 1 })

                    CardButton(style: .secondary, icon: "hand.thumbsup.fill",
                               title: "Feedback geben",
                               action: { route = 3 })

                    lastResultCard
                }
                .padding(20)
                .padding(.bottom, 28)
                .foregroundColor(.white)
            }
        }
        .tint(.white)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Bausteine

/// Einheitliche Karte
private struct Card<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
            )
    }
}

/// Einheitlicher Button im Karten-Look (Primary = weiß gefüllt, Secondary = Glas)
private struct CardButton: View {
    enum Style { case primary, secondary }
    let style: Style
    let icon: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .imageScale(.medium)
                Text(title).fontWeight(.semibold)
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .opacity(0.6)
            }
            .padding(16)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(overlayStroke)
            .shadow(color: shadowColor, radius: shadowRadius, y: shadowY)
        }
        .buttonStyle(.plain)
        .foregroundColor(fg)
    }

    // Styles
    private var bg: some ShapeStyle {
        switch style {
        case .primary:   return AnyShapeStyle(Color.white)
        case .secondary: return AnyShapeStyle(Color.white.opacity(0.12))
        }
    }
    private var fg: Color {
        switch style {
        case .primary:   return .black
        case .secondary: return .white
        }
    }
    private var overlayStroke: some View {
        switch style {
        case .primary:
            return AnyView(EmptyView())
        case .secondary:
            return AnyView(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(0.45), lineWidth: 1)
            )
        }
    }
    private var shadowColor: Color {
        style == .primary ? .black.opacity(0.18) : .clear
    }
    private var shadowRadius: CGFloat { style == .primary ? 8 : 0 }
    private var shadowY: CGFloat { style == .primary ? 2 : 0 }
}
