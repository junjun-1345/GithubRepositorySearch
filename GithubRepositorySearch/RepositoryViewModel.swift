//
//  RepositoryViewModel.swift
//  GithubRepositorySearch
//
//  Created by 大野純平 on 2024/05/17.
//

import Foundation
import Combine

class RepositoryViewModel: ObservableObject {
    //@Published属性は、ObservableObjectプロトコルに準拠したクラス内で使用されます。プロパティの値が変更されるたびに変更が通知され、監視しているビューが自動的に再描画されます。ref.watch的な?
    @Published var query: String = ""
    @Published var repositories: [Repository] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    private var cancellable = Set<AnyCancellable>()
    private let gitHubService = GitHubService()
    
    init() {
//         queryプロパティのPublisherです。これにより、queryの変更を監視します。
        $query
//             入力のデバウンスを行い、最後の入力から500ミリ秒経過後に処理を実行します。これにより、過剰なリクエストを防ぎます。
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
//             連続する同じ値の重複を除去します。同じクエリが連続して入力された場合に無駄な検索を防ぎます。
            .removeDuplicates()
//            flatMapは、queryプロパティの新しい値を受け取り、それに基づいて新しいPublisher（ここではsearchRepositories(query:)メソッドが返すPublisher）を作成します。
            .flatMap { query in
                self.searchRepositories(query: query)
            }
//             最後にsinkオペレーターを使って、flatMapによって返されたPublisherの出力を受け取り処理します。
            .sink { completion in
                if case .failure(let error) = completion {
                    self.error = error
                    self.repositories = []
                }
            } receiveValue: { repositories in
                self.repositories = repositories
            }
//             購読を保存する
            .store(in: &cancellable)
    }
    
    private func searchRepositories(query: String) -> AnyPublisher<[Repository], Never> {
//        空のリポジトリリストを即座に発行するPublisherです。
        guard !query.isEmpty else {
            return Just([]).eraseToAnyPublisher()
        }
        
        isLoading = true
        
        return gitHubService.searchRepositories(query: query)
//        エラーハンドリングのためのオペレーターです。エラーが発生した場合に、空のリポジトリリストを返します。
            .catch { _ in Just([]) }
            .handleEvents(receiveCompletion: { _ in
                self.isLoading = false
            })
            .eraseToAnyPublisher()
    }
}

