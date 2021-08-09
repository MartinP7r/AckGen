//
//  AcknowledgementsList.swift
//  AckGen
//
//  Created by Martin Pfundmair on 2021-08-09.
//

import AckGen
import SwiftUI

public struct AcknowledgementsList: View {
    typealias Acknowledgement = AckGen.Acknowledgement

    private let plistName: String

    public init(plistName: String = "Acknowledgements") {
        self.plistName = plistName
    }

    @State private var acknowledgements: [Acknowledgement] = []

    public var body: some View {
        List(acknowledgements, id: \.title) { ack in
            NavigationLink(destination: ScrollView { Text(ack.license).padding() },
                           label: { Text(ack.title) })
        }
        .onAppear {
            self.acknowledgements = Acknowledgement.all()
        }
    }
}
