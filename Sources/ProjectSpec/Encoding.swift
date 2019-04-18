import Foundation
import JSONUtilities

public protocol JSONEncodable {
    // returns JSONDictionary or JSONArray or JSONRawType or nil
    func toJSONValue() -> Any
}

extension JSONEncodable {
    func filterEmpty(value: [String: Any?]) -> [String: Any] {
        func filterOut(x: Any?) -> Any? {
            if let x = x as? [Any], x.isEmpty {
                return nil
            }
            if let x = x as? [AnyHashable: Any], x.isEmpty {
                return nil
            }
            return x
        }
        return value.compactMapValues(filterOut)
    }
}
