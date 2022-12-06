//
//  AppIconManagerApp.swift
//  AppIconManager
//
//  Created by Marius Seufzer on 22.08.22.
//

import SwiftUI
import ComposableArchitecture

@main
struct AppIconManagerApp: SwiftUI.App {
    let store: Store<AppState, AppAction>

    init() {
        store = Store(
            initialState: AppState(),
            reducer: appReducer,
            environment: .live(environment: AppEnvironment(appsClient: .live(urlSession: .shared), iconsClient: .dev))
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
