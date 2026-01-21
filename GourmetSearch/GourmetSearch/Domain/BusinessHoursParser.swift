//
//  BusinessHoursParser.swift
//  GourmetSearch
//
//  Created by miyamotokenshin on R 8/01/21.
//

import Foundation

enum BusinessHoursParser {
    
    /// 営業中なら true、営業時間外なら false、判定不能なら nil
    static func isOpen(
        now: Date = .now,
        text: String
    ) -> Bool? {
        
        // 区切り文字を統一（全角・半角対策）
        let normalized = text
            .replacingOccurrences(of: "〜", with: "-")
            .replacingOccurrences(of: "～", with: "-")
        
        // "11:00-14:00 / 17:00-23:00" などから全時間帯を抽出
        let pattern = #"(\d{1,2}:\d{2})\s*-\s*(\d{1,2}:\d{2})"#
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }
        
        let matches = regex.matches(
            in: normalized,
            range: NSRange(normalized.startIndex..., in: normalized)
        )
        
        // 時間帯が1つも取れない場合は判定不能
        guard !matches.isEmpty else { return nil }
        
        let nowMinutes = currentMinutes(from: now)
        
        for match in matches {
            guard
                let startRange = Range(match.range(at: 1), in: normalized),
                let endRange   = Range(match.range(at: 2), in: normalized),
                let start = minutes(from: String(normalized[startRange])),
                let end   = minutes(from: String(normalized[endRange]))
            else {
                continue
            }
            
            // 翌日跨ぎ（例: 18:00-02:00）
            if end < start {
                if nowMinutes >= start || nowMinutes <= end {
                    return true
                }
            }
            // 通常時間帯
            else if (start...end).contains(nowMinutes) {
                return true
            }
        }
        
        // どの時間帯にも該当しなければ営業時間外
        return false
    }
    
    /// "HH:mm" → 分(Int) に変換
    private static func minutes(from time: String) -> Int? {
        let parts = time.split(separator: ":")
        guard
            parts.count == 2,
            let hour = Int(parts[0]),
            let minute = Int(parts[1])
        else { return nil }
        
        return hour * 60 + minute
    }
    
    /// 現在時刻 → 分(Int)
    private static func currentMinutes(from date: Date) -> Int {
        let comp = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (comp.hour ?? 0) * 60 + (comp.minute ?? 0)
    }
}
