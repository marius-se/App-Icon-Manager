//
//  IconSelectionView.swift
//  App Icon Manager
//
//  Created by Marius Seufzer on 17.12.20.
//

import SwiftUI

struct IconSelectionView: View {
    
    @ObservedObject var viewModel: IconSelectionViewModel
    
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150, maximum: .infinity))
    ]
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .idle:
                ScrollView {
                    LazyVGrid(
                        columns: columns,
                        alignment: .leading,
                        spacing: nil,
                        pinnedViews: [],
                        content: {
                            ForEach(viewModel.icons) { icon in
                                IconView(
                                    image: .constant(NSImage()),
                                    title: icon.name
                                )
                            }
                        }
                    )
                }
            case .loading:
                ProgressView()
            case .error(let message):
                ProgressView(message)
            }
        }
        .onAppear(perform: viewModel.loadIcons)
    }
}

struct IconSelectionView_Previews: PreviewProvider {
    
    static let app = Application(name: "Blender", path: "/Applications/Blender")
    
    static var previews: some View {
        IconSelectionView(viewModel: IconSelectionViewModel(forApplication: app))
    }
}
