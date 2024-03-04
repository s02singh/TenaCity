
//
//  CustomButton.swift
//  TenaCity
//
//  Created by Sahilbir Singh on 2/17/24.
//


import SwiftUI

struct CustomButton: View {
    var body: some View {
        Button(action: {}) {
            HStack {
                Spacer()
                Text("Login")
                    .foregroundColor(.white)
                Spacer()
            }
        }
        .padding()
        .background(.black)
        .cornerRadius(12)
        .padding()
    }
}

struct CustomButton_Previews: PreviewProvider {
    static var previews: some View {
        CustomButton()
    }
}
