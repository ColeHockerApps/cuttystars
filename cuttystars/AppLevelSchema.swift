import Foundation
import CoreGraphics

struct AppLevelSchema {

    struct Anchor {
        let id: Int
        let position: CGPoint
    }

    struct Rope {
        let id: Int
        let fromAnchor: Int
        let toAnchor: Int
        let length: CGFloat
        let isCuttable: Bool
    }

    struct Candy {
        let startPosition: CGPoint
        let radius: CGFloat
    }

    struct Blade {
        let position: CGPoint
        let radius: CGFloat
    }

    let levelIndex: Int
    let anchors: [Anchor]
    let ropes: [Rope]
    let candy: Candy
    let blades: [Blade]

    init(
        levelIndex: Int,
        anchors: [Anchor],
        ropes: [Rope],
        candy: Candy,
        blades: [Blade]
    ) {
        self.levelIndex = levelIndex
        self.anchors = anchors
        self.ropes = ropes
        self.candy = candy
        self.blades = blades
    }

    static func demo() -> AppLevelSchema {
        AppLevelSchema(
            levelIndex: 0,
            anchors: [
                Anchor(id: 0, position: CGPoint(x: 120, y: 80)),
                Anchor(id: 1, position: CGPoint(x: 220, y: 140))
            ],
            ropes: [
                Rope(id: 0, fromAnchor: 0, toAnchor: 1, length: 120, isCuttable: true)
            ],
            candy: Candy(
                startPosition: CGPoint(x: 170, y: 120),
                radius: 14
            ),
            blades: [
                Blade(position: CGPoint(x: 170, y: 200), radius: 18)
            ]
        )
    }
}
