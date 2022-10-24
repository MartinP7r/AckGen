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
    private let title: String

    public init(
        plistName: String = "Acknowledgements",
        title: String = "Acknowledgements"
    ) {
        self.plistName = plistName
        self.title = title
    }

    @State private var acknowledgements: [Acknowledgement] = []

    public var body: some View {
        List(acknowledgements, id: \.title) { ack in
            NavigationLink(destination: AcknowledgementDetailsView(acknowledgement: ack)) {
                Text(ack.title)
            }
        }
            .navigationTitle(title)
            .onAppear {
                self.acknowledgements = Acknowledgement.all()
            }
    }
}

public struct AcknowledgementDetailsView: View {

    let acknowledgement: Acknowledgement

    public var body: some View {
        ScrollView {
            Text(acknowledgement.license)
                .padding()
        }
            .navigationTitle(acknowledgement.title)
    }
}
