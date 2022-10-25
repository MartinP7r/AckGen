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

    private let title: String

    public init(title: String = "Acknowledgements") {
        self.title = title
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
            .customNavigationTitle(acknowledgement.title)
    }
}
