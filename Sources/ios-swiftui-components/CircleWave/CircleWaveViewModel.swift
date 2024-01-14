//
//  CircleWaveViewModel.swift
//  
//
//  Created by Aynur Nasybullin on 25.10.2023.
//

import SwiftUI

public class CircleWaveViewModel: Identifiable, ObservableObject {
    public let id = UUID().uuidString
    let color: Color
    let position: CGPoint
    let duration: CGFloat
    let opacity: Double
    
    @Published var startRadius: CGFloat = 0
    @Published var endRadius: CGFloat = 0
    let maxRadius: CGFloat
    let radiusDiff: CGFloat
    
    public init(
        color: Color = .blue,
        position: CGPoint = .init(x: UIScreen.main.bounds.midX,
                                  y: UIScreen.main.bounds.midY),
        duration: CGFloat = 2,
        radius: CGFloat = 100,
        opacity: Double = 0.5,
        radiusDiff: CGFloat = 50
    ) {
        self.color = color
        self.position = position
        self.duration = duration
        self.maxRadius = radius
        self.opacity = opacity
        self.radiusDiff = radiusDiff
    }
    
    func update() {
        startRadius = maxRadius - radiusDiff
        endRadius = maxRadius
    }
}
