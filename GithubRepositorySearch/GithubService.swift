//
//  GithubService.swift
//  GithubRepositorySearch
//
//  Created by 大野純平 on 2024/05/17.
//

import Foundation
import Combine

struct Repository: Decodable, Identifiable {
    let id: Int
    let name: String
    let html_url: String
    let description: String?
}

class GitHubService {
    private let baseURL = "https://api.github.com"
    
    func searchRepositories(query: String) -> AnyPublisher<[Repository], Error> {
        guard let url = URL(string: "\(baseURL)/search/repositories?q=\(query)") else {
//            Fail Publisherを返してエラーを発行します。
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: SearchResponse.self, decoder: JSONDecoder())
            .map { $0.items }
//          取得したデータをメインスレッドで受け取ります。UIの更新が必要な場合、このステップでメインスレッドに移行します。
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    struct SearchResponse: Decodable {
        let items: [Repository]
    }
}
