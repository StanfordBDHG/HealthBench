//
// This source file is part of the StanfordBDHG Template Application project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct MainView: View {
    var body: some View {
        VStack {
            Image(systemName: "hand.wave.fill")
                .accessibilityLabel(Text("Hand waving"))
                .font(.system(size: 100))
                .foregroundColor(.accentColor)
                .padding()
            Text("Welcome to the Template Application!")
                .bold()
        }
    }
}


#if swift(>=5.9)
#Preview {
    MainView()
}
#endif
