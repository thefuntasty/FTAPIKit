import XCTest
@testable import FTAPIKit

final class StressTests: XCTestCase {

    private func apiAdapter() -> URLSessionAPIAdapter {
        return URLSessionAPIAdapter(baseUrl: URL(string: "http://httpbin.org/")!)
    }

    private let extendedTimeout: TimeInterval = 120.0

    func testStressMultipleRequestsViaGet() {
        struct Endpoint: APIEndpoint {
            let path = "get"
        }

        let adapter: APIAdapter = apiAdapter()
        let expectation = self.expectation(description: "Result")

        let testingRange = 0...9
        let testingRequests = testingRange.count * 4

        let counter: Serialized<UInt> = Serialized(initialValue: 0)
        counter.didSet = { count in
            if testingRequests > count {
                //nop
            } else if testingRequests == count {
                expectation.fulfill()
            } else if testingRequests < count {
                print(testingRequests)
                print(count)
                XCTFail("Number of responses exceeded number of requests")
            }
        }

        for _ in testingRange {
            DispatchQueue.global(qos: .background).async {
                adapter.request(data: Endpoint()) { result in
                    if case let .failure(error) = result {
                        XCTFail(error.localizedDescription)
                    }
                    counter.asyncAccess { $0 + 1 }
                }
            }
            DispatchQueue.global(qos: .userInitiated).async {
                adapter.request(data: Endpoint()) { result in
                    if case let .failure(error) = result {
                        XCTFail(error.localizedDescription)
                    }
                    counter.asyncAccess { $0 + 1 }
                }
            }
            DispatchQueue.global(qos: .userInteractive).async {
                adapter.request(data: Endpoint()) { result in
                    if case let .failure(error) = result {
                        XCTFail(error.localizedDescription)
                    }
                    counter.asyncAccess { $0 + 1 }
                }
            }
            DispatchQueue.global(qos: .utility).async {
                adapter.request(data: Endpoint()) { result in
                    if case let .failure(error) = result {
                        XCTFail(error.localizedDescription)
                    }
                    counter.asyncAccess { $0 + 1 }
                }
            }
        }

        wait(for: [expectation], timeout: extendedTimeout)
    }

    static var allTests = [
        ("testStressMultipleRequestsViaGet", testStressMultipleRequestsViaGet)
    ]

}
