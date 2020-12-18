//
//  ListItemView.swift
//  App Icon Manager
//
//  Created by Marius Seufzer on 13.12.20.
//

import SwiftUI

struct ListItemView: View {
    @Binding var image: NSImage
    let title: String
    
    var body: some View {
        HStack(alignment: .center) {
            Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40, height: 40, alignment: .center)
            Text(title)
                .lineLimit(2)
            Spacer()
        }
        .padding()
    }
}

struct AppIconView_Previews: PreviewProvider {
    static var previews: some View {
        ListItemView(
            image: .constant(NSImage(systemSymbolName: "phone", accessibilityDescription: nil)!),
            title: "Blender"
        )
    }
}
