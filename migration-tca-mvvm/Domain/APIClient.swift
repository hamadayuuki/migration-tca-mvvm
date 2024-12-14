import Foundation

protocol APIClientProtocol {
    func request<D: Decodable>(apiRequest: any APIRequestProtocol) async throws -> Result<D, HTTPError>
}

class APIClient: APIClientProtocol {
    /// APIから取得したJSONを変換するためのDecoder
    ///
    /// `total_count -> totalCount`
    private var decoder: JSONDecoder {
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase  // total_count -> totalCount
        return jsonDecoder
    }

    /// URLSessionを用いたHTTPリクエスト
    ///
    /// ```
    /// Task {
    ///    let apiRequest = ~~~
    ///    let apiClient = APIClient()
    ///    let response: Result<SearchRepositoryResponse, HTTPError> = try await apiClient.request(apiRequest: apiRequest)
    /// }
    /// ```
    func request<D: Decodable>(apiRequest: any APIRequestProtocol) async throws -> Result<D, HTTPError> {
        let request = apiRequest.buildURLRequest()
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpStatus = response as? HTTPURLResponse else {
            return .failure(.responseError)
        }

        switch httpStatus.statusCode {
        case 200..<300:
            do {
                let decodedData = try decoder.decode(D.self, from: data)
                return .success(decodedData)
            } catch {
                return .failure(.decodeError)
            }
        case 400..<600:
            let error = errorHandling(statusCode: httpStatus.statusCode)
            return .failure(error)
        default:
            return .failure(.unknownError)
        }
    }
}

// MARK: - extension

extension APIClient {
    /// 400, 500番台のエラーハンドリング
    func errorHandling(statusCode: Int) -> HTTPError {
        switch statusCode {
        // 4xx クライアントエラー
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 405:
            return .methodNotAllowed
        case 408:
            return .requestTimeout
        case 409:
            return .conflict
        case 429:
            return .tooManyRequests
        case 400...499:
            return .clientError(statusCode)
        // 5xx サーバーエラー
        case 500:
            return .internalServerError
        case 501:
            return .notImplemented
        case 502:
            return .badGateway
        case 503:
            return .serviceUnavailable
        case 504:
            return .gatewayTimeout
        case 500...599:
            return .serverError(statusCode)
        default:
            return .unknownError
        }
    }
}
