//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// Type of callback for both action and dismiss buttons.
public typealias CardNudgeButtonAction = ((_ state: MSFCardNudgeState) -> Void)

/// Properties that can be used to customize the appearance of the `CardNudge`.
@objc public protocol MSFCardNudgeState: NSObjectProtocol {
    /// Style to draw the control.
    @objc var style: MSFCardNudgeStyle { get set }

    /// Text for the main title area of the control.
    @objc var title: String { get set }

    /// Optional subtext to draw below the main title area.
    @objc var subtitle: String? { get set }

    /// Optional icon to draw at the leading edge of the control.
    @objc var mainIcon: UIImage? { get set }

    /// Optional accented text to draw below the main title area.
    @objc var accentText: String? { get set }

    /// Optional small icon to draw at the leading edge of `accentText`.
    @objc var accentIcon: UIImage? { get set }

    /// Title to display in the action button on the trailing edge of the control.
    ///
    /// To show an action button, provide values for both `actionButtonTitle` and  `actionButtonAction`.
    @objc var actionButtonTitle: String? { get set }

    /// Action to be dispatched by the action button on the trailing edge of the control.
    ///
    /// To show an action button, provide values for both `actionButtonTitle` and  `actionButtonAction`.
    @objc var actionButtonAction: CardNudgeButtonAction? { get set }

    /// Action to be dispatched by the dismiss ("close") button on the trailing edge of the control.
    @objc var dismissButtonAction: CardNudgeButtonAction? { get set }

    /// Custom design token set for this control, to use in place of the control's default Fluent tokens.
    @objc var overrideTokens: CardNudgeTokens? { get set }
}

/// View that represents the CardNudge.
public struct CardNudge: View, ConfigurableTokenizedControl {
    @Environment(\.fluentTheme) var fluentTheme: FluentTheme
    @ObservedObject var state: MSFCardNudgeStateImpl
    let defaultTokens: CardNudgeTokens = .init()
    var tokens: CardNudgeTokens {
        let tokens = resolvedTokens
        tokens.style = state.style
        return tokens
    }

    @ViewBuilder
    var icon: some View {
        if let icon = state.mainIcon {
            ZStack {
                RoundedRectangle(cornerRadius: tokens.circleRadius)
                    .frame(width: tokens.circleSize, height: tokens.circleSize)
                    .foregroundColor(Color(dynamicColor: tokens.buttonBackgroundColor))
                Image(uiImage: icon)
                    .renderingMode(.template)
                    .frame(width: tokens.iconSize, height: tokens.iconSize, alignment: .center)
                    .foregroundColor(Color(dynamicColor: tokens.accentColor))
            }
            .padding(.trailing, tokens.horizontalPadding)
            .showsLargeContentViewer(text: state.title, image: state.mainIcon)
        }
    }

    private var hasSecondTextRow: Bool {
        state.accentIcon != nil || state.accentText != nil || state.subtitle != nil
    }

    @ViewBuilder
    var textContainer: some View {
        VStack(alignment: .leading, spacing: tokens.interTextVerticalPadding) {
            Text(state.title)
                .font(.fluent(tokens.titleFont, shouldScale: false))
                .lineLimit(1)
                .foregroundColor(Color(dynamicColor: tokens.textColor))
                .showsLargeContentViewer(text: state.title, image: state.mainIcon)

            if hasSecondTextRow {
                HStack(spacing: tokens.accentPadding) {
                    if let accentIcon = state.accentIcon {
                        Image(uiImage: accentIcon)
                            .renderingMode(.template)
                            .frame(width: tokens.accentIconSize, height: tokens.accentIconSize)
                            .foregroundColor(Color(dynamicColor: tokens.accentColor))
                    }
                    if let accent = state.accentText {
                        Text(accent)
                            .font(.fluent(tokens.accentFont, shouldScale: false))
                            .layoutPriority(1)
                            .lineLimit(1)
                            .foregroundColor(Color(dynamicColor: tokens.accentColor))
                            .showsLargeContentViewer(text: accent, image: state.accentIcon)
                    }
                    if let subtitle = state.subtitle {
                        Text(subtitle)
                            .font(.fluent(tokens.subtitleFont, shouldScale: false))
                            .lineLimit(1)
                            .foregroundColor(Color(dynamicColor: tokens.subtitleTextColor))
                            .showsLargeContentViewer(text: subtitle)
                    }
                }
            }
        }
    }

