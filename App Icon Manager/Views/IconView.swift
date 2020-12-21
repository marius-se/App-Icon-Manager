//
//  IconView.swift
//  App Icon Manager
//
//  Created by Marius Seufzer on 15.12.20.
//

import SwiftUI

struct IconView: View {
    @ObservedObject private(set) var viewModel: IconViewModel
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Image(nsImage: viewModel.image ?? .init())
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60, alignment: .center)
                Text(viewModel.title)
                    .multilineTextAlignment(.center)
                    // FIX-ME: dont hardcode this
                    .frame(height: 32)
                Spacer()
            }
            Spacer()
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct GridItemView_Previews: PreviewProvider {
    static var previews: some View {
        IconView(viewModel: IconViewModel(
                    imageURL: URL(string: "https://via.placeholder.com/150")!, title: "Test 123\n223")
        )
    }
}
