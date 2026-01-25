//
//  HotPepperAPIError.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/25.
//

import Foundation

enum HotPepperAPIError: Error {
    case invalidAPIKey
    case badURL
    case httpStatus(Int)
    case decoding

    /// ユーザー向け日本語メッセージ
    var userMessage: String {
        switch self {
        case .invalidAPIKey:
            return "APIキーが未設定です。設定を確認してください。"
        case .badURL:
            return "不正なリクエストが行われました。"
        case .httpStatus(let code):
            switch code {
            case 401:
                return "認証に失敗しました。APIキーを確認してください。"
            case 403:
                return "アクセスが拒否されました。しばらく時間をおいてお試しください。"
            case 404:
                return "データが見つかりませんでした。条件を見直してください。"
            case 429:
                return "リクエストが多すぎます。しばらく待ってから再度お試しください。"
            case 500...599:
                return "サーバーでエラーが発生しています。時間をおいてお試しください。"
            default:
                return "通信に失敗しました。（ステータスコード: \(code)）"
            }
        case .decoding:
            return "データの読み取りに失敗しました。時間をおいてお試しください。"
        }
    }

    /// 任意の Error を日本語メッセージに変換
    static func userMessage(for error: Error) -> String {
        if let apiError = error as? HotPepperAPIError {
            return apiError.userMessage
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet:
                return "インターネットに接続できません。接続を確認してください。"
            case .timedOut:
                return "通信がタイムアウトしました。時間をおいてお試しください。"
            case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
                return "サーバーに接続できません。しばらくしてからお試しください。"
            case .networkConnectionLost:
                return "通信が中断されました。安定した回線で再度お試しください。"
            case .cancelled:
                return "通信がキャンセルされました。"
            default:
                return "通信に失敗しました。時間をおいてお試しください。"
            }
        }
        return "不明なエラーが発生しました。"
    }
}
