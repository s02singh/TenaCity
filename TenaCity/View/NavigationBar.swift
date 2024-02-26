//
//  NavigationBar.swift
//  TenaCity
//
//  Created by Divya Raj on 2/26/24.
//

import SwiftUI

struct NavigationBar: View {
    var body: some View {
        VStack {
            HStack {
                Button {
                    //link to view
                } label: {
                    Text("􁽇")
                }
                
                Button {
                    //link to view
                } label: {
                    Text("􀉫")
                }
                
                Button {
                    //link to view
                } label: {
                    Image("􀝒")
                }
                
                Button {
                    //link to view
                } label: {
                    Image("􀣌")
                }
            }
        }
    }
}

#Preview {
    NavigationBar()
}
