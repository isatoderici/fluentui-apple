//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import SwiftUI

/// Design token set for the `AvatarGroup` control
open class AvatarGroupTokens: ControlTokens {

    /// Defines the style of the `Avatar` controls in the `AvatarGroup`.
    public internal(set) var style: MSFAvatarGroupStyle = .stack

    /// Defines the size of the `Avatar` controls in the `AvatarGroup`.
    public internal(set) var size: MSFAvatarSize = .large

    // MARK: - Design Tokens

    /// CGFloat that defines the space between  the `Avatar` controls hosted by the `AvatarGroup`.
    open var interspace: CGFloat {
        switch style {
        case .stack:
            switch size {
            case .xsmall, .small:
                return -GlobalTokens.spacing(.xxxSmall)
            case .medium:
                return -GlobalTokens.spacing(.xxSmall)
            case .large:
                return -GlobalTokens.spacing(.xSmall)
            case .xlarge, .xxlarge:
                return -GlobalTokens.spacing(.small)
            }
        case .pile:
            switch size {
            case .xsmall, .small:
                return GlobalTokens.spacing(.xxSmall)
            case .medium, .large, .xlarge, .xxlarge:
                return GlobalTokens.spacing(.xSmall)
            }
        }
    }
}
