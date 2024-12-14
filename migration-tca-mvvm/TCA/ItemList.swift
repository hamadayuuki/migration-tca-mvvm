//
//  ItemList.swift
//  migration-tca-mvvm
//
//  Created by 濵田　悠樹 on 2024/12/14.
//

import ComposableArchitecture
import Foundation

@Reducer
struct ItemList {
    enum LoadingState: Equatable {
        case idle
        case loading
        case loaded(SearchRepositoriesResponse)
        case error(String?)   // 今回はエラーハンドリング無し
    }

    @ObservableState
    struct State: Equatable {
        var loading: LoadingState = .idle
    }

    enum Action: Sendable {
        case onAppear
        case itemCellTapped(Int)
        case loaded(SearchRepositoriesResponse)
    }

    @Dependency(\.mainQueue) var mainQueue

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                state.loading = .loading
                // ① : API通信は副作用として .run を使い実行する
                // .run 内は非同期処理で実装しないといけない
                return .run { send in
                    try await self.mainQueue.sleep(for: .seconds(2.0))   // API通信を想定し2sのタイムラグを再現
                    let repositories: SearchRepositoriesResponse = .init(items: [.stub(), .stub(), .stub(), .stub(), .stub()])
                    await send(.loaded(repositories))
                }
            // ② : state の更新は .run 内では行えない設計になっている → API通信 と 状態の更新 を分けて実装できる
            case .loaded(let repositories):
                state.loading = .loaded(repositories)
                return .none
            case .itemCellTapped(let index):
                switch state.loading {
                case .loaded(let repositories):
                    let repository = repositories.items[index]
                    print(repository)
                    return .none
                case .idle, .loading, .error:
                    return .none
                }
            }
        }
    }
}
