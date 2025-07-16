import SpriteKit
import UIKit

class SpermScene: SKScene {

    override init(size: CGSize) {
        super.init(size: size)
        scaleMode = .resizeFill
        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        addGradientBackground()
    }

    private func addGradientBackground() {
        let gradient = SKSpriteNode(texture: makeGradientTexture(size: size))
        gradient.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gradient.zPosition = -10
        gradient.size = size
        gradient.blendMode = .replace
        addChild(gradient)
    }

    private func makeGradientTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { ctx in
            let colors = [UIColor.purple.withAlphaComponent(0.8).cgColor,
                          UIColor.systemPink.withAlphaComponent(0.9).cgColor] as CFArray
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors, locations: nil)!
            ctx.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: 0, y: 0),
                end: CGPoint(x: size.width, y: size.height),
                options: []
            )
        }
        return SKTexture(image: image)
    }

    func emitSperm(from point: CGPoint) {
        let sperm = SpermNode()
        sperm.position = point
        addChild(sperm)

        let angle = CGFloat.random(in: 0..<2 * .pi)
        let distance: CGFloat = 1000
        let dx = cos(angle) * distance
        let dy = sin(angle) * distance
        let direction = CGVector(dx: dx, dy: dy)

        sperm.swim(in: direction)

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            sperm.removeFromParent()
        }
    }

    func emitSweat(from point: CGPoint) {
        let dropletCount = Int.random(in: 6...12)
        let capsuleWidth: CGFloat = 240
        let capsuleHeight: CGFloat = 48
        let cornerRadius: CGFloat = capsuleHeight / 2

        for _ in 0..<dropletCount {
            let x = CGFloat.random(in: -capsuleWidth / 2 ... capsuleWidth / 2)

            let edgeCutoff = capsuleWidth / 2 - cornerRadius
            let yRange: CGFloat
            if abs(x) <= edgeCutoff {
                yRange = cornerRadius
            } else {
                let dx = abs(x) - edgeCutoff
                yRange = sqrt(max(0, cornerRadius * cornerRadius - dx * dx))
            }

            let y = CGFloat.random(in: -yRange...yRange)

            let droplet = SKShapeNode(path: dropletPath())
            droplet.fillColor = .white
            droplet.strokeColor = .clear
            droplet.alpha = 0.9
            droplet.zPosition = 5
            droplet.setScale(CGFloat.random(in: 0.7...1.2))
            droplet.position = CGPoint(x: point.x + x, y: point.y + y)

            addChild(droplet)

            let fall = SKAction.moveBy(x: 0, y: CGFloat.random(in: -50 ... -30), duration: 0.4)

            let splash = SKAction.group([
                SKAction.scale(to: 1.4, duration: 0.08),
                SKAction.fadeAlpha(to: 0.5, duration: 0.08)
            ])

            let slide = SKAction.moveBy(x: CGFloat.random(in: -4...4), y: -40, duration: 0.8)
            slide.timingMode = .easeOut

            let steam = SKAction.run {
                self.emitSteam(at: CGPoint(x: droplet.position.x, y: droplet.position.y - 40))
            }

            let fadeOut = SKAction.fadeOut(withDuration: 0.3)
            let remove = SKAction.removeFromParent()

            let full = SKAction.sequence([fall, splash, slide, steam, fadeOut, remove])
            droplet.run(full)
        }
    }

    func emitSteam(at point: CGPoint) {
        let puff = SKShapeNode(circleOfRadius: CGFloat.random(in: 10...14))
        puff.fillColor = .white
        puff.strokeColor = .clear
        puff.alpha = 0.4
        puff.zPosition = 4
        puff.position = point
        addChild(puff)

        let expand = SKAction.scale(to: 2.5, duration: 0.4)
        let fade = SKAction.fadeOut(withDuration: 0.4)
        let remove = SKAction.removeFromParent()
        puff.run(SKAction.sequence([SKAction.group([expand, fade]), remove]))
    }

    private func dropletPath() -> CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addCurve(to: CGPoint(x: 4, y: -10),
                      controlPoint1: CGPoint(x: 6, y: -2),
                      controlPoint2: CGPoint(x: 6, y: -8))
        path.addCurve(to: CGPoint(x: -4, y: -10),
                      controlPoint1: CGPoint(x: 2, y: -12),
                      controlPoint2: CGPoint(x: -2, y: -12))
        path.close()
        return path.cgPath
    }
}

