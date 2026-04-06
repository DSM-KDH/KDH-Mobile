import SwiftUI

public enum KDHFontStyle {
    case heading3
    case body1, body2, body3, body4, body5, body6, body7, body8
    case caption1, caption2, caption3, caption4, caption5

    var size: CGFloat {
        switch self {
        case .heading3: return 24
        case .body1, .body2: return 20
        case .body3, .body4: return 18
        case .body5, .body6, .body7, .body8: return 16
        case .caption1, .caption2: return 14
        case .caption3, .caption4, .caption5: return 12
        }
    }

    var weight: KDHFontWeight {
        switch self {
        case .heading3, .body1, .body3, .body5, .caption3:
            return .semiBold
        case .body2, .body4, .body6, .caption1, .caption4:
            return .medium
        case .body7, .caption2, .caption5:
            return .regular
        case .body8:
            return .light
        }
    }
}

public enum KDHFontWeight: String {
    case semiBold = "Pretendard-SemiBold"
    case medium   = "Pretendard-Medium"
    case regular  = "Pretendard-Regular"
    case light    = "Pretendard-Light"
}

public extension Font {
    static func kdf(_ style: KDHFontStyle) -> Font {
        Font.custom(style.weight.rawValue, size: style.size)
    }
}
