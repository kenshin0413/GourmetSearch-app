//
//  HotPepperAPIService.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/19.
//

import Foundation

final class HotPepperAPIService {
    
    private let apiKey = "55e90cb3b25ef11a"
    private let baseUrl = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/"
    
    /// 店舗検索APIを呼び出す
    func fetchShops(
        latitude: Double,
        longitude: Double,
        range: Int,
        keyword: String?,
        startIndex: Int,
        fetchCount: Int
    ) async throws -> HotPepperResponse {
        
        var components = URLComponents(string: baseUrl)!
        components.queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "lat", value: String(latitude)),
            URLQueryItem(name: "lng", value: String(longitude)),
            URLQueryItem(name: "range", value: String(range)),
            URLQueryItem(name: "start", value: String(startIndex)),
            URLQueryItem(name: "count", value: String(fetchCount))
        ]
        
        if let keyword, !keyword.isEmpty {
            components.queryItems?.append(
                URLQueryItem(name: "keyword", value: keyword)
            )
        }
        
        guard let url = components.url else {
            throw URLError(.badURL)
        }
        
        // リクエストURLをログ出力
        print("📡 Request URL:", url.absoluteString)
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // レスポンスJSONをログ出力
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📦 Response JSON:", jsonString)
        }
        
        let result = try JSONDecoder().decode(HotPepperResponse.self, from: data)
        print("\(result.results.shop.count)############################")
        return result
    }
}
