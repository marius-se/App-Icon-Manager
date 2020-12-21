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
            Spacer()
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
                                    viewModel: IconViewModel(
                                        imageURL: URL(string: icon.path)!,
                                        title: icon.name
                                    )
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
            Spacer()
            HStack {
                Button("Reset icon", action: viewModel.resetIcon)
                Spacer()
            }
            .padding()
        }
        .onAppear(perform: viewModel.loadIcons)
    }
}

struct IconSelectionView_Previews: PreviewProvider {
    
    static let app = Application(name: "Blender", path: "/Applications/Blender")
    
    static var previews: some View {
        IconSelectionView(viewModel: IconSelectionViewModel(forApplication: app, onIconReset: nil))
    }
}
