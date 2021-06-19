//
//  ContentView.swift
//  CustomTextFieldApp
//
//  Created by Arie Peretz on 18/06/2021.
//

import SwiftUI

struct ContentView: View {
    @State var input: String = ""
    
    var body: some View {
        VStack(spacing: 20.0) {
            Text("Custom Text Field")
                .padding()
            CustomTextFieldComponent(input: $input)
                .fixedSize()
            Text("This is the input: \(input)")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
