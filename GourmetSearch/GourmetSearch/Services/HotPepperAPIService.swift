//
//  HotPepperAPIService.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/19.
//

import Foundation

final class HotPepperAPIService {
    
    // MARK: - API設定
    
    /// Info.plist から APIキーを取得
    private var apiKey: String {
        Bundle.main.object(
            forInfoDictionaryKey: "HOTPEPPER_API_KEY"
        ) as? String ?? ""
    }
    
    /// APIベースURL
    private let baseUrl = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/"
    
    // MARK: - 店舗検索API
    
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
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let result = try JSONDecoder().decode(HotPepperResponse.self, from: data)
        
        return result
    }
}
