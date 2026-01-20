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

/// APIレスポンスの中身（検索結果情報）
struct Results: Codable {
    let apiVersion: String
    let resultsAvailable: Int
    let resultsReturned: String
    let resultsStart: Int
    let shop: [Shop]
    
    // APIのキー名とSwiftのプロパティ名が異なるためマッピング定義
    enum CodingKeys: String, CodingKey {
        case apiVersion = "api_version"
        case resultsAvailable = "results_available"
        case resultsReturned = "results_returned"
        case resultsStart = "results_start"
        case shop
    }
}

/// 1店舗分の情報モデル
struct Shop: Codable {
    let id, name: String
    let logoImage: String
    let nameKana, address, stationName: String
    let ktaiCoupon: Int
    let largeServiceArea, serviceArea, largeArea, middleArea: Area
    let smallArea: Area
    let lat, lng: Double
    let genre: Genre
    let budget: Budget
    let shopCatch: String
    let capacity: Int
    let access, mobileAccess: String
    let urls: Urls
    let photo: Photo
    let shopOpen, close: String
    let partyCapacity: PartyCapacity
    let otherMemo: String
    let shopDetailMemo: String
    let budgetMemo: String
    let wedding: String
    let freeDrink: String
    let freeFood: String
    let privateRoom: String
    let horigotatsu, tatami: String
    let card: String
    let nonSmoking: String
    let charter: String
    let parking: String
    let barrierFree: String
    let show, karaoke: String
    let band: String
    let tv, lunch: String
    let midnight: String
    let english: String
    let pet: String
    let child: String
    let wifi: String
    let couponUrls: CouponUrls
    let course: String?
    
    // APIのキー名とSwiftのプロパティ名が異なるためマッピング定義
    enum CodingKeys: String, CodingKey {
        case id, name
        case logoImage = "logo_image"
        case nameKana = "name_kana"
        case address
        case stationName = "station_name"
        case ktaiCoupon = "ktai_coupon"
        case largeServiceArea = "large_service_area"
        case serviceArea = "service_area"
        case largeArea = "large_area"
        case middleArea = "middle_area"
        case smallArea = "small_area"
        case lat, lng, genre, budget
        case shopCatch = "catch"
        case capacity, access
        case mobileAccess = "mobile_access"
        case urls, photo
        case shopOpen = "open"
        case close
        case partyCapacity = "party_capacity"
        case otherMemo = "other_memo"
        case shopDetailMemo = "shop_detail_memo"
        case budgetMemo = "budget_memo"
        case wedding
        case freeDrink = "free_drink"
        case freeFood = "free_food"
        case privateRoom = "private_room"
        case horigotatsu, tatami, card
        case nonSmoking = "non_smoking"
        case charter, parking
        case barrierFree = "barrier_free"
        case show, karaoke, band, tv, lunch, midnight, english, pet, child, wifi
        case couponUrls = "coupon_urls"
        case course
    }
}

/// 予算情報
struct Budget: Codable {
    let code, name, average: String
}

/// クーポンURL情報
struct CouponUrls: Codable {
    let pc, sp: String
}

/// ジャンル情報
struct Genre: Codable {
    let name: String
    let genreCatch: String
    let code: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case genreCatch = "catch"
        case code
    }
}

/// エリア情報
struct Area: Codable {
    let code, name: String
}

/// JSONで数値と文字列のどちらも返るため、専用型で対応する
enum PartyCapacity: Codable {
    case integer(Int)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let value = try? container.decode(Int.self) {
            self = .integer(value)
            return
        }
        
        if let value = try? container.decode(String.self) {
            self = .string(value)
            return
        }
        
        throw DecodingError.typeMismatch(
            PartyCapacity.self,
            DecodingError.Context(
                codingPath: decoder.codingPath,
                debugDescription: "PartyCapacity は Int または String である必要があります"
            )
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .integer(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        }
    }
}

/// 写真情報
struct Photo: Codable {
    let pc: PC
    let mobile: Mobile
}

struct Mobile: Codable {
    let l, s: String
}

struct PC: Codable {
    let l, m, s: String
}

/// 店舗URL情報
struct Urls: Codable {
    let pc: String
}
