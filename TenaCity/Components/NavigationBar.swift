//
//  NavigationBar.swift
//  TenaCity
//
//  Created by Divya Raj on 2/26/24.
//

import SwiftUI

struct NavigationBar: View {
    var left_space: CGFloat = 20
    var right_space: CGFloat = 20
    var top_space: CGFloat = 15
    var bottom_space: CGFloat = 15
    
    @State var store: Bool = false
    @State var friends: Bool = false
    @State var buildings: Bool = false
    @State var settings: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    store = true
                } label: {
                    Image(systemName: "storefront")
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: top_space, leading: left_space, bottom: bottom_space, trailing: right_space))
                }
                Spacer()
                Button {
                    friends = true
                } label: {
                    Image(systemName: "person.2")
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: top_space, leading: left_space, bottom: bottom_space, trailing: right_space))
                }
                Spacer()
                Button {
                    buildings = true
                } label: {
                    Image(systemName: "building.2")
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: top_space, leading: left_space, bottom: bottom_space, trailing: right_space))
                }
                Spacer()
                Button {
                    settings = true
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: top_space, leading: left_space, bottom: bottom_space, trailing: right_space))
                }
                Spacer()
            }
            .background(Color("SageGreen"))
            .frame(maxHeight: 70, alignment: .center)
            .onChange(of: store) {
                print("store view")
            }
            .navigationDestination(isPresented: $friends) {
                FriendsView()//.environmentObject(authManager)
            }
            .onChange(of: buildings) {
                print("buildings view")
            }
            .onChange(of: settings) {
                print("Settings view")
            }
        }
        .frame(maxHeight: 50, alignment: .center)
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar()
    }
}
