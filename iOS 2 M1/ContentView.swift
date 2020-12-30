//
//  ContentView.swift
//  iOS 2 M1
//
//  Created by ipodtouchdude on 29/12/2020.
//

import SwiftUI



struct ContentView: View {
    @State private var appString = ""
    @State private var dirString = ""
    @State private var nameString = ""
    @State private var showingAlert = false
    @State private var completedAlert = false
    var body: some View {
        VStack {
            Spacer()
                .frame(width: 600.0, height: 10.0)
            HStack {
                Spacer()
                Text("iOS .app: ")
                Spacer()
                    .frame(width: 17.0)
                TextField("Path to signed iOS .app", text: $appString).disabled(true)
                Button("Choose") {
                    let openPanel = NSOpenPanel()
                    openPanel.prompt = "Select File"
                    openPanel.allowsMultipleSelection = false
                    openPanel.canChooseDirectories = false
                    openPanel.canCreateDirectories = false
                    openPanel.canChooseFiles = true
                    openPanel.allowedFileTypes = ["app"]
                    openPanel.begin { (result) -> Void in
                        if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                            let selectedPath = openPanel.url!.path
                            appString = selectedPath
                        }
                    }
                }
                Spacer()
            }
            HStack {
                Spacer()
                Text("Destination:")
                Spacer()
                    .frame(width: 3.0)
                TextField("Save where the converted app located", text: $dirString).disabled(true)
                Button("Choose") {
                    let openPanel = NSOpenPanel()
                    openPanel.prompt = "Save"
                    openPanel.allowsMultipleSelection = false
                    openPanel.canChooseDirectories = true
                    openPanel.canCreateDirectories = false
                    openPanel.canChooseFiles = false
                    openPanel.begin { (result) -> Void in
                        if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                            let selectedPath = openPanel.url!.path
                            dirString = selectedPath
                        }
                    }
                }
                Spacer()
            }
            HStack {
                Spacer()
                Text("App Name:")
                Spacer()
                    .frame(width: 8.0)
                TextField("Name of the converted app", text: $nameString)
                Spacer()
                    .frame(width: 79.0)
            }
            Button("Create") {
                if appString == "" || dirString == "" || nameString == "" {
                    self.showingAlert = true
                    self.completedAlert = false
                }
                else {
                    let docURL = URL(string: dirString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
                    let appPath = docURL.appendingPathComponent("\(nameString).app")
                    let wrapperPath = appPath.appendingPathComponent("Wrapper")
                    let appCopy = URL(string: appString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
                    if !FileManager.default.fileExists(atPath: appPath.absoluteString) {
                        do {
                            try FileManager.default.createDirectory(atPath: wrapperPath.absoluteString.removingPercentEncoding!, withIntermediateDirectories: true, attributes: nil)
                        } catch {
                            print(error.localizedDescription);
                        }
                        do {
                            try FileManager.default.copyItem(atPath: appCopy.path, toPath: String("\(wrapperPath)/\(appCopy.lastPathComponent)").removingPercentEncoding!)
                        } catch {
                            print(error.localizedDescription);
                        }
                        do {
                            try FileManager.default.createSymbolicLink(atPath: String("\(appPath)/WrappedBundle").removingPercentEncoding!, withDestinationPath: String("Wrapper/\(appCopy.lastPathComponent)"))
                        } catch {
                            print(error.localizedDescription);
                        }
                        self.showingAlert = true
                        self.completedAlert = true
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                if completedAlert == true {
                    return Alert(title: Text("Completed!"), message: Text("You can now open your app at:\n \(dirString)/\(nameString).app\n\nPlease note that the app may show the prohibited symbol over app icon. This will be removed once macOS updates the directory.\n\nIf the app fails to open, please make sure it is signed correctly and some apps may not even work due to macOS limitation and would need the developer to update the app."), dismissButton: .default(Text("OK")))
                    
                }
                else {
                    return Alert(title: Text("Warning!"), message: Text("Make sure all text boxes are filled!"), dismissButton: .default(Text("OK")))
                }
            }
            Spacer()
                .frame(width: 600.0, height: 9.0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
