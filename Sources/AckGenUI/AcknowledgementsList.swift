//
//  AcknowledgementsList.swift
//  AckGen
//
//  Created by Martin Pfundmair on 2021-08-09.
//

import AckGenCore
import SwiftUI

public struct AcknowledgementsList: View {
    typealias Acknowledgement = AckGenCore.Acknowledgement

    private let title: String
    private let plistName: String
    private let bundle: Bundle
    private let otherAcknowledgements: [Acknowledgement]

    public init(
        title: String = "Acknowledgements",
        plistName: String = "Acknowledgements",
        bundle: Bundle = .main,
        otherAcknowledgements: [AckGenCore.Acknowledgement] = []
    ) {
        self.title = title
        self.plistName = plistName
        self.bundle = bundle
        self.otherAcknowledgements = otherAcknowledgements
    }

    @State private var acknowledgements: [Acknowledgement] = []

    public var body: some View {
        List(acknowledgements, id: \.title) { ack in
            NavigationLink(destination: AcknowledgementDetailsView(acknowledgement: ack)) {
                Text(ack.title)
            }
        }
        .customNavigationTitle(title)
        .onAppear {
            self.acknowledgements = (Acknowledgement.all(fromPlist: plistName, in: bundle) + otherAcknowledgements).sorted()
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
        .customNavigationTitle(acknowledgement.title)
    }
}
