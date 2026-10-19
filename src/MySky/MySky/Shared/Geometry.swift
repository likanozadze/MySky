//
//  Geometry.swift
//  MySky
//
//  Created by Mattia Silvestro on 19/10/2026.
//

import CoreGraphics

// These are useful functions for collision detection

// Shortest distance between the segment a1-a2 and the segment b1-b2 (0 if they cross)
func segmentDistance(_ a1: CGPoint, _ a2: CGPoint, _ b1: CGPoint, _ b2: CGPoint) -> CGFloat {
    func cross(_ o: CGPoint, _ p: CGPoint, _ q: CGPoint) -> CGFloat {
        (p.x - o.x) * (q.y - o.y) - (p.y - o.y) * (q.x - o.x)
    }
    // They cross if the ends of each segment are on opposite sides of the other one
    let crosses = cross(a1, a2, b1) * cross(a1, a2, b2) < 0 && cross(b1, b2, a1) * cross(b1, b2, a2) < 0
    if crosses { return 0 }

    // Otherwise the closest point is always one of the four ends
    func pointDistance(_ p: CGPoint, _ s1: CGPoint, _ s2: CGPoint) -> CGFloat {
        let dx = s2.x - s1.x, dy = s2.y - s1.y
        let lengthSquared = dx * dx + dy * dy
        guard lengthSquared > 0 else { return hypot(p.x - s1.x, p.y - s1.y) }
        let t = max(0, min(1, ((p.x - s1.x) * dx + (p.y - s1.y) * dy) / lengthSquared))
        return hypot(p.x - (s1.x + t * dx), p.y - (s1.y + t * dy))
    }
    return min(pointDistance(a1, b1, b2), pointDistance(a2, b1, b2),
               pointDistance(b1, a1, a2), pointDistance(b2, a1, a2))
}
