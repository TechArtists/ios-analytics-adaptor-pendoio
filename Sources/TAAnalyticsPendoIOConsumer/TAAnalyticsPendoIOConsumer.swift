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

// The Swift Programming Language
// https://docs.swift.org/swift-book

import TAAnalytics

import Pendo

/// Sends messages to Pendo Analytics about analytics events & user properties.
public class PendoAnalyticsConsumer: AnalyticsConsumer, AnalyticsConsumerWithWriteOnlyUserID {

    public typealias T = PendoAnalyticsConsumer

    private let enabledInstallTypes: [TAAnalyticsConfig.InstallType]
    private let appKey: String

    // MARK: AnalyticsConsumer

    /// - Parameters:
    ///   - isRedacted: If parameter & user property values should be redacted.
    ///   - enabledInstallTypes: Install types for which the consumer is enabled.
    init(appKey: String, enabledInstallTypes: [TAAnalyticsConfig.InstallType]) {
        self.appKey = appKey
        self.enabledInstallTypes = enabledInstallTypes
    }

    public func startFor(
        installType: TAAnalyticsConfig.InstallType,
        userDefaults: UserDefaults,
        TAAnalytics: TAAnalytics
    ) async throws {
        if !self.enabledInstallTypes.contains(installType) {
            throw InstallTypeError.invalidInstallType
        }

        PendoManager.shared().setup(appKey)
    }

    public func track(trimmedEvent: TrimmedEvent, params: [String: AnalyticsBaseParameterValue]?) {
        let event = trimmedEvent.event
        
        var eventProperties = [String: Any]()
        if let params = params {
            for (key, value) in params {
                eventProperties[key] = value.description
            }
        }

        // Track the event in Pendo
        PendoManager.shared().track(event.rawValue, properties: eventProperties)
    }

    public func set(trimmedUserProperty: TrimmedUserProperty, to: String?) {
        let userPropertyKey = trimmedUserProperty.userProperty.rawValue
        
        if let value = to {
            // Set user properties in Pendo
            let userInfo: [String: String] = [userPropertyKey: value]
            PendoManager.shared().setVisitorData(userInfo)
        } else {
            // Handle the removal of the property if necessary
            PendoManager.shared().setVisitorData([userPropertyKey: NSNull()])
        }
    }

    public func trim(event: AnalyticsEvent) -> TrimmedEvent {
        // Pendo doesn't have strict event name limits, but you can enforce one.
        let trimmedEventName = event.rawValue.ob_trim(type: "event", toLength: 40)
        return TrimmedEvent(trimmedEventName)
    }

    public func trim(userProperty: AnalyticsUserProperty) -> TrimmedUserProperty {
        // Pendo doesn't have strict user property key limits, but you can enforce one.
        let trimmedUserPropertyKey = userProperty.rawValue.ob_trim(type: "user property", toLength: 24)
        return TrimmedUserProperty(trimmedUserPropertyKey)
    }

    public var wrappedValue: Self {
        return self
    }

    // MARK: AnalyticsConsumerWithWriteOnlyUserID

    public func set(userID: String?) {
        if let userID = userID {
           
        }
    }
}
