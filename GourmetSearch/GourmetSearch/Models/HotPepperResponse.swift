//
//  HotPepperResponse.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/19.
//

import Foundation

// https://app.quicktype.io
// 上記のサイトを使用してAPIから返ってきたJSONに合う構造体を作成した
// MARK: - HotPepperResponse

struct HotPepperResponse: Codable {
    let results: Results
}

// MARK: - Results

struct Results: Codable {
    let apiVersion: String
    let resultsAvailable: Int
    let resultsReturned: String
    let resultsStart: Int
    let shop: [Shop]
    
    enum CodingKeys: String, CodingKey {
        case apiVersion = "api_version"
        case resultsAvailable = "results_available"
        case resultsReturned = "results_returned"
        case resultsStart = "results_start"
        case shop
    }
}

// MARK: - Shop

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

// MARK: - Budget

struct Budget: Codable {
    let code, name, average: String
}

// MARK: - CouponUrls

struct CouponUrls: Codable {
    let pc, sp: String
}

// MARK: - Genre

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

// MARK: - Area

struct Area: Codable {
    let code, name: String
}

enum PartyCapacity: Codable {
    case integer(Int)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(PartyCapacity.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for PartyCapacity"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

// MARK: - Photo

struct Photo: Codable {
    let pc: PC
    let mobile: Mobile
}

// MARK: - Mobile

struct Mobile: Codable {
    let l, s: String
}

// MARK: - PC

struct PC: Codable {
    let l, m, s: String
}

// MARK: - Urls

struct Urls: Codable {
    let pc: String
}
