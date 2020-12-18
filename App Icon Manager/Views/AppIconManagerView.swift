//
//  AppIconManagerView.swift
//  App Icon Manager
//
//  Created by Marius Seufzer on 13.12.20.
//

import SwiftUI

struct AppIconManagerView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: AppIconManagerViewModel

    // MARK: - View
    var body: some View {
        NavigationView {
            switch viewModel.state {
            case .idle:
                List {
                    ForEach(viewModel.applications) { application in
                        NavigationLink(
                            destination: IconSelectionView(
                                viewModel: .init(
                                    forApplication: application
                                )
                            )
                        ) {
                            ListItemView(
                                image: .constant(
                                    NSWorkspace.shared.icon(forFile: application.path)
                                ),
                                title: application.name
                            )
                        }
                    }
                }
                .listStyle(SidebarListStyle())
                
                Text("Select an app...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loading:
                ProgressView()
            case .error(let message):
                // TODO: Error popup
                ProgressView("Error: \(message)")
            }
        }
        .onAppear {
            self.viewModel.loadApplications()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var data: [Application] {
        [
            Application(name: "1 Password", path: "/Applications/1Password 7.app"),
            Application(name: "Blender", path: "/Applications/Blender.app"),
            Application(name: "CLion", path: "/Applications/CLion.app"),
            Application(name: "Discord", path: "/Applications/Discord.app"),
        ]
    }
    
    static var previews: some View {
        AppIconManagerView(viewModel: AppIconManagerViewModel())
    }
}
