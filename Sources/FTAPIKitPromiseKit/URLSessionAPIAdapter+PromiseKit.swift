import PromiseKit
import Foundation
#if !COCOAPODS
import FTAPIKit
#endif

public struct APIDataTask<T> {
    public let sessionTask: Guarantee<URLSessionTask?>
    public let response: Promise<T>
}

extension URLSessionAPIAdapter {
    public func dataTask<Endpoint: APIResponseEndpoint>(response endpoint: Endpoint) -> APIDataTask<Endpoint.Response> {
        let task = Guarantee<URLSessionTask?>.pending()
        let response = Promise<Endpoint.Response>.pending()

        dataTask(response: endpoint, creation: task.resolve, completion: { result in
            if task.guarantee.isPending {
                task.resolve(nil)
            }
            response.resolver.resolve(result: result)
        })
        return APIDataTask(sessionTask: task.guarantee, response: response.promise)
    }

    public func dataTask(data endpoint: APIEndpoint) -> APIDataTask<Data> {
        let task = Guarantee<URLSessionTask?>.pending()
        let response = Promise<Data>.pending()

        dataTask(data: endpoint, creation: task.resolve, completion: { result in
            if task.guarantee.isPending {
                task.resolve(nil)
            }

            response.resolver.resolve(result: result)
        })
        return APIDataTask(sessionTask: task.guarantee, response: response.promise)
    }
}
