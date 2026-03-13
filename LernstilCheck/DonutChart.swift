import SwiftUI

struct Segment: Identifiable {
    let id = UUID()
    let value: Double
    let color: Color
    let label: String
}

struct DonutSlice: Shape {
    var start: Angle
    var end: Angle

    func path(in rect: CGRect) -> Path {
        let r = min(rect.width, rect.height) / 2
        let c = CGPoint(x: rect.midX, y: rect.midY)
        var p = Path()
        p.addArc(center: c, radius: r, startAngle: start, endAngle: end, clockwise: false)
        p.addLine(to: c)
        p.closeSubpath()
        return p
    }
}

struct DonutChart: View {
    let segments: [Segment]
    var thickness: CGFloat = 18     // „Ringbreite“

    var body: some View {
        GeometryReader { geo in
            // Sichere Größen
            let w = geo.size.width
            let h = geo.size.height
            let side = max(0, min(w, h))

            // Ringbreite darf nicht größer als die Hälfte der kleineren Seite sein
            let safeT = min(thickness, side / 2)
            let inner = max(0, side - safeT * 2)

            // Total gegen 0 absichern (sonst NaN)
            let total = max(segments.map(\.value).reduce(0, +), 0.0001)
            let pairs = anglePairs(total: total)

            ZStack {
                // Kuchenstücke
                ForEach(segments.indices, id: \.self) { i in
                    let seg = segments[i]
                    let se  = pairs[i]
                    DonutSlice(start: se.start, end: se.end)
                        .fill(seg.color)
                    DonutSlice(start: se.start, end: se.end)
                        .stroke(Color.white.opacity(0.9), lineWidth: 1)
                }

                // Loch in der Mitte – robust geklemmt
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: inner, height: inner)
            }
            .frame(width: w, height: h) // mittig im zugewiesenen Frame
        }
        // Sorgt dafür, dass der GeometryReader eine sinnvolle Größe bekommt
        .aspectRatio(1, contentMode: .fit)
    }

    private func anglePairs(total: Double) -> [(start: Angle, end: Angle)] {
        var res: [(Angle, Angle)] = []
        var running = Angle(degrees: -90)
        for s in segments {
            let delta = Angle(degrees: (s.value / total) * 360.0)
            let start = running
            let end   = running + delta
            res.append((start, end))
            running = end
        }
        return res
    }
}