    @ViewBuilder
    var buttons: some View {
        HStack(spacing: 0) {
            if let actionTitle = state.actionButtonTitle,
                      let action = state.actionButtonAction {
                SwiftUI.Button(actionTitle) {
                    action(state)
                }
                .font(.fluent(tokens.actionTitleFont, shouldScale: false))
                .lineLimit(1)
                .padding(.horizontal, tokens.buttonInnerPaddingHorizontal)
                .padding(.vertical, tokens.verticalPadding)
                .foregroundColor(Color(dynamicColor: tokens.accentColor))
                .background(
                    RoundedRectangle(cornerRadius: tokens.circleRadius)
                        .foregroundColor(Color(dynamicColor: tokens.buttonBackgroundColor))
                )
                .showsLargeContentViewer(text: actionTitle)
            }
            if let dismissAction = state.dismissButtonAction {
                let dismissImage = UIImage.staticImageNamed("dismiss-20x20")
                let dismissLabel = "Accessibility.Dismiss.Label".localized
                SwiftUI.Button(action: {
                    dismissAction(state)
                }, label: {
                    if let image = dismissImage {
                        Image(uiImage: image)
                    }
                })
                .padding(.horizontal, tokens.buttonInnerPaddingHorizontal)
                .padding(.vertical, tokens.verticalPadding)
                .accessibilityLabel(dismissLabel)
                .foregroundColor(Color(dynamicColor: tokens.textColor))
                .showsLargeContentViewer(text: dismissLabel, image: dismissImage)
            }
        }
    }

    @ViewBuilder
    var innerContents: some View {
        HStack(spacing: 0) {
            icon
            textContainer
            Spacer(minLength: tokens.accentPadding)
            buttons
                .layoutPriority(1)
        }
        .padding(.vertical, tokens.mainContentVerticalPadding)
        .padding(.horizontal, tokens.horizontalPadding)
        .frame(minHeight: tokens.minimumHeight)
    }

    public var body: some View {
        innerContents
            .background(
                RoundedRectangle(cornerRadius: tokens.cornerRadius)
                    .strokeBorder(lineWidth: tokens.outlineWidth)
                    .foregroundColor(Color(dynamicColor: tokens.outlineColor))
                    .background(
                        Color(dynamicColor: tokens.backgroundColor)
                            .cornerRadius(tokens.cornerRadius)
                    )
            )
            .padding(.vertical, tokens.verticalPadding)
            .padding(.horizontal, tokens.horizontalPadding)
    }

    public init(style: MSFCardNudgeStyle, title: String) {
        let state = MSFCardNudgeStateImpl(style: style, title: title)
        self.state = state
    }
}

class MSFCardNudgeStateImpl: NSObject, ControlConfiguration, MSFCardNudgeState {
    @Published var title: String
    @Published var subtitle: String?
    @Published var mainIcon: UIImage?
    @Published var accentIcon: UIImage?
    @Published var accentText: String?

    /// Title to display in the action button on the trailing edge of the control.
    ///
    /// To show an action button, provide values for both `actionButtonTitle` and  `actionButtonAction`.
    @Published var actionButtonTitle: String?

    /// Action to be dispatched by the action button on the trailing edge of the control.
    ///
    /// To show an action button, provide values for both `actionButtonTitle` and  `actionButtonAction`.
    @Published var actionButtonAction: CardNudgeButtonAction?

    /// Action to be dispatched by the dismiss ("close") button on the trailing edge of the control.
    @Published var dismissButtonAction: CardNudgeButtonAction?

    /// Design token set for this control, to use in place of the control's default Fluent tokens.
    @Published var overrideTokens: CardNudgeTokens?

    /// Style to draw the control.
    @Published var style: MSFCardNudgeStyle

    @objc init(style: MSFCardNudgeStyle, title: String) {
        self.style = style
        self.title = title

        super.init()
    }
}
