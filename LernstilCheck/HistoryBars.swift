import SwiftUI

struct HistoryBars: View {
    @EnvironmentObject var app: AppState

    // einfache Farbwahl
    private func color(for s: Lernstil) -> Color {
        switch s {
        case .visuell:        return .blue
        case .auditiv:        return .teal
        case .kinaesthetisch: return .purple
        }
    }

    var body: some View {
        // die letzten 7 Einträge
        let items = Array(app.history.suffix(7))

        // 1) größter Rohwert (Int) über alle Einträge
        let maxRaw: Int = items
            .map { $0.totals.values.max() ?? 0 }  // aus jedem Result den größten Stilwert
            .max() ?? 1                            // größtes davon, fallback 1

        // 2) als CGFloat für die Geometrie
        let maxV: CGFloat = CGFloat(maxRaw)

        HStack(alignment: .bottom, spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.offset) { _, r in
                // dominante Kategorie für Farbe/Höhe
                let dominant = r.top.first ?? .visuell
                let value    = CGFloat(r.totals[dominant] ?? 0)

                VStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color(for: dominant).opacity(0.9))
                        .frame(width: 18, height: max(8, (value / maxV) * 110))

                    Text(dominant.rawValue)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.9))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
