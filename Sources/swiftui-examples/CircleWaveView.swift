//
//  CircleWaveView.swift
//  SwiftUI Examples
//
//  Created by Aynur Nasybullin on 09.10.2023.
//

import SwiftUI

public class CircleWaveViewModel: Identifiable, ObservableObject {
    let id = UUID().uuidString
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

public struct CircleWaveViewConfig {
    let colors: [Color]
    
    let position: CGPoint
    let minPosition: CGPoint
    let maxPosition: CGPoint
    let isRandomPosition: Bool
    
    let generationDuration: Double
    
    let liveCycleDuration: Double
    let minLiveCycleDuration: Double
    let maxLiveCycleDuration: Double
    let isRandomLiveCycleDuration: Bool
    
    let radius: CGFloat
    let minRadius: CGFloat
    let maxRadius: CGFloat
    let isRandomRadius: Bool
    
    let opacity: Double
    let minOpacity: Double
    let maxOpacity: Double
    let isRandomOpacity: Bool
    
    let blureRadius: CGFloat
    let isBlured: Bool
    
    public init(
        colors: [Color] = [.red, .green, .blue],
        
        position: CGPoint = .init(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY),
        minPosition: CGPoint = .zero,
        maxPosition: CGPoint = .init(x: UIScreen.main.bounds.width, y: UIScreen.main.bounds.height),
        isRandomPosition: Bool = true,
        
        generationDuration: Double = 2,
        
        liveCycleDuration: Double = 4,
        minLiveCycleDuration: Double = 3,
        maxLiveCycleDuration: Double = 5,
        isRandomLiveCycleDuration: Bool = true,
        
        radius: CGFloat = 100,
        minRadius: CGFloat = 50,
        maxRadius: CGFloat = 150,
        isRandomRadius: Bool = true,
        
        opacity: Double = 0.5,
        minOpacity: Double = 0.0,
        maxOpacity: Double = 1.0,
        isRandomOpacity: Bool = true,
        
        blureRadius: CGFloat = 10,
        isBlured: Bool = false
    ) {
        self.colors = colors
        
        self.position = position
        self.minPosition = minPosition
        self.maxPosition = maxPosition
        self.isRandomPosition = isRandomPosition
        
        self.generationDuration = generationDuration
        
        self.liveCycleDuration = liveCycleDuration
        self.minLiveCycleDuration = minLiveCycleDuration
        self.maxLiveCycleDuration = maxLiveCycleDuration
        self.isRandomLiveCycleDuration = isRandomLiveCycleDuration
        
        self.radius = radius
        self.minRadius = minRadius
        self.maxRadius = maxRadius
        self.isRandomRadius = isRandomRadius
        
        self.opacity = opacity
        self.minOpacity = minOpacity
        self.maxOpacity = maxOpacity
        self.isRandomOpacity = isRandomOpacity
        
        self.blureRadius = blureRadius
        self.isBlured = isBlured
    }
}

public struct CircleWaveView: View {
    @State private var circleWaves: [CircleWaveViewModel] = []

    private let options: CircleWaveViewConfig
    
    public init(_ options: CircleWaveViewConfig = .init()) {
        self.options = options
    }
    
    var body: some View {
        ZStack {
            ForEach(circleWaves) { circleWave in
                Circle()
                    .fill(RadialGradient(colors: [Color.clear,
                                                  circleWave.color.opacity(circleWave.opacity),
                                                  Color.clear],
                                         center: .center,
                                         startRadius: circleWave.startRadius,
                                         endRadius: circleWave.endRadius))
                    .position(circleWave.position)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + circleWave.duration) {
                            removeCircleWave(circleWave)
                        }
                    }
                    .blur(radius: getBlureRadius())
                    .animation(.easeOut(duration: circleWave.duration), value: circleWave.startRadius)
                    .animation(.easeOut(duration: circleWave.duration), value: circleWave.endRadius)
                    .onAppear {
                        circleWave.update()
                    }
            }
        }
        .onAppear {
            startTimer()
        }
    }
    
    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            addCircleWave()
        }
    }
    
    private func getPosition() -> CGPoint {
        options.isRandomPosition
        ? CGPoint(x: CGFloat.random(in: options.minPosition.x...options.maxPosition.x),
                  y: CGFloat.random(in: options.minPosition.y...options.maxPosition.y))
        : options.position
    }
    
    private func getDuration() -> Double {
        options.isRandomLiveCycleDuration
        ? Double.random(in: options.minLiveCycleDuration...options.maxLiveCycleDuration)
        : options.liveCycleDuration
    }
    
    private func getRadius() -> CGFloat {
        options.isRandomRadius
        ? CGFloat.random(in: options.minRadius...options.maxRadius)
        : options.radius
    }
    
    private func getOpacity() -> Double {
        options.isRandomOpacity
        ? Double.random(in: options.minOpacity...options.maxOpacity)
        : options.opacity
    }
    
    private func getRadiusDiff(_ radius: CGFloat) -> Double {
        Double.random(in: (radius / 2)...radius)
    }
    
    private func getBlureRadius() -> CGFloat {
        options.isBlured ? options.blureRadius : 0
    }
    
    private func addCircleWave() {
        let radius = getRadius()
        let circleWave = CircleWaveViewModel(
            color: options.colors.randomElement() ?? .white,
            position: getPosition(),
            duration: getDuration(),
            radius: radius,
            opacity: getOpacity(),
            radiusDiff: getRadiusDiff(radius)
        )
        
        circleWaves.append(circleWave)
    }
    
    private func removeCircleWave(_ circleWave: CircleWaveViewModel) {
        if let idx = circleWaves.firstIndex(where: { $0.id == circleWave.id }) {
            _ = circleWaves.remove(at: idx)
        }
    }
}

struct WaveView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            CircleWaveView()
        }
    }
}
