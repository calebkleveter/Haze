// The MIT License (MIT)
//
// Copyright (c) 2017 Caleb Kleveter
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import Console
import Command
import Helpers
import Core
import Bits

public class Configuration: Command {
    public static let configPath = "/Library/Application\\ Support/Ether/config.json"
    
    public var arguments: [CommandArgument] = [
        CommandArgument.argument(name: "key", help: ["The configuration JSON key to set"]),
        CommandArgument.argument(name: "value", help: ["The new value for the key passed in"])
    ]
    
    public var options: [CommandOption] = []
    
    public var help: [String] = ["Configure custom actions to occure when a command is run"]
    
    public init() {}
    
    public func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        let setter = context.console.loadingBar(title: "Setting Configuration Key")
        _ = setter.start(on: context.container)
        
        let key = try context.argument("key")
        let value = try context.argument("value")
        let user = try Process.execute("whoami")
        
        var configuration = try Configuration.get()
        
        guard let property = Config.properties[key] else {
            throw EtherError(identifier: "noSettingWithName", reason: "No configuration setting found with name '\(key)'")
        }
        
        configuration[keyPath: property] = value
        
        try JSONEncoder().encode(configuration).write(to: URL(string: "file:/Users/\(user)/Library/Application%20Support/Ether/config.json")!)
        
        setter.succeed()
        return context.container.eventLoop.newSucceededFuture(result: ())
    }
    
    public static func get()throws -> Config {
        let user = try Process.execute("whoami")
        let url = "file:/Users/\(user)\(configPath)"
        
        let configuration = FileManager.default.contents(atPath: url) ?? Data([.leftCurlyBracket, .rightCurlyBracket])
        return try JSONDecoder().decode(Config.self, from: configuration)
    }
}

public struct Config: Codable, Reflectable {
    public var accessToken: String?
    
    static let properties: [String: WritableKeyPath<Config, String?>] = [
        "access-token": \.accessToken
    ]
}
