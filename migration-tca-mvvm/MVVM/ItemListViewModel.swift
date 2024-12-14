//
//  ItemListViewModel.swift
//  migration-tca-mvvm
//
//  Created by 濵田　悠樹 on 2024/12/13.
//

import Observation
import Foundation

@Observable
final class ItemListViewModel {
    // TCAと共通
    enum LoadingState: Equatable {
        case idle
        case loading
        case loaded(SearchRepositoriesResponse)
        case error(String?)   // 今回はエラーハンドリング無し
    }

    // TCAのState
    var loading: LoadingState = .idle

    // TCAのAction
    func onAppear() {
        // ! スレッド管理を自分でする必要がある
        Task.detached {
            sleep(2)
            // TCAのReducer(内の処理)
            let repositories: SearchRepositoriesResponse = .init(items: [.stub(), .stub(), .stub(), .stub(), .stub()])
            self.loading = .loaded(repositories)   // TCAでは Action.loaded(SearchRepositoriesResponse) にて状態更新していたがMVVMでは不要
        }
    }

    func itemCellTapped(index: Int) {
        switch loading {
        case .loaded(let repositories):
            let repository = repositories.items[index]
            print(repository)
        case .idle, .loading, .error:
            let _ = ""   // 空実装
        }
    }
}
