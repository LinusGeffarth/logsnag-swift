import Foundation

public struct Options {
    /// Options for publishing LogSnag events
    public struct Publish: Codable, Equatable {
        let channel: String
        let description: String?
        let event: String
        let icon: String?
        let notify: Bool?
        var project: String?
        var userId: String?
        var autoAddUserId: Bool?
        let tags: [String: String]?
        
        /// Creates a `PublishOptions` object to send to LogSnag
        /// - Parameters:
        ///   - channel: Channel name
        ///   - event: Event name
        ///   - description: Event description (default `nil`)
        ///   - icon: Event icon (emoji)  (default `nil`)
        ///   - notify: Send push notification  (default `nil`)
        ///   - userId: User ID  (default `nil`)
        ///   - autoAddUserId: Automatically add user ID to event  (default `nil`)
        ///   - tags: Additional information as key:value (default `nil`)
        public init(
            channel: String,
            event: String,
            description: String? = nil,
            icon: String? = nil,
            notify: Bool? = nil,
            userId: String? = nil,
            autoAddUserId: Bool? = nil,
            tags: [String: String]? = nil
        ) {
            self.channel = channel
            self.event = event
            self.description = description
            self.icon = icon
            self.notify = notify
            self.userId = userId
            self.autoAddUserId = autoAddUserId
            self.tags = tags
        }
        
        enum CodingKeys: String, CodingKey {
            case channel, description, event, icon, notify, project, tags
            case userId = "user_id"
            case autoAddUserId
        }
    }
    
    /// Options for identifying the user with LogSnag
    public struct Identify: Codable, Equatable {
        var project: String?
        var userId: String?
        let properties: [String: String]?
        
        /// Creates a `PublishOptions` object to send to LogSnag
        /// - Parameters:
        ///   - userId: User ID  (default `nil`)
        ///   - properties: Additional information as key:value (default `nil`)
        public init(
            userId: String? = nil,
            properties: [String: String]? = nil
        ) {
            self.userId = userId
            self.properties = properties
        }
        
        enum CodingKeys: String, CodingKey {
            case userId = "user_id"
            case properties, project
        }
    }
}
