//
//  SystemEnvironment.swift
//  AppIconManager
//
//  Created by Marius Seufzer on 22.08.22.
//

import Foundation
import ComposableArchitecture

@dynamicMemberLookup
public struct SystemEnvironment<Environment> {
    public var environment: Environment
    public var mainQueue: AnySchedulerOf<DispatchQueue>
    public var uuid: () -> UUID

    public init(
        environment: Environment,
        mainQueue: AnySchedulerOf<DispatchQueue>,
        uuid: @escaping () -> UUID
    ) {
        self.environment = environment
        self.mainQueue = mainQueue
        self.uuid = uuid
    }

    public subscript<Dependency>(
        dynamicMember keyPath: WritableKeyPath<Environment, Dependency>
    ) -> Dependency {
        get { self.environment[keyPath: keyPath] }
        set { self.environment[keyPath: keyPath] = newValue }
    }

    /// Creates a live system environment with the wrapped environment provided.
    ///
    /// - Parameter environment: An environment to be wrapped in the system environment.
    /// - Returns: A new system environment.
    public static func live(
        environment: Environment
    ) -> Self {
        Self(
            environment: environment,
            mainQueue: .main,
            uuid: UUID.init
        )
    }

    public static func dev(environment: Environment) -> Self {
        Self(
            environment: environment,
            mainQueue: .main,
            uuid: UUID.init
        )
    }

    /// Transforms the underlying wrapped environment.
    public func map<NewEnvironment>(
        _ transform: @escaping (Environment) -> NewEnvironment
    ) -> SystemEnvironment<NewEnvironment> {
        .init(
            environment: transform(self.environment),
            mainQueue: self.mainQueue,
            uuid: self.uuid
        )
    }
}

