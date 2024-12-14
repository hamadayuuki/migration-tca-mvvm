//
//  ItemListView.swift
//  migration-tca-mvvm
//
//  Created by 濵田　悠樹 on 2024/12/13.
//

import SwiftUI

struct ItemListView: View {
    @State var vm: ItemListViewModel = .init()   // TCAと異なる

    var body: some View {
        switch vm.loading {
        case .idle:
            Text("Init ItemListView...")
                .onAppear {
                    vm.onAppear()
                }
        case .loading:
            VStack(spacing: 24) {
                Text("Loading...")
                ProgressView()
            }
        case .loaded(let repositories):
            List {
                ForEach(0..<repositories.items.count, id: \.self) { i in
                    ItemCell(reposiotry: repositories.items[i])
                        .onTapGesture {
                            vm.itemCellTapped(index: i)
                        }
                }
            }
        case .error(_):
            Text("Error!")
        }
    }

    /// GitHubのリポジトリセル
    private func ItemCell(reposiotry: GithubRepository) -> some View {
        HStack {
            Image("github-icon")
                .resizable()
                .frame(width: 60.0, height: 60.0, alignment: .center)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 12) {
                Text(reposiotry.fullName)

                Text(reposiotry.description)
            }
        }
    }

}

#Preview {
    ItemListView()
}