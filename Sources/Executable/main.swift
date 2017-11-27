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
import Ether
import Helpers
import libc

// The current version of Ether. This string should be updated with each release.
let version = "1.9.1"
var arguments = CommandLine.arguments
let terminal = Terminal(arguments: arguments)
var iterator = arguments.makeIterator()

guard let executable = iterator.next() else {
    throw ConsoleError.noExecutable
}

if arguments.count == 2, arguments[1] == "--version" || arguments[1] == "-v" {
    terminal.output("Ether Version: \(version)", style: .info, newLine: true)
    exit(0)
}

let date = Date()
let formatter = DateFormatter()
formatter.dateFormat = "YYYY"
let currentYear = formatter.string(from: date)

do {
    try terminal.run(executable: executable, commands: [
        Search(console: terminal),
        Install(console: terminal),
        Update(console: terminal),
        Remove(console: terminal),
        Template(console: terminal),
        New(console: terminal),
        FixInstall(console: terminal),
        Group(id: "version", commands: [
            VersionLatest(console: terminal),
            VersionAll(console: terminal)
        ], help: ["For interacting with dependency versions"]),
        CleanManifest(console: terminal)
    ], arguments: Array(iterator),
    help: [
        "MIT \(currentYear) Caleb Kleveter.",
        "If you are getting errors, open an issue on GitHub.",
        "If you want to help, submit a PR."
    ])
} catch ConsoleError.insufficientArguments {
    terminal.error("Error: ", newLine: false)
    terminal.print("Insufficient arguments.")
} catch ConsoleError.help {
    exit(0)
} catch ConsoleError.cancelled {
    print("Cancelled")
    exit(2)
} catch ConsoleError.noCommand {
    terminal.error("Error: ", newLine: false)
    terminal.print("No command supplied.")
} catch let ConsoleError.commandNotFound(id) {
    terminal.error("Error: ", newLine: false)
    terminal.print("Command \"\(id)\" not found.")
} catch let EtherError.fail(message) {
    let err = "Error: "
    var output = message.split(separator: "\n").map({ return String(repeating: " ", count: err.count) + $0 })
    output[0] = output[0].trim()
    
    terminal.error("Error: ", newLine: false)
    terminal.print(output.joined(separator: "\n"))
    exit(1)
} catch {
    terminal.error("Error: ", newLine: false)
    terminal.print("\(error)")
    exit(1)
}
