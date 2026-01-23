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
    let shop: [Shop]
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

// MARK: - CoreData変換

extension Shop {
    
    /// Entity → Shop
    init?(entity: FavoriteShopEntity) {
        guard
            let id = entity.id,
            let name = entity.name,
            let address = entity.address
        else { return nil }
        
        self.id = id
        self.name = name
        self.address = address
        self.stationName = entity.stationName ?? ""
        
        self.lat = entity.lat
        self.lng = entity.lng
        
        self.access = entity.access ?? ""
        self.shopOpen = entity.shopOpen ?? ""
        self.shopCatch = entity.shopCatch ?? ""
        
        self.genre = Genre(name: entity.genreName ?? "")
        self.budget = Budget(average: entity.budgetAverage ?? "")
        
        let pc = PC(l: entity.photoPCURL ?? "")
        let mobile = Mobile(l: entity.photoMobileURL ?? "")
        self.photo = Photo(pc: pc, mobile: mobile)
        
        self.urls = Urls(pc: entity.websiteURL ?? "")
        
        self.card = entity.card ?? ""
        self.parking = entity.parking ?? ""
    }
    
    /// Shop → Entity
    func apply(to entity: FavoriteShopEntity) {
        entity.id = self.id
        entity.name = self.name
        entity.address = self.address
        entity.stationName = self.stationName
        
        entity.lat = self.lat
        entity.lng = self.lng
        
        entity.access = self.access
        entity.shopOpen = self.shopOpen
        entity.shopCatch = self.shopCatch
        
        entity.genreName = self.genre.name
        entity.budgetAverage = self.budget.average
        
        entity.photoMobileURL = self.photo.mobile.l
        entity.photoPCURL = self.photo.pc.l
        
        entity.websiteURL = self.urls.pc
        
        entity.card = self.card
        entity.parking = self.parking
    }
}

// MARK: - Budget

struct Budget: Codable {
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
