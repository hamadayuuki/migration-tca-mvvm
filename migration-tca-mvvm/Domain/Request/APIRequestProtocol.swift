import Foundation

/// APIリクエスト時のパラメータ
protocol APIRequestProtocol {
    associatedtype Response: Decodable

    var baseURL: URL { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var urlQueryItem: URLQueryItem { get }  // https://〜?hoge=1&hage=2 のクエリ
    var body: Data? { get }
}

// MARK: - extension

extension APIRequestProtocol {
    func buildURLRequest() -> URLRequest {
        let url = baseURL.appendingPathComponent(path)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue

        switch method {
        case .get:
            components?.queryItems = [urlQueryItem]
            urlRequest.url = components?.url
            return urlRequest
        case .post:
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")  // 動的にする必要がある場合は変更する
            urlRequest.httpBody = body
            return urlRequest
        }
    }
}
