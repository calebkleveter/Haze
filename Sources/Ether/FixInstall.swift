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

import Command

public final class FixInstall: Command {
    public var arguments: [CommandArgument] = []
    public var options: [CommandOption] = []
    
    public var help: [String] = ["Fixes fetching errors that occur during package install"]
    
    public init() {}
    
    public func run(using context: CommandContext) throws -> EventLoopFuture<Void> {
        context.console.output("This may take some time...", style: .info)
        
        let fixing = context.console.loadingBar(title: "Fixing Instillation")
        _ = fixing.start(on: context.container)
        
        _ = try Process.execute("rm", ["-rf", ".build"])
        _ = try Process.execute("swift", ["package", "update"])
        _ = try Process.execute("swift", ["package", "resolve"])
        
        fixing.succeed()
        
        return context.container.future()
    }
}
