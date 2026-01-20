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
        
        // "11:00～23:00" / "18:00～翌2:00" をざっくり分解
        let pattern = #"(\d{1,2}:\d{2}).*?(翌)?(\d{1,2}:\d{2})"#
        guard
            let regex = try? NSRegularExpression(pattern: pattern),
            let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
            let startRange = Range(match.range(at: 1), in: text),
            let endRange = Range(match.range(at: 3), in: text)
        else {
            return nil
        }
        
        let startMinutes = minutes(from: String(text[startRange]))
        let endMinutes   = minutes(from: String(text[endRange]))
        let nowMinutes   = currentMinutes(from: now)
        
        guard let start = startMinutes, let end = endMinutes else {
            return nil
        }
        
        // 翌日営業 or 終了時刻が開始より小さい場合
        if end < start {
            // 例: 18:00〜02:00
            return nowMinutes >= start || nowMinutes <= end
        } else {
            // 通常: 11:00〜23:00
            return (start...end).contains(nowMinutes)
        }
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
