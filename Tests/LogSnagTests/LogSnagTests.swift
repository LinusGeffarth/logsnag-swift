import Combine
@testable import LogSnag
import XCTest

class MockDataClient: LogSnagDataClientProvider {
    var logs: [Options.Publish] = []
    var identifications: [Options.Identify] = []

    private lazy var jsonDecoder = JSONDecoder()
    
    init() {}
    
    @available(iOS 15.0, *)
    @available(macOS 12.0, *)
    @available(tvOS 15.0, *)
    @available(watchOS 8.0, *)
    func data(for request: URLRequest) async throws -> Bool {
        guard let data = request.httpBody else {
            XCTFail()
            return false
        }
        
        if var log = try? jsonDecoder.decode(Options.Publish.self, from: data) {
            log.project = nil
            logs.append(log)
            return true
        } else if var identification = try? jsonDecoder.decode(Options.Identify.self, from: data) {
            identification.project = nil
            identifications.append(identification)
            return true
        }
        return false
    }
    
    func dataTaskPublisher(for request: URLRequest) -> AnyPublisher<Bool, Error> {
        guard let data = request.httpBody else {
            XCTFail()
            return Just(false)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        
        if var log = try? jsonDecoder.decode(Options.Publish.self, from: data) {
            log.project = nil
            logs.append(log)
            return Just(true)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else if var identification = try? jsonDecoder.decode(Options.Identify.self, from: data) {
            identification.project = nil
            identifications.append(identification)
            return Just(true)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return Just(false)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

class LogSnagTests: XCTestCase {
    
    private var cancellables = Set<AnyCancellable>()
    
    @available(iOS 15.0, *)
    @available(macOS 12.0, *)
    @available(tvOS 15.0, *)
    @available(watchOS 8.0, *)
    func testAsyncAwaitPublish() async throws {
        let dataClient = MockDataClient()
        let client = LogSnagClient(
            dataClient: dataClient,
            project: "test-project",
            token: "TEST-TOKEN"
        )
        
        let success = try await client.asyncPublish(
            options: Options.Publish(
                channel: "test-channel",
                event: name
            )
        )
        
        XCTAssertTrue(success)
        
        XCTAssertEqual(
            dataClient.logs,
            [
                Options.Publish(channel: "test-channel", event: name, description: nil, icon: nil)
            ]
        )
    }
    
    func testCombinePublish() {
        let dataClient = MockDataClient()
        let client = LogSnagClient(
            dataClient: dataClient,
            project: "test-project",
            token: "TEST-TOKEN"
        )
        
        var success: Bool = false
        
        client.publish(
            options: Options.Publish(
                channel: "test-channel",
                event: name
            )
        )
        .receive(on: ImmediateScheduler.shared)
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { success = $0 }
        )
        .store(in: &cancellables)
        
        XCTAssertTrue(success)
        
        XCTAssertEqual(
            dataClient.logs,
            [
                Options.Publish(channel: "test-channel", event: name, description: nil, icon: nil)
            ]
        )
    }
    
    @available(iOS 15.0, *)
    @available(macOS 12.0, *)
    @available(tvOS 15.0, *)
    @available(watchOS 8.0, *)
    func testAsyncAwaitIdentify() async throws {
        let dataClient = MockDataClient()
        let client = LogSnagClient(
            dataClient: dataClient,
            project: "test-project",
            token: "TEST-TOKEN"
        )
        
        let success = try await client.asyncIdentify(
            options: Options.Identify(
                userId: "1",
                properties: [
                    "name": name,
                    "email": "email@example.com"
                ]
            )
        )
        
        XCTAssertTrue(success)
        
        XCTAssertEqual(
            dataClient.identifications,
            [
                Options.Identify(userId: "1", properties: ["name": name, "email": "email@example.com"])
            ]
        )
    }
    
    func testCombineIdentify() {
        let dataClient = MockDataClient()
        let client = LogSnagClient(
            dataClient: dataClient,
            project: "test-project",
            token: "TEST-TOKEN"
        )
        
        var success: Bool = false
        
        client.identify(
            options: Options.Identify(
                userId: "1",
                properties: [
                    "name": name,
                    "email": "email@example.com"
                ]
            )
        )
        .receive(on: ImmediateScheduler.shared)
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { success = $0 }
        )
        .store(in: &cancellables)
        
        XCTAssertTrue(success)
        
        XCTAssertEqual(
            dataClient.identifications,
            [
                Options.Identify(userId: "1", properties: ["name": name, "email": "email@example.com"])
            ]
        )
    }
}
