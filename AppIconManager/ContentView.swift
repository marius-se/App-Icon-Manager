//
//  ContentView.swift
//  AppIconManager
//
//  Created by Marius Seufzer on 22.08.22.
//

import SwiftUI
import ComposableArchitecture
import SDWebImageSwiftUI

struct AppState: Equatable {
    var selectedApp: App?
    var apps: IdentifiedArrayOf<App> = []
    var icons: [Icon] = []

    var isLoadingIcons: Bool = false
}

enum AppAction: Equatable {
    case loadInstalledApps
    case appsResponse(Result<[App], AppsClient.Failure>)
    case selectApp(App)
    case iconsResponse(Result<[Icon], IconsClient.Failure>)
    case setIcon(App, Icon)
    case setIconResponse(Result<NSImage, AppsClient.Failure>)
    case resetIcon(App)
}

struct AppEnvironment {
    var appsClient: AppsClient
    var iconsClient: IconsClient

    init(appsClient: AppsClient, iconsClient: IconsClient) {
        self.appsClient = appsClient
        self.iconsClient = iconsClient
    }
}

let appReducer = Reducer<
    AppState,
    AppAction,
    SystemEnvironment<AppEnvironment>
> { state, action, environment in
    switch action {
    case let .selectApp(app):
        state.selectedApp = app
        if state.selectedApp != app {
            state.icons = []
        }
        state.isLoadingIcons = true
        return environment.iconsClient.getIcons(app)
            .receive(on: environment.mainQueue)
            .catchToEffect(AppAction.iconsResponse)
    case .loadInstalledApps:
        return environment.appsClient.getAllApps()
            .receive(on: environment.mainQueue)
            .catchToEffect(AppAction.appsResponse)
    case let .appsResponse(.success(apps)):
        state.apps = .init(uniqueElements: apps)
        if state.selectedApp == nil, let firstApp = apps.first {
            return Effect(value: .selectApp(firstApp))
        } else {
            return .none
        }
    case let .appsResponse(.failure(error)):
        print(error)
        return .none
    case let .iconsResponse(.success(icons)):
        state.icons = icons
        state.isLoadingIcons = false
        return .none
    case let .iconsResponse(.failure(error)):
        print(error)
        state.isLoadingIcons = false
        return .none
    case let .setIcon(app, icon):
        return .concatenate(
            environment.appsClient.setIcon(app, icon)
                .receive(on: environment.mainQueue)
                .catchToEffect(AppAction.setIconResponse),
            Effect(value: AppAction.loadInstalledApps).deferred(for: 0.5, scheduler: environment.mainQueue)
        )
    case let .setIconResponse(.success(image)):
        state.selectedApp?.icon = image
        return .none
    case let .setIconResponse(.failure(error)):
        print(error)
        return .none
    case let .resetIcon(app):
        return environment.appsClient.resetIcon(app)
            .receive(on: environment.mainQueue)
            .fireAndForget()
    }
}

struct ContentView: View {
    let store: Store<AppState, AppAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                ScrollView {
                    VStack {
                        ForEach(viewStore.apps) { app in
                            Button(
                                action: {
                                    viewStore.send(.selectApp(app))
                                },
                                label: {
                                    HStack {
                                        Image(nsImage: app.icon)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 50)
                                        Text(app.name)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                    .padding(10)
                                    .background(viewStore.selectedApp == app ? Color.accentColor : Color.clear)
                                    .contentShape(Rectangle())
                                }
                            )
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                if let selectedApp = viewStore.selectedApp {
                    Button("Reset", action: { viewStore.send(.resetIcon(selectedApp)) })
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))]) {
                        ForEach(viewStore.icons) { icon in
                            Button(
                                action: { viewStore.send(.setIcon(selectedApp, icon)) },
                                label: {
                                    HStack {
                                        WebImage(url: icon.fileURL)
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(height: 100)

                                        VStack(alignment: .leading) {
                                            Text(icon.name)
                                            Text(icon.author + " on " + DateFormatter().string(from: icon.lastModified))
                                                .multilineTextAlignment(.leading)
                                                .lineLimit(2)
                                        }
                                    }
                                    .frame(width: 250)
                                }
                            )
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                } else {
                    Text("Select an app to get started.")
                }
            }
            .onAppear {
                viewStore.send(.loadInstalledApps)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            store: Store(
                initialState: .init(apps: []),
                reducer: appReducer,
                environment: .dev(environment: AppEnvironment(appsClient: .dev, iconsClient: .dev))
            )
        )
    }
}
