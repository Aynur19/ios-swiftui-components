//
//  OverlappedCirclesView.swift
//  SwiftUI Examples
//
//  Created by Aynur Nasybullin on 10.10.2023.
//

import SwiftUI

public struct OverlappedCirclesView: View {
    private let color: Color
    private let count: Int
    
    private let minRadius: CGFloat
    private let maxRadius: CGFloat
    private let radiusDiff: CGFloat
    
    private let minOpacity: Double
    private let maxOpacity: Double
    private let opacityDiff: Double
    
    @State private var position: CGPoint
    private let minPosition: CGPoint
    private let maxPosition: CGPoint
    private let isRandomWalking: Bool
    
    private let speed: CGFloat
    
    @State private var duration: CGFloat = 0
    
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
        
        self.position = position
        self.minPosition = minPosition
        self.maxPosition = maxPosition
        self.isRandomWalking = isRandomWalking
        
        self.speed = 50
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
        ForEach(0..<count) { i in
            Circle()
                .fill(RadialGradient(colors: [color.opacity(getOpacity(i))],
                                     center: .center,
                                     startRadius: 0,
                                     endRadius: getRadius(i)))
                .frame(width: getRadius(i))
        }
    }
    
    private func moveCircle() {
        Task {
            let randomPosition = getPosition()
            let distance = distanceBetween(position, and: randomPosition)
            let duration = distance / speed

            withAnimation(.easeInOut(duration: TimeInterval(duration))) {
                position = randomPosition
            }

            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            
            moveCircle()
        }
    }
    
    private func getOpacity(_ idx: Int) -> Double {
        maxOpacity - Double(idx) * opacityDiff
    }
    
    private func getRadius(_ idx: Int) -> CGFloat {
        minRadius + radiusDiff * CGFloat(idx + 1)
    }
    
    private func getPosition() -> CGPoint {
        isRandomWalking
        ? .init(x: CGFloat.random(in: minPosition.x...maxPosition.x),
                y: CGFloat.random(in: minPosition.y...maxPosition.y))
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
