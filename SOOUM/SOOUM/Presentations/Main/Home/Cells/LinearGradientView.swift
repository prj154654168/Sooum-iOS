//
//  LinearGradientView.swift
//  SOOUM
//
//  Created by Codex on 7/26/26.
//

import UIKit

final class LinearGradientView: UIView {
    
    struct GradientStop: Equatable {
        let color: UIColor
        let location: CGFloat
    }
    
    enum Direction: Equatable {
        case leftToRight
        case rightToLeft
        case topToBottom
        case bottomToTop
        case custom(start: CGPoint, end: CGPoint)
    }
    
    struct Configuration: Equatable {
        let stops: [GradientStop]
        let direction: Direction
    }
    
    override class var layerClass: AnyClass {
        CAGradientLayer.self
    }
    
    private var gradientLayer: CAGradientLayer {
        self.layer as! CAGradientLayer
    }
    
    var configuration: Configuration = .init(stops: [], direction: .leftToRight) {
        didSet {
            self.updateGradient()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func apply(_ configuration: Configuration) {
        guard self.configuration != configuration else { return }
        self.configuration = configuration
    }
    
    private func updateGradient() {
        let configuration = self.configuration
        
        self.gradientLayer.colors = configuration.stops.map(\.color.cgColor)
        self.gradientLayer.locations = configuration.stops.map {
            NSNumber(value: Float($0.location))
        }
        
        let points = configuration.direction.points
        self.gradientLayer.startPoint = points.start
        self.gradientLayer.endPoint = points.end
    }
}

private extension LinearGradientView.Direction {
    
    var points: (start: CGPoint, end: CGPoint) {
        switch self {
        case .leftToRight:
            return (.init(x: 0, y: 0.5), .init(x: 1, y: 0.5))
        case .rightToLeft:
            return (.init(x: 1, y: 0.5), .init(x: 0, y: 0.5))
        case .topToBottom:
            return (.init(x: 0.5, y: 0), .init(x: 0.5, y: 1))
        case .bottomToTop:
            return (.init(x: 0.5, y: 1), .init(x: 0.5, y: 0))
        case let .custom(start, end):
            return (start, end)
        }
    }
}
