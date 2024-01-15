//
//  TabItemView.swift
//
//
//  Created by Aynur Nasybullin on 15.01.2024.
//

import SwiftUI

@available(iOS 16.0, *)
public struct TabItemView<ContentType, LabelType, BackgroundType>: View
where ContentType: View,
      LabelType: View,
      BackgroundType: ShapeStyle {

    @ViewBuilder private var contentView: ContentType
    @ViewBuilder private var labelView: LabelType
    @ViewBuilder private var backgroundStyle: BackgroundType
    private let backgroundVisibility: Visibility
    
    public init(
        @ViewBuilder contentView: () -> ContentType,
        @ViewBuilder labelView: () -> LabelType,
        @ViewBuilder backgroundStyle: () -> BackgroundType,
        backgroundVisibility: Visibility = .automatic
    ) {
        self.contentView = contentView()
        self.labelView = labelView()
        self.backgroundStyle = backgroundStyle()
        self.backgroundVisibility = backgroundVisibility
    }
    
    public var body: some View {
        contentView
            .tabItem { labelView }
            .toolbarBackground(backgroundVisibility, for: .tabBar)
            .toolbarBackground(backgroundStyle, for: .tabBar)
    }
}

@available(iOS 16.0, *)
private struct TestTabItemView: View {
    var body: some View {
        TabView {
            TabItemView(
                contentView: {
                    ZStack {
                        Color.indigo.opacity(0.5)
                            .ignoresSafeArea()
                    }
                },
                labelView: {
                    VStack {
                        Image(systemName: "heart")
                        Text("Heart")
                    }
                },
                backgroundStyle: { Color.orange },
                backgroundVisibility: .visible
            )
        }
    }
}

@available(iOS 16.0, *)
struct TabItemView_Previews: PreviewProvider {
    static var previews: some View {
        TestTabItemView()
    }
}
