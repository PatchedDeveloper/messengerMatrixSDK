// 
// Copyright 2020 Vector Creations Ltd
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

/// BuildSettings provides settings computed at build time.
/// In future, it may be automatically generated from xcconfig files
@objcMembers
final class BuildSettings: NSObject {
    
    // MARK: - Bundle Settings
    static var applicationGroupIdentifier: String {
        guard let applicationGroupIdentifier = Bundle.app.object(forInfoDictionaryKey: "applicationGroupIdentifier") as? String else {
            fatalError("applicationGroupIdentifier should be defined")
        }
        return applicationGroupIdentifier
    }
    
    static var baseBundleIdentifier: String {
        guard let baseBundleIdentifier = Bundle.app.object(forInfoDictionaryKey: "baseBundleIdentifier") as? String else {
            fatalError("baseBundleIdentifier should be defined")
        }
        return baseBundleIdentifier
    }
    
    static var keychainAccessGroup: String {
        guard let keychainAccessGroup = Bundle.app.object(forInfoDictionaryKey: "keychainAccessGroup") as? String else {
            fatalError("keychainAccessGroup should be defined")
        }
        return keychainAccessGroup
    }
    
    static var applicationURLScheme: String? {
        guard let urlTypes = Bundle.app.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [AnyObject],
              let urlTypeDictionary = urlTypes.first as? [String: AnyObject],
              let urlSchemes = urlTypeDictionary["CFBundleURLSchemes"] as? [AnyObject],
              let externalURLScheme = urlSchemes.first as? String else {
            return nil
        }
        
        return externalURLScheme
    }
    
    static var pushKitAppIdProd: String {
        return baseBundleIdentifier + ".ios.voip.prod"
    }
    
    static var pushKitAppIdDev: String {
        return baseBundleIdentifier + ".ios.voip.dev"
    }
    
    static var pusherAppIdProd: String {
        return baseBundleIdentifier + ".ios.prod"
    }
    
    static var pusherAppIdDev: String {
        return baseBundleIdentifier + ".ios.dev"
    }
    
    static var pushKitAppId: String {
        #if DEBUG
        return pushKitAppIdDev
        #else
        return pushKitAppIdProd
        #endif
    }
    
    static var pusherAppId: String {
        #if DEBUG
        return pusherAppIdDev
        #else
        return pusherAppIdProd
        #endif
    }
    
    // Element-Web instance for the app
    static let applicationWebAppUrlString = "https://bigstarmessenger.com"
    
    
    // MARK: - Localization
    
    /// Whether to allow the app to use a right to left layout or force left to right for all languages
    static let disableRightToLeftLayout = true
    
    
    // MARK: - Server configuration
    
    // Default servers proposed on the authentication screen
    static let forceHomeserverSelection = false
    static let serverConfigDefaultHomeserverUrlString = "https://matrix.bigstarmessenger.com"
    static let serverConfigDefaultIdentityServerUrlString = "https://matrix.bigstarmessenger.com"
    
    static let serverConfigSygnalAPIUrlString = "https://sygnal.bigstarmessenger.com/_matrix/push/v1/notify"
    
    
    
    // MARK: - Legal URLs
    
    // Note: Set empty strings to hide the related entry in application settings
    static let applicationCopyrightUrlString = ""
    static let applicationPrivacyPolicyUrlString = ""
    static let applicationAcceptableUsePolicyUrlString = ""
    static let applicationHelpUrlString = ""
    
    
    // MARK: - Permalinks
    // Hosts/Paths for URLs that will considered as valid permalinks. Those permalinks are opened within the app.
    static let permalinkSupportedHosts: [String: [String]] = [
        "app.element.io": [],
        "bigstarmessenger.com": [],
        "staging.element.io": [],
        "develop.element.io": [],
        "mobile.element.io": [""],
        // Historical ones
        "riot.im": ["/app", "/staging", "/develop"],
        "www.riot.im": ["/app", "/staging", "/develop"],
        "vector.im": ["/app", "/staging", "/develop"],
        "www.vector.im": ["/app", "/staging", "/develop"],
        // Official Matrix ones
        "matrix.to": ["/"],
        "www.matrix.to": ["/"],
        // Client Permalinks (for use with `BuildSettings.clientPermalinkBaseUrl`)
//        "example.com": ["/"],
//        "www.example.com": ["/"],
    ]
    
    // For use in clients that use a custom base url for permalinks rather than matrix.to.
    // This baseURL is used to generate permalinks within the app (E.g. timeline message permalinks).
    // Optional String that when set is used as permalink base, when nil matrix.to format is used.
    // Example value would be "https://www.example.com", note there is no trailing '/'.
    static let clientPermalinkBaseUrl: String? = nil
    
