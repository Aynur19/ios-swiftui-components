//
//  HWheelPickerView.swift
//
//
//  Created by Aynur Nasybullin on 15.01.2024.
//

import SwiftUI
import Combine

struct ScrollViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}

@available(iOS 15.0, *)
public struct HWheelPickerView<DataType, ContentViewType, DividerViewType, BackgroundViewType, MaskViewType>: View
where DataType: Hashable,
      ContentViewType: View,
      DividerViewType: View,
      BackgroundViewType: View,
      MaskViewType: View {
    
    private let preferenceName = "scrollOffset"
    
    private let data: [DataType]
    @Binding var selectedItemIdx: Int
    
    private let contentSize: CGSize
    private let dividerSize: CGSize
    
    @ViewBuilder private var contentView: (DataType) -> ContentViewType
    @ViewBuilder private var dividerView: () -> DividerViewType
    
    @ViewBuilder private var backgroundView: () -> BackgroundViewType
    @ViewBuilder private var maskView: () -> MaskViewType
    
    @State private var xOffset: CurrentValueSubject<CGFloat, Never>
    @State private var publisher: AnyPublisher<CGFloat, Never>
    
    private let itemWidth: CGFloat
    
    public init(
        data: [DataType],
        valueIdx: Binding<Int>,
        contentSize: CGSize = .init(width: 64, height: 32),
        dividerSize: CGSize = .init(width: 1.5, height: 16),
        @ViewBuilder contentView: @escaping (DataType) -> ContentViewType,
        @ViewBuilder dividerView: @escaping () -> DividerViewType = {
            Rectangle()
                .fill(Color(.systemGray3))
        },
        @ViewBuilder backgroundView: @escaping () -> BackgroundViewType = {
            Color.clear
        },
        @ViewBuilder maskView: @escaping () -> MaskViewType = {
            LinearGradient(colors: [.clear, .black, .clear],
                           startPoint: .leading,
                           endPoint: .trailing)
        }
    ) {
        self.data = data
        _selectedItemIdx = valueIdx
        
        self.contentSize = contentSize
        self.dividerSize = dividerSize
        self.itemWidth = contentSize.width + dividerSize.width
        
        self.contentView = contentView
        self.dividerView = dividerView
        
        self.backgroundView = backgroundView
        self.maskView = maskView
        
        let xOffset = CurrentValueSubject<CGFloat, Never>(0)
        self.publisher = xOffset
            .debounce(for: .seconds(0.2), scheduler: DispatchQueue.main)
            .dropFirst()
            .eraseToAnyPublisher()
        self.xOffset = xOffset
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollProxy in
                hScrollView(geometry, scrollProxy)
                    .coordinateSpace(name: preferenceName)
                    .onAppear {
                        DispatchQueue.main.async {
                            scrollProxy.scrollTo(selectedItemIdx, anchor: .center)
                        }
                    }
                    .onReceive(publisher) { offset in
                        scrollTo(offset, scrollProxy)
                    }
                    .background { backgroundView() }
                    .mask { maskView() }
            }
        }
    }
    
    private var scrollItems: some View {
        ForEach(data.indices, id: \.self) { itemIdx in
            HStack(spacing: .zero) {
                dividerView()
                    .frame(width: dividerSize.width,
                           height: dividerSize.height)
                
                contentView(data[itemIdx])
                    .frame(width: contentSize.width,
                           height: contentSize.height)
                
                if itemIdx == data.count - 1 {
                    dividerView()
                        .frame(width: dividerSize.width,
                               height: dividerSize.height)
                }
            }
        }
    }
    
    private func scrollTo(_ offset: CGFloat, _ scrollProxy: ScrollViewProxy) {
        var idx = Int((offset / itemWidth).rounded(.down))
        
        if idx >= data.count {
            idx = data.count - 1
        }
        selectedItemIdx = idx
        
        scrollTo(idx: idx, scrollProxy: scrollProxy)
    }
    
    private func scrollTo(idx: Int, scrollProxy: ScrollViewProxy) {
        withAnimation {
            scrollProxy.scrollTo(idx, anchor: .center)
        }
    }
    
    @ViewBuilder
    private func hScrollView(_ geometry: GeometryProxy, _ scrollProxy: ScrollViewProxy) -> some View {
        if #available(iOS 17.0, *) {
            hScrollView_ios17(geometry, scrollProxy)
        } else {
            hScrollView_default(geometry, scrollProxy)
        }
    }
    
    @available(iOS 17.0, *)
    private func hScrollView_ios17(_ geometry: GeometryProxy, _ scrollProxy: ScrollViewProxy) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .zero) {
                Spacer(minLength: geometry.size.width / 2)
                scrollItems
                Spacer(minLength: geometry.size.width / 2)
            }
            .background {
                GeometryReader {
                    Color.clear.preference(
                        key: ScrollViewOffsetKey.self,
                        value: -$0.frame(in: .named(preferenceName)).origin.x
                    )
                }
            }
        }
        .onPreferenceChange(ScrollViewOffsetKey.self) {
            xOffset.send($0)
        }
        .onChange(of: selectedItemIdx) { oldValue, newValue in
            if oldValue != newValue {
                scrollTo(idx: newValue, scrollProxy: scrollProxy)
            }
        }
    }
    
    private func hScrollView_default(_ geometry: GeometryProxy, _ scrollProxy: ScrollViewProxy) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: .zero) {
                Spacer(minLength: geometry.size.width / 2)
                scrollItems
                Spacer(minLength: geometry.size.width / 2)
            }
            .background {
                GeometryReader {
                    Color.clear.preference(
                        key: ScrollViewOffsetKey.self,
                        value: -$0.frame(in: .named(preferenceName)).origin.x
                    )
                }
            }
        }
        .onPreferenceChange(ScrollViewOffsetKey.self) {
            xOffset.send($0)
        }
        .onChange(of: selectedItemIdx) { newValue in
            scrollTo(idx: newValue, scrollProxy: scrollProxy)
        }
    }
}

@available(iOS 15.0, *)
private struct TestHWheelPickerView: View {
    let data = [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60]
    
    @State private var selectedItemIdx1 = 5
    @State private var selectedItemIdx2 = 0
    
    var body: some View {
        VStack {
            Spacer()
                .frame(maxHeight: .infinity)
            
            VStack {
                Text("\(data[selectedItemIdx1])")
            
                HWheelPickerView(
                    data: data,
                    valueIdx: $selectedItemIdx1,
                    contentView: { item in
                        Text("\(item)")
                    }
                )
            }
            
            VStack {
                Text("\(data[selectedItemIdx1])")
                
                HWheelPickerView(
                    data: data,
                    valueIdx: $selectedItemIdx1,
                    contentSize: .init(width: 100, height: 50),
                    dividerSize: .init(width: 1.5, height: 34),
                    contentView: { item in
                        Text("\(item)")
                            .font(.title2)
                            .foregroundStyle(Color.orange)
                    },
                    dividerView: {
                        Color.orange
                    },
                    backgroundView: {
                        LinearGradient(
                            colors: [.clear, Color.orange.opacity(0.25), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    },
                    maskView: {
                        LinearGradient(
                            colors: [.clear, Color.black, .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                )
            }
            Spacer()
                .frame(maxHeight: .infinity)
        }
    }
}

@available(iOS 15.0, *)
struct HWheelPickerView_Previews: PreviewProvider {
    static var previews: some View {
        TestHWheelPickerView()
    }
}
