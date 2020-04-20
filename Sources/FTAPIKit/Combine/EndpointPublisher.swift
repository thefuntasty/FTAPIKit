import Combine
import Foundation

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
extension Publishers {
    public struct Endpoint<R, E: Error>: Publisher {
        public typealias Output = R
        public typealias Failure = E

        public typealias Builder = (@escaping (Result<R, E>) -> Void) -> URLSessionTask?

        let builder: Builder

        public func receive<S>(subscriber: S) where S: Subscriber, Self.Failure == S.Failure, Self.Output == S.Input {
            let subscription = EndpointSubscription(subscriber: subscriber, builder: builder)
            subscriber.receive(subscription: subscription)
        }
    }
}