    // MARK: - VoIP
    static var allowVoIPUsage: Bool {
        #if canImport(JitsiMeetSDK)
        return true
        #else
        return false
        #endif
    }
    static let stunServerFallbackUrlString: String? = "stun:turn.bigstarmessenger.com"
    
    // MARK: -  Public rooms Directory
    // List of homeservers for the public rooms directory
    static let publicRoomsDirectoryServers = [
        "bigstarmessenger.com",
        "gitter.im"
    ]
    
    // MARK: -  Rooms Screen
    static let roomsAllowToJoinPublicRooms: Bool = true
    
    // MARK: - Analytics
    
    /// A type that represents how to set up the analytics module in the app.
    ///
    /// **Note:** Analytics are disabled by default for forks.
    /// If you are maintaining a fork, set custom configurations.
    struct AnalyticsConfiguration {
        /// Whether or not analytics should be enabled.
        let isEnabled: Bool
        /// The host to use for PostHog analytics.
        let host: String
        /// The public key for submitting analytics.
        let apiKey: String
        /// The URL to open with more information about analytics terms.
        let termsURL: URL
    }
    
    #if DEBUG
    /// The configuration to use for analytics during development. Set `isEnabled` to false to disable analytics in debug builds.
    static let analyticsConfiguration = AnalyticsConfiguration(isEnabled: BuildSettings.baseBundleIdentifier.starts(with: "im.vector.app"),
                                                               host: "https://posthog.element.dev",
                                                               apiKey: "phc_VtA1L35nw3aeAtHIx1ayrGdzGkss7k1xINeXcoIQzXN",
                                                               termsURL: URL(string: "https://element.io/cookie-policy")!)
    #else
    /// The configuration to use for analytics. Set `isEnabled` to false to disable analytics.
    static let analyticsConfiguration = AnalyticsConfiguration(isEnabled: BuildSettings.baseBundleIdentifier.starts(with: "im.vector.app"),
                                                               host: "https://posthog.hss.element.io",
                                                               apiKey: "phc_Jzsm6DTm6V2705zeU5dcNvQDlonOR68XvX2sh1sEOHO",
                                                               termsURL: URL(string: "https://element.io/cookie-policy")!)
    #endif
    
    
    // MARK: - Bug report
    static let bugReportEndpointUrlString = "https://riot.im/bugreports"
    // Use the name allocated by the bug report server
    static let bugReportApplicationId = "riot-ios"
    static let bugReportUISIId = "element-auto-uisi"
    
    
    // MARK: - Integrations
    static let integrationsUiUrlString = "https://scalar.vector.im/"
    static let integrationsRestApiUrlString = "https://scalar.vector.im/api"
    // Widgets in those paths require a scalar token
    static let integrationsScalarWidgetsPaths = [
        "https://scalar.vector.im/_matrix/integrations/v1",
        "https://scalar.vector.im/api",
        "https://scalar-staging.vector.im/_matrix/integrations/v1",
        "https://scalar-staging.vector.im/api",
        "https://scalar-staging.riot.im/scalar/api",
    ]
    // Jitsi server used outside integrations to create conference calls from the call button in the timeline.
    // Setting this to nil effectively disables Jitsi conference calls (given that there is no wellknown override).
    // Note: this will not remove the conference call button, use roomScreenAllowVoIPForNonDirectRoom setting.
    static let jitsiServerUrl: URL? = URL(string: "https://jitsi.bigstarmessenger.com")

    
    // MARK: - Features
    
    /// Setting to force protection by pin code
    static let forcePinProtection: Bool = false
    
    /// Max allowed time to continue using the app without prompting PIN
    static let pinCodeGraceTimeInSeconds: TimeInterval = 0
    
    /// Force non-jailbroken app usage
    static let forceNonJailbrokenUsage: Bool = true
    
    static let allowSendingStickers: Bool = true
    
    static let allowLocalContactsAccess: Bool = true
    
    static let allowInviteExernalUsers: Bool = true
    
    static let allowBackgroundAudioMessagePlayback: Bool = true
    
    // MARK: - Side Menu
    static let enableSideMenu: Bool = true && !newAppLayoutEnabled
    static let sideMenuShowInviteFriends: Bool = false

    /// Whether to read the `io.element.functional_members` state event and exclude any service members when computing a room's name and avatar.
    static let supportFunctionalMembers: Bool = true
    
    // MARK: - Feature Specifics
    
