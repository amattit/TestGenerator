//
//  ContentView.swift
//  TestGenerator
//
//  Created by Серегин Михаил Андреевич on 06.10.2023.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: TestGenerationViewModel
    
    var body: some View {
        HSplitView {
            VStack {
                TextEditor(text: $viewModel.text)
            }
            ScrollView {
                HStack {
                    Text(viewModel.getSuccessTestTemplate())
                        .textSelection(.enabled)
                    Spacer()
                }
                HStack {
                Text(viewModel.getFailureTestTemplate())
                    .textSelection(.enabled)
                    Spacer()
                }
            }
            .frame(minWidth: 600)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init())
    }
}
