//
//  OverlappedCirclesView.swift
//  SwiftUI Examples
//
//  Created by Aynur Nasybullin on 10.10.2023.
//

import SwiftUI

public struct OverlappedCirclesViewConfig {
    let color: Color
    let count: Int
    
    let minRadius: CGFloat
    let maxRadius: CGFloat
    let radiusDiff: CGFloat
    
    let minOpacity: Double
    let maxOpacity: Double
    let opacityDiff: Double
    
    let minPosition: CGPoint
    let maxPosition: CGPoint
    let isRandomWalking: Bool
    
    let speed: CGFloat
    
    public init(
        color: Color = .blue,
        count: Int = 5,
        
        minRadius: CGFloat = 0,
        maxRadius: CGFloat = 500,
        radiusDiff: CGFloat? = .none,
        
        minOpacity: Double = 0.00,
        maxOpacity: Double = 0.5,
        opacityDiff: Double? = .none,
        
        position: CGPoint = .init(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY),
        minPosition: CGPoint = .zero,
        maxPosition: CGPoint = .init(x: UIScreen.main.bounds.maxX, y: UIScreen.main.bounds.maxY),
        isRandomWalking: Bool = true,
        
        speed: CGFloat = 50
    ) {
        self.color = color
        self.count = count
        
        self.minRadius = minRadius
        self.maxRadius = maxRadius
        self.radiusDiff = radiusDiff ?? (maxRadius - minRadius) / CGFloat(count)
        
        self.minOpacity = minOpacity
        self.maxOpacity = maxOpacity
        self.opacityDiff = opacityDiff ?? (maxOpacity - minOpacity) / Double(count)
        
        self.minPosition = minPosition
        self.maxPosition = maxPosition
        self.isRandomWalking = isRandomWalking
        
        self.speed = speed
    }
}

public struct OverlappedCirclesView: View {
    private let options: OverlappedCirclesViewConfig
    @State private var position: CGPoint = .init(x: UIScreen.main.bounds.midX,
                                                 y: UIScreen.main.bounds.midY)
    @State private var duration: CGFloat = 0
    
    public init(options: OverlappedCirclesViewConfig = .init()) {
        self.options = options
    }
    
    public var body: some View {
        ZStack {
            circles
                .position(position)
                .onAppear {
                    moveCircle()
                }
        }
    }
    
    private var circles: some View {
        ForEach(0..<options.count, id: \.self) { idx in
            Circle()
                .fill(RadialGradient(colors: [options.color.opacity(getOpacity(idx))],
                                     center: .center,
                                     startRadius: 0,
                                     endRadius: getRadius(idx)))
                .frame(width: getRadius(idx))
        }
    }
    
    private func moveCircle() {
        Task {
            let randomPosition = getPosition()
            let distance = distanceBetween(position, and: randomPosition)
            let duration = distance / options.speed
            
            withAnimation(.easeInOut(duration: TimeInterval(duration))) {
                position = randomPosition
            }
            
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            
            moveCircle()
        }
    }
    
    private func getOpacity(_ idx: Int) -> Double {
        options.maxOpacity - Double(idx) * options.opacityDiff
    }
    
    private func getRadius(_ idx: Int) -> CGFloat {
        options.minRadius + options.radiusDiff * CGFloat(idx + 1)
    }
    
    private func getPosition() -> CGPoint {
        options.isRandomWalking
        ? .init(x: CGFloat.random(in: options.minPosition.x...options.maxPosition.x),
                y: CGFloat.random(in: options.minPosition.y...options.maxPosition.y))
        : position
    }
    
    private func distanceBetween(_ point1: CGPoint, and point2: CGPoint) -> CGFloat {
        let deltaX = point2.x - point1.x
        let deltaY = point2.y - point1.y
        
        return sqrt(deltaX * deltaX + deltaY * deltaY)
    }
}

struct OverlappedCirclesView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            OverlappedCirclesView()
        }
    }
}
