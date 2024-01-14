//
//  HStaticSegmentedPickerView.swift
//
//
//  Created by Aynur Nasybullin on 14.01.2024.
//

import SwiftUI

public struct HStaticSegmentedPickerView<DataType, ContentViewType>: View
where DataType: Hashable,
      ContentViewType: View {
    
    let data: [DataType]
    @Binding var selectedItem: DataType
    
    @ViewBuilder private var contentView: (DataType) -> ContentViewType
    
    public init(
        data: [DataType],
        value: Binding<DataType>,
        backgroundColor: UIColor = .gray.withAlphaComponent(0.25),
        selectedSegmentTintColor: UIColor = .gray.withAlphaComponent(0.75),
        selectedForecroundColor: UIColor = .white,
        normalForegroundColor: UIColor = .white.withAlphaComponent(0.75),
        textStyle: UIFont.TextStyle = .headline,
        @ViewBuilder contentView: @escaping (DataType) -> ContentViewType
    ) {
        self.data = data
        _selectedItem = value
        
        self.contentView = contentView
        
        UISegmentedControl.appearance().backgroundColor = backgroundColor
        
        UISegmentedControl.appearance().setDividerImage(
            .init(),
            forLeftSegmentState: .normal,
            rightSegmentState: .normal,
            barMetrics: .compact
        )
        
        UISegmentedControl.appearance().selectedSegmentTintColor = selectedSegmentTintColor
        
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: selectedForecroundColor,
            .font: UIFont.preferredFont(forTextStyle: textStyle)
        ], for: .selected)
        
        UISegmentedControl.appearance().setTitleTextAttributes([
            .foregroundColor: normalForegroundColor,
            .font: UIFont.preferredFont(forTextStyle: textStyle)
        ], for: .normal)
        
    }
    
    public var body: some View {
        ZStack {
            Picker("", selection: $selectedItem) {
                ForEach(data, id: \.self) { item in
                    contentView(item)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

@available(iOS 14.0, *)
private struct TestHStaticSegmentedPickerView: View {
    let data = [5, 10, 13, 15, 17, 30]
    @State private var selectedItem = 5
    
    var body: some View {
        VStack {
            Picker("Options", selection: $selectedItem) {
                ForEach(data, id: \.self) { item in
                    Text("\(item)")
                }
            }
            .pickerStyle(.segmented)
            
            HStaticSegmentedPickerView(
                data: data,
                value: $selectedItem,
                contentView: { item in
                    Text("\(item)")
                }
            )
            
            HStaticSegmentedPickerView(
                data: data,
                value: $selectedItem,
                backgroundColor: UIColor(Color.orange.opacity(0.25)),
                selectedSegmentTintColor: UIColor(Color.orange),
                selectedForecroundColor: UIColor(Color.black),
                normalForegroundColor: UIColor(Color.black.opacity(0.5))
            ) { item in
                Text("\(item)")
            }
        }
    }
}

@available(iOS 15.0, *)
struct HStaticSegmentedPickerView_Previews: PreviewProvider {
    static var previews: some View {
        TestHStaticSegmentedPickerView()
    }
}
