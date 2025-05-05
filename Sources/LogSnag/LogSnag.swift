import Combine
import Foundation

/// LogSnag Client
public class LogSnagClient {
    
    private let dataClient: LogSnagDataClientProvider
    private let project: String
    private let token: String
    
    private lazy var jsonEncoder = JSONEncoder()
    
    init(
        dataClient: LogSnagDataClientProvider,
        project: String,
        token: String
    ) {
        self.dataClient = dataClient
        self.project = project
        self.token = token
    }
    
    /// Construct a new LogSnag instance
    /// - Parameters:
    /// - project: Your project slug
    /// - token: Your API token. See docs.logsnag.com for details
    public init(
        project: String,
        token: String
    ) {
        self.project = project
        self.token = token
        self.dataClient = LogSnagDataClient()
    }
    
    private func createAuthorizationHeader() -> String {
        "Bearer \(token)"
    }
    
    private func request(to url: String, data: Data?) -> URLRequest {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Authorization": createAuthorizationHeader()
        ]
        request.httpBody = data
        return request
    }
    
    private func _publish(options: Options.Publish) -> URLRequest {
        var options = options
        options.project = project
        
        if options.autoAddUserId == true, options.userId == nil  {
            options.userId = generateOrRetrieveUserId()
            options.autoAddUserId = nil
        }
        
        let data = try? jsonEncoder.encode(options)
        return request(to: Endpoints.log, data: data!)
    }
    
    private func _identify(options: Options.Identify) -> URLRequest {
        var options = options
        options.project = project
        
        let data = try? jsonEncoder.encode(options)
        
        return request(to: Endpoints.identify, data: data!)
    }
    
    /// Publish a new event to LogSnag
    /// - Parameter options
    /// - Returns: true when successfully published
    @available(iOS 15.0, *)
    @available(macOS 12.0, *)
    @available(tvOS 15.0, *)
    @available(watchOS 8.0, *)
    @discardableResult
    public func asyncPublish(options: Options.Publish) async throws -> Bool {
        try await dataClient.data(for: _publish(options: options))
    }
    
    /// Publish a new event to LogSnag
    /// - Parameter options
    /// - Returns: Combine `Publisher`
    public func publish(options: Options.Publish) -> AnyPublisher<Bool, Error> {
        dataClient.dataTaskPublisher(for: _publish(options: options))
    }
    
    /// Identify the user with LogSnag
    /// - Parameter options
    /// - Returns: true when successfully identified
    @available(iOS 15.0, *)
    @available(macOS 12.0, *)
    @available(tvOS 15.0, *)
    @available(watchOS 8.0, *)
    @discardableResult
    public func asyncIdentify(options: Options.Identify) async throws -> Bool {
        try await dataClient.data(for: _identify(options: options))
    }
    
    /// Identify the user with LogSnag
    /// - Parameter options
    /// - Returns: Combine `Publisher`
    public func identify(options: Options.Identify) -> AnyPublisher<Bool, Error> {
        dataClient.dataTaskPublisher(for: _identify(options: options))
    }
    
    private func generateOrRetrieveUserId() -> String {
        // Retrieve the user ID if it's already been generated.
        if let existingId = UserDefaults.standard.string(forKey: "logSnagUserId") {
            return existingId
        } else {
            // Generate a new user ID if one does not exist, then store it for future use.
            let newId = UUID().uuidString
            UserDefaults.standard.setValue(newId, forKey: "logSnagUserId")
            return newId
        }
    }
}
