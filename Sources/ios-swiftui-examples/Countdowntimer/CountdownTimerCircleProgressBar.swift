//
//  CountdownTimerCircleProgressBar.swift
//
//
//  Created by Aynur Nasybullin on 13.01.2024.
//

import SwiftUI

@available(iOS 15.0, *)
public struct CountdownTimerCircleProgressBar<BackShapeStyleType, FrontShapeStyleType, ContentViewType>: View
where BackShapeStyleType: ShapeStyle,
      FrontShapeStyleType: ShapeStyle,
      ContentViewType: View {
    
    @EnvironmentObject var timerVM: CountdownTimerViewModel
    
    private let lineWidth: CGFloat
    private let circleRotation: Angle
    private let animationDuration: Double
    
    private let backForegroundStyle: () -> BackShapeStyleType
    private let frontForegroundStyle: () -> FrontShapeStyleType
    
    @ViewBuilder private var contentView: ContentViewType
    
    public init(
        lineWidth: CGFloat = 20,
        circleRotation: Angle = .degrees(-90),
        animationDuration: Double = 0.2,
        backForegroundStyle: @escaping () -> BackShapeStyleType = { Color.gray.opacity(0.25) },
        frontForegroundStyle: @escaping () -> FrontShapeStyleType = { Color.green },
        @ViewBuilder contentView: () -> ContentViewType
    ) {
        self.lineWidth = lineWidth
        self.circleRotation = circleRotation
        self.animationDuration = animationDuration
         
        self.backForegroundStyle = backForegroundStyle
        self.frontForegroundStyle = frontForegroundStyle
        
        self.contentView = contentView()
    }
    
    public var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .foregroundStyle(backForegroundStyle())
            
            Circle()
                .trim(from: .zero, to: timerVM.progress)
                .stroke(style: StrokeStyle(lineWidth: lineWidth,
                                           lineCap: .round,
                                           lineJoin: .round))
                .foregroundStyle(frontForegroundStyle())
                .rotationEffect(circleRotation)
                .animation(.linear(duration: animationDuration), value: timerVM.progress)
            
            contentView
        }
    }
}

@available(iOS 15.0, *)
public struct TestCountdownTimerCircleProgressBarView: View {
    @StateObject var timerVM = CountdownTimerViewModel(47_000)
    
    public var body: some View {
        VStack {
            CountdownTimerCircleProgressBar(
                contentView: {
                    Text(TimerStringFormat.secMs.msStr(timerVM.counter))
                        .font(.headline)
                        .bold()
                        .foregroundStyle(Color.green)
                }
            )
            .environmentObject(timerVM)
            .padding()
            
            VStack(spacing: 16) {
                Button { timerVM.reset() } label: { Text("RESET") }
                Button { timerVM.start() } label: { Text("START") }
                Button { timerVM.stop() } label: { Text("STOP") }
            }
            .padding()
        }
    }
}

@available(iOS 15.0, *)
struct CountdownTimerCircleProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        TestCountdownTimerCircleProgressBarView()
    }
}

