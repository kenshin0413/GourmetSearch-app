//
//  HotPepperResponse.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/19.
//

import Foundation

// https://app.quicktype.io
// 上記のサイトを使用してAPIから返ってきたJSONに合う構造体を作成

/// HotPepper API のレスポンス全体モデル
struct HotPepperResponse: Codable {
    let results: Results
}

/// APIレスポンスの中身
struct Results: Codable {
    let resultsAvailable: Int
    let resultsReturned: String
    let resultsStart: Int
    let shop: [Shop]
    
    enum CodingKeys: String, CodingKey {
        case resultsAvailable = "results_available"
        case resultsReturned  = "results_returned"
        case resultsStart     = "results_start"
        case shop
    }
}

// MARK: - Shop

/// 店舗モデル
struct Shop: Codable, Identifiable {
    
    // MARK: - 基本情報
    
    let id: String
    let name: String
    let address: String
    let stationName: String
    
    // MARK: - 位置情報
    
    let lat: Double
    let lng: Double
    
    // MARK: - 表示情報
    
    let access: String
    let shopOpen: String
    let shopCatch: String
    
    // MARK: - カテゴリ・予算
    
    let genre: Genre
    let budget: Budget
    
    // MARK: - メディア・リンク
    
    let photo: Photo
    let urls: Urls
    
    // MARK: - 設備情報
    
    let card: String
    let parking: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, address
        case stationName = "station_name"
        case lat, lng
        case access
        case shopOpen = "open"
        case shopCatch = "catch"
        case genre, budget
        case photo, urls
        case card, parking
    }
}

// MARK: - Budget

struct Budget: Codable {
    let name: String
    let average: String
}

// MARK: - Genre

struct Genre: Codable {
    let name: String
}

// MARK: - Photo

struct Photo: Codable {
    let pc: PC
    let mobile: Mobile
}

struct PC: Codable {
    let l: String
}

struct Mobile: Codable {
    let l: String
}

// MARK: - Urls

struct Urls: Codable {
    let pc: String
}
