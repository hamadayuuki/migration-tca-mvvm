//
//  migration_tca_mvvmApp.swift
//  migration-tca-mvvm
//
//  Created by 濵田　悠樹 on 2024/12/13.
//

import SwiftUI
import ComposableArchitecture

@main
struct migration_tca_mvvmApp: App {
    var body: some Scene {
        WindowGroup {
            // TCA
            TCAItemListView(store: Store(initialState: ItemList.State()) {
                ItemList()
            })

            // MVVM
//            ItemListView()
        }
    }
}
