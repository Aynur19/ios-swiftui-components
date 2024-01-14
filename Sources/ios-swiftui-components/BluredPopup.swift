//
//  BluredPopup.swift
//
//
//  Created by Aynur Nasybullin on 14.01.2024.
//

import SwiftUI

@available(iOS 15.0, *)
public struct BluredPopup<ContentType>: View
where ContentType: View {
    @ViewBuilder private var contentView: ContentType
    
    private let cornerRadius: CGFloat
    private let material: Material
    
    public init(
        @ViewBuilder contentView: () -> ContentType,
        cornerRadius: CGFloat = 25,
        material: Material = .ultraThinMaterial
    ) {
        self.contentView = contentView()
        self.cornerRadius = cornerRadius
        self.material = material
    }
    
    public var body: some View {
        ZStack {
            Color.clear.background(material)
            
            contentView
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }
}

private let labelHello = "Hello, World!"

@available(iOS 15.0, *)
struct BluredPopup_Previews: PreviewProvider {
    static var previews: some View {
        BluredPopup(
            contentView: { Text(labelHello) },
            cornerRadius: 30,
            material: .thin
        )
        .padding(.horizontal, 48)
        .padding(.vertical, 128)
    }
}
