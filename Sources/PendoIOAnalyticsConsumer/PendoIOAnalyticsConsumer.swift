/*
MIT License

Copyright (c) 2025 Tech Artists Agency

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/


import TAAnalytics
import Pendo

/// Sends messages to Pendo Analytics about analytics events & user properties.
public class PendoIOAnalyticsConsumer: AnalyticsConsumer {

    public typealias T = PendoManager

    private let sdkKey: String
    private let enabledInstallTypes: [TAAnalyticsConfig.InstallType]
    private let isRedacted: Bool

    // MARK: - Init

    public init(
        enabledInstallTypes: [TAAnalyticsConfig.InstallType] = TAAnalyticsConfig.InstallType.allCases,
        isRedacted: Bool = true,
        sdkKey: String
    ) {
        self.sdkKey = sdkKey
        self.enabledInstallTypes = enabledInstallTypes
        self.isRedacted = isRedacted
    }

    // MARK: - AnalyticsConsumer

    public func startFor(
        installType: TAAnalyticsConfig.InstallType,
        userDefaults: UserDefaults,
        TAAnalytics: TAAnalytics
    ) async throws {
        if !self.enabledInstallTypes.contains(installType) {
            throw InstallTypeError.invalidInstallType
        }

        PendoManager.shared().setup(sdkKey)
    }

    public func track(trimmedEvent: EventAnalyticsModelTrimmed, params: [String: any AnalyticsBaseParameterValue]?) {
        var eventProperties = [String: Any]()
        if let params = params {
            for (key, value) in params {
                eventProperties[key] = value.description
            }
        }

        PendoManager.shared().track(trimmedEvent.rawValue, properties: eventProperties)
    }

    public func set(trimmedUserProperty: UserPropertyAnalyticsModelTrimmed, to: String?) {
        let key = trimmedUserProperty.rawValue

        if let value = to {
            PendoManager.shared().setVisitorData([key: value])
        } else {
            PendoManager.shared().setVisitorData([key: NSNull()])
        }
    }

    public func trim(event: EventAnalyticsModel) -> EventAnalyticsModelTrimmed {
        EventAnalyticsModelTrimmed(event.rawValue.ta_trim(toLength: 40, debugType: "event"))
    }

    public func trim(userProperty: UserPropertyAnalyticsModel) -> UserPropertyAnalyticsModelTrimmed {
        UserPropertyAnalyticsModelTrimmed(userProperty.rawValue.ta_trim(toLength: 24, debugType: "user property"))
    }

    public var wrappedValue: T {
        PendoManager.shared()
    }
}
