import SpriteKit

class SpermNode: SKNode {
    private let head = SKShapeNode(ellipseOf: CGSize(width: 20, height: 14))
    private let eye = SKShapeNode(circleOfRadius: 2.5)
    private let tail = SKShapeNode()

    private var tailPath: CGMutablePath = .init()
    private var time: CGFloat = 0
    private let tailLength = 25
    private let tailSegmentLength: CGFloat = 4
    private let tailAmplitude: CGFloat = 6
    private let tailFrequency: CGFloat = 2.2

    override init() {
        super.init()
        setupHead()
        setupEye()
        setupTail()
        startWiggling()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHead() {
        head.fillColor = .white
        head.strokeColor = .clear
        head.zPosition = 1
        addChild(head)
    }

    private func setupEye() {
        eye.fillColor = .black
        eye.strokeColor = .clear
        eye.zPosition = 2
        eye.position = CGPoint(x: 5.5, y: 2.5) // Slightly inset from front
        head.addChild(eye)
    }

    private func setupTail() {
        tail.strokeColor = .white
        tail.lineWidth = 3
        tail.lineCap = .round
        tail.zPosition = 0
        tail.position = CGPoint(x: -10, y: 0) // attach to rear
        addChild(tail)
    }

    private func startWiggling() {
        let update = SKAction.run { [weak self] in
            self?.updateTail()
        }
        let wait = SKAction.wait(forDuration: 1.0 / 60.0)
        run(SKAction.repeatForever(.sequence([update, wait])))
    }

    private func updateTail() {
        time += 0.1
        tailPath = CGMutablePath()
        tailPath.move(to: .zero)

        for i in 1..<tailLength {
            let progress = CGFloat(i) / CGFloat(tailLength)
            let x = CGFloat(i) * tailSegmentLength
            // Keep base rigid, wiggle tip only
            let tailMotionFactor: CGFloat = pow(progress, 1.8) // minimal at base, max at end
            let y = sin(CGFloat(i) * 0.4 + time * tailFrequency) * tailAmplitude * tailMotionFactor
            tailPath.addLine(to: CGPoint(x: -x, y: y))
        }

        tail.path = tailPath
    }

    func swim(in direction: CGVector) {
        let move = SKAction.move(by: direction, duration: 3.0)
        let angle = atan2(direction.dy, direction.dx)
        let rotate = SKAction.rotate(toAngle: angle, duration: 0.2, shortestUnitArc: true)
        run(.group([move, rotate]))
    }
}

