//
//  IconView.swift
//  App Icon Manager
//
//  Created by Marius Seufzer on 15.12.20.
//

import SwiftUI

struct IconView: View {
    @Binding var image: NSImage
    let title: String
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Image(nsImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60, alignment: .center)
                Text(title)
                Spacer()
            }
            Spacer()
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct GridItemView_Previews: PreviewProvider {
    static var previews: some View {
        IconView(
            image: .constant(NSImage(systemSymbolName: "phone", accessibilityDescription: nil)!),
            title: "Icon Alt 1"
        )
    }
}
