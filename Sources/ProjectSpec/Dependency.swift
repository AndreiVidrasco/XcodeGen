import Foundation
import JSONUtilities

public struct Dependency: Equatable {

    public var type: DependencyType
    public var reference: String
    public var embed: Bool?
    public var codeSign: Bool?
    public var removeHeaders: Bool = true
    public var link: Bool?
    public var implicit: Bool = false
    public var weakLink: Bool = false

    public init(
        type: DependencyType,
        reference: String,
        embed: Bool? = nil,
        codeSign: Bool? = nil,
        link: Bool? = nil,
        implicit: Bool = false,
        weakLink: Bool = false
    ) {
        self.type = type
        self.reference = reference
        self.embed = embed
        self.codeSign = codeSign
        self.link = link
        self.implicit = implicit
        self.weakLink = weakLink
    }

    public enum DependencyType: Equatable {
        case target
        case framework
        case carthage(findFrameworks: Bool?)
        case sdk
    }
}

extension Dependency: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(reference)
    }
}

extension Dependency: JSONObjectConvertible {

    public init(jsonDictionary: JSONDictionary) throws {
        if let target: String = jsonDictionary.json(atKeyPath: "target") {
            type = .target
            reference = target
        } else if let framework: String = jsonDictionary.json(atKeyPath: "framework") {
            type = .framework
            reference = framework
        } else if let carthage: String = jsonDictionary.json(atKeyPath: "carthage") {
            let findFrameworks: Bool? = jsonDictionary.json(atKeyPath: "findFrameworks")
            type = .carthage(findFrameworks: findFrameworks)
            reference = carthage
        } else if let sdk: String = jsonDictionary.json(atKeyPath: "sdk") {
            type = .sdk
            reference = sdk
        } else {
            throw SpecParsingError.invalidDependency(jsonDictionary)
        }

        embed = jsonDictionary.json(atKeyPath: "embed")
        codeSign = jsonDictionary.json(atKeyPath: "codeSign")
        link = jsonDictionary.json(atKeyPath: "link")

        if let bool: Bool = jsonDictionary.json(atKeyPath: "removeHeaders") {
            removeHeaders = bool
        }
        if let bool: Bool = jsonDictionary.json(atKeyPath: "implicit") {
            implicit = bool
        }
        if let bool: Bool = jsonDictionary.json(atKeyPath: "weak") {
            weakLink = bool
        }
    }
}

extension Dependency: JSONDictionaryEncodable {
    public func toJSONDictionary() -> JSONDictionary {
        var dict: JSONDictionary = [:]

        if !removeHeaders {
            dict["removeHeaders"] = removeHeaders
        }
        if implicit {
            dict["implicit"] = implicit
        }
        if weakLink {
            dict["weak"] = weakLink
        }
        if let embed = embed {
            dict["embed"] = embed
        }
        if let codeSign = codeSign {
            dict["codeSign"] = codeSign
        }
        if let link = link {
            dict["link"] = link
        }

        switch type {
        case .target:
            dict["target"] = reference
        case .framework:
            dict["framework"] = reference
        case .carthage(let findFrameworks):
            dict["carthage"] = reference
            if let findFrameworks = findFrameworks {
                dict["findFrameworks"] = findFrameworks
            }
        case .sdk:
            dict["sdk"] = reference
        }

        return dict
    }
}

extension Dependency: PathContainer {

    static var pathProperties: [PathProperty] {
        return [
            .string("framework"),
        ]
    }
}