    /// Not allowed pin codes. User won't be able to select one of the pin in the list.
    static let notAllowedPINs: [String] = []
    
    /// Maximum number of allowed pin failures when unlocking, before force logging out the user. Defaults to `3`
    static let maxAllowedNumberOfPinFailures: Int = 3
    
    /// Maximum number of allowed biometrics failures when unlocking, before fallbacking the user to the pin if set or logging out the user. Defaults to `5`
    static let maxAllowedNumberOfBiometricsFailures: Int = 5
    
    /// Indicates should the app log out the user when number of PIN failures reaches `maxAllowedNumberOfPinFailures`. Defaults to `false`
    static let logOutUserWhenPINFailuresExceeded: Bool = false
    
    /// Indicates should the app log out the user when number of biometrics failures reaches `maxAllowedNumberOfBiometricsFailures`. Defaults to `false`
    static let logOutUserWhenBiometricsFailuresExceeded: Bool = false
    
    static let showNotificationsV2: Bool = true
    
    // MARK: - Main Tabs
    
    static let homeScreenShowFavouritesTab: Bool = true
    static let homeScreenShowPeopleTab: Bool = true
    static let homeScreenShowRoomsTab: Bool = true

    // MARK: - General Settings Screen
    
    static let settingsScreenShowUserFirstName: Bool = false
    static let settingsScreenShowUserSurname: Bool = false
    static let settingsScreenAllowAddingEmailThreepids: Bool = false
    static let settingsScreenAllowAddingPhoneThreepids: Bool = true
    static let settingsScreenShowThreepidExplanatory: Bool = true
    static let settingsScreenShowDiscoverySettings: Bool = true
    static let settingsScreenAllowIdentityServerConfig: Bool = true
    static let settingsScreenShowConfirmMediaSize: Bool = true
    static let settingsScreenShowAdvancedSettings: Bool = false
    static let settingsScreenShowLabSettings: Bool = false
    static let settingsScreenAllowChangingRageshakeSettings: Bool = false
    static let settingsScreenAllowChangingCrashUsageDataSettings: Bool = false
    static let settingsScreenAllowBugReportingManually: Bool = false
    static let settingsScreenAllowDeactivatingAccount: Bool = true
    static let settingsScreenShowChangePassword:Bool = false
    static let settingsScreenShowEnableStunServerFallback: Bool = false
    static let settingsScreenShowNotificationDecodedContentOption: Bool = true
    static let settingsScreenShowNsfwRoomsOption: Bool = false
    static let settingsSecurityScreenShowSessions:Bool = true
    static let settingsSecurityScreenShowSetupBackup:Bool = true
    static let settingsSecurityScreenShowRestoreBackup:Bool = true
    static let settingsSecurityScreenShowDeleteBackup:Bool = true
    static let settingsSecurityScreenShowCryptographyInfo:Bool = false
    static let settingsSecurityScreenShowCryptographyExport:Bool = false
    static let settingsSecurityScreenShowAdvancedUnverifiedDevices:Bool = true
    /// A setting to enable the presence configuration settings section.
    static let settingsScreenPresenceAllowConfiguration: Bool = false

    // MARK: - Timeline settings
    static let roomInputToolbarCompressionMode: MediaCompressionMode = .prompt
    
    enum MediaCompressionMode {
        case prompt, small, medium, large, none
    }
    
    // MARK: - Room Creation Screen
    
    static let roomCreationScreenAllowEncryptionConfiguration: Bool = true
    static let roomCreationScreenRoomIsEncrypted: Bool = true
    static let roomCreationScreenAllowRoomTypeConfiguration: Bool = true
    static let roomCreationScreenRoomIsPublic: Bool = false
    
    // MARK: - Room Screen
    
    static let roomScreenAllowVoIPForDirectRoom: Bool = true
    static let roomScreenAllowVoIPForNonDirectRoom: Bool = true
    static let roomScreenAllowCameraAction: Bool = true
    static let roomScreenAllowMediaLibraryAction: Bool = true
    static let roomScreenAllowStickerAction: Bool = true
    static let roomScreenAllowFilesAction: Bool = true
    
    // Timeline style
    static let roomScreenAllowTimelineStyleConfiguration: Bool = false
    static let roomScreenTimelineDefaultStyleIdentifier: RoomTimelineStyleIdentifier = .bubble
    static var isRoomScreenEnableMessageBubblesByDefault: Bool {
        return self.roomScreenTimelineDefaultStyleIdentifier == .bubble
    }
    static let roomScreenUseOnlyLatestUserAvatarAndName: Bool = false

    /// Allow split view detail view stacking    
    static let allowSplitViewDetailsScreenStacking: Bool = true
    
