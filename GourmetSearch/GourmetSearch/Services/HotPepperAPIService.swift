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
        
        // APIキー未設定は明示エラーにする
        guard !apiKey.isEmpty else { throw HotPepperAPIError.invalidAPIKey }
        
        var components = URLComponents(string: baseUrl)!
        let baseItems: [(String, String)?] = [
            ("key", apiKey),
            ("format", "json"),
            ("lat", String(latitude)),
            ("lng", String(longitude)),
            ("range", String(range)),
            ("start", String(startIndex)),
            ("count", String(fetchCount)),
            (keyword?.isEmpty == false ? ("keyword", keyword!) : nil)
        ]
        components.queryItems = baseItems
            .compactMap { $0 }
            .map { URLQueryItem(name: $0.0, value: $0.1) }
        
        guard let url = components.url else {
            throw HotPepperAPIError.badURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
            throw HotPepperAPIError.httpStatus(http.statusCode)
        }
        
        do {
            return try JSONDecoder().decode(HotPepperResponse.self, from: data)
        } catch {
            throw HotPepperAPIError.decoding
        }
    }
}
