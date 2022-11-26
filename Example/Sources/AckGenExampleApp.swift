//
//  AckGenExampleApp.swift
//  AckGenExample
//
//  Created by Martin Pfundmair on 2022-11-26.
//

import AckGenUI
import SwiftUI

@main
struct AckGenExampleApp: App {

    var body: some Scene {
        WindowGroup {
            NavigationView {
                AcknowledgementsList()
            }
        }
    }
}