    // MARK: - Room Contextual Menu

    static let roomContextualMenuShowMoreOptionForMessages: Bool = true
    static let roomContextualMenuShowMoreOptionForStates: Bool = true
    static let roomContextualMenuShowReportContentOption: Bool = true

    // MARK: - Room Info Screen
    
    static let roomInfoScreenShowIntegrations: Bool = true

    // MARK: - Room Settings Screen
    
    static let roomSettingsScreenShowLowPriorityOption: Bool = true
    static let roomSettingsScreenShowDirectChatOption: Bool = true
    static let roomSettingsScreenAllowChangingAccessSettings: Bool = true
    static let roomSettingsScreenAllowChangingHistorySettings: Bool = true
    static let roomSettingsScreenShowAddressSettings: Bool = false
    static let roomSettingsScreenShowAdvancedSettings: Bool = false
    static let roomSettingsScreenAdvancedShowEncryptToVerifiedOption: Bool = true

    // MARK: - Room Member Screen
    
    static let roomMemberScreenShowIgnore: Bool = true

    // MARK: - Message
    static let messageDetailsAllowShare: Bool = true
    static let messageDetailsAllowPermalink: Bool = true
    static let messageDetailsAllowViewSource: Bool = false
    static let messageDetailsAllowSave: Bool = true
    static let messageDetailsAllowCopyMedia: Bool = true
    static let messageDetailsAllowPasteMedia: Bool = true
    
    // MARK: - Notifications
    static let decryptNotificationsByDefault: Bool = true
    
    // MARK: - HTTP
    /// Additional HTTP headers will be sent by all requests. Not recommended to use request-specific headers, like `Authorization`.
    /// Empty dictionary by default.
    static let httpAdditionalHeaders: [String: String] = [:]
    
    
    // MARK: - Authentication Screen
    static let authScreenShowRegister = true
    static let authScreenShowPhoneNumber = true
    static let authScreenShowForgotPassword = true
    static let authScreenShowCustomServerOptions = true
    static let authScreenShowSocialLoginSection = true
    
    // MARK: - Authentication Options
    static let authEnableRefreshTokens = false
    
    // MARK: - Onboarding
    static let onboardingShowAccountPersonalization = true
    static let onboardingEnableNewAuthenticationFlow = true
    
    // MARK: - Unified Search
    static let unifiedSearchScreenShowPublicDirectory = true
    
    // MARK: - Secrets Recovery
    static let secretsRecoveryAllowReset = true
    
    // MARK: - UISI Autoreporting
    static let cryptoUISIAutoReportingEnabled = false
    
    // MARK: - Polls
    
    static let pollsEnabled = true
    
    // MARK: - Location Sharing
    
    /// Overwritten by the home server's .well-known configuration (if any exists)
    static let defaultTileServerMapStyleURL = URL(string: "https://api.maptiler.com/maps/streets/style.json?key=fU3vlMsMn4Jb6dnEIFsx")!
    
    static let locationSharingEnabled = true
    
    // MARK: - Voice Broadcast
    static let voiceBroadcastChunkLength: Int = 120
    static let voiceBroadcastMaxLength: UInt = 14400 // 240min.

    // MARK: - MXKAppSettings
    static let enableBotCreation: Bool = false
    static let maxAllowedMediaCacheSize: Int = 1073741824
    static let presenceColorForOfflineUser: Int = 15020851
    static let presenceColorForOnlineUser: Int = 3401011
    static let presenceColorForUnavailableUser: Int = 15066368
    static let showAllEventsInRoomHistory: Bool = false
    static let showLeftMembersInRoomMemberList: Bool = false
    static let showRedactionsInRoomHistory: Bool = false
    static let showUnsupportedEventsInRoomHistory: Bool = false
    static let sortRoomMembersUsingLastSeenTime: Bool = true
    static let syncLocalContacts: Bool = true
    
    // MARK: - New App Layout
    static let newAppLayoutEnabled = true

    // MARK: - QR Login
    
    /// Flag indicating whether the QR login enabled from login screen
    static let qrLoginEnabledFromNotAuthenticated = false
    /// Flag indicating whether the QR login enabled from Device Manager screen
    static let qrLoginEnabledFromAuthenticated = false
    /// Flag indicating whether displaying QRs enabled for the QR login screens
    static let qrLoginEnableDisplayingQRs = false
    
    static let rendezvousServerBaseURL = URL(string: "https://rendezvous.lab.element.dev/")!
    
    // MARK: - Alerts
    static let showUnverifiedSessionsAlert = true
}
