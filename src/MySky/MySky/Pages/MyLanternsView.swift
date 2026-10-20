//
//  MyLanternsView.swift
//  MySky
//
//  Created by Lika Nozadze on 19/10/2026.
//

import SwiftUI
import SwiftData

struct MyLanternsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ReleasedLantern.releasedAt, order: .reverse)
    private var lanterns: [ReleasedLantern]

    @State private var selectedLantern: ReleasedLantern?

    var body: some View {
        ZStack {
            SkyBackground()

            GeometryReader { geo in
               
                let ordered = Array(lanterns.reversed())
                let points = SkyLayout.positions(for: ordered.map { CGFloat($0.scale) }, in: geo.size)

                ForEach(Array(ordered.enumerated()), id: \.element.id) { index, lantern in
                    Lantern(type: lantern.type,
                            width: 40 * lantern.scale,
                            glowOpacity: 0.6,
                            glowRadius: 20)
                        .goFloating()
                        .onTapGesture { selectedLantern = lantern }
                        .position(points[index])
                }
            }

            if lanterns.isEmpty {
                Text("Your released lanterns will glow here")
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .sheet(item: $selectedLantern) { lantern in
            LanternDetailView(lantern: lantern) {
                selectedLantern = nil
                modelContext.delete(lantern)
            }
            .presentationDetents([.medium])
        }
    }
}


enum SkyLayout {

    static let insets = EdgeInsets(top: 80, leading: 36, bottom: 130, trailing: 36)

    static func positions(for scales: [CGFloat], in size: CGSize) -> [CGPoint] {
        let area = CGRect(
            x: insets.leading,
            y: insets.top,
            width: max(size.width - insets.leading - insets.trailing, 1),
            height: max(size.height - insets.top - insets.bottom, 1)
        )

        var placed: [(point: CGPoint, height: CGFloat)] = []
        var result: [CGPoint] = []
        var step = 0

        for scale in scales {
            let height = 40 * scale * 116 / 79
            var spacing: CGFloat = 0.65
            var chosen: CGPoint?

            while chosen == nil {
                for _ in 0..<150 {
                    step += 1
                    let candidate = point(at: step, in: area)
                    let isFree = placed.allSatisfy { other in
                        hypot(candidate.x - other.point.x, candidate.y - other.point.y)
                            >= spacing * (height + other.height)
                    }
                    if isFree { chosen = candidate; break }
                }
                if chosen == nil {
                    spacing -= 0.1
                    if spacing < 0.2 {
                        step += 1
                        chosen = point(at: step, in: area)
                    }
                }
            }

            placed.append((chosen!, height))
            result.append(chosen!)
        }
        return result
    }

    private static func point(at n: Int, in area: CGRect) -> CGPoint {
        let x = (0.5 + Double(n) * 0.7548776662466927).truncatingRemainder(dividingBy: 1)
        let y = (0.5 + Double(n) * 0.5698402909980532).truncatingRemainder(dividingBy: 1)
        return CGPoint(x: area.minX + CGFloat(x) * area.width,
                       y: area.minY + CGFloat(y) * area.height)
    }
}
