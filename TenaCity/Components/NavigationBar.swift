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
    var bottom_space: CGFloat = 0
    
    @State var store: Bool = false
    @State var friends: Bool = false
    @State var buildings: Bool = false
    @State var settings: Bool = false
    @State var group: Bool = false
    
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        VStack {
            HStack {
         
                
                Spacer()
                Button {
                    friends = true
                } label: {
                    Image(systemName: "person.2")
                    //                            .resizable()
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: top_space, leading: left_space, bottom: bottom_space, trailing: right_space))
                }
                Spacer()
                Button {
                    buildings = true
                } label: {
                    Image(systemName: "building.2")
                    //                            .resizable()
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: top_space, leading: left_space, bottom: bottom_space, trailing: right_space))
                }
                Spacer()
                Button {
                    group = true
                } label: {
                    Image(systemName: "person.3")
                    //                            .resizable()
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: top_space, leading: left_space, bottom: bottom_space, trailing: right_space))
                }
                Spacer()
                Button {
                    settings = true
                } label: {
                    Image(systemName: "gearshape")
                    //                            .resizable()
                        .foregroundColor(.white)
                        .padding(EdgeInsets(top: top_space, leading: left_space, bottom: bottom_space, trailing: right_space))
                }
                Spacer()
            }
            .background(Color("SageGreen"))
        }
        .frame(maxHeight: 60, alignment: .bottom)
        //            .navigationDestination(isPresented: store, destination: {
        //                  StoreView()
        //              })
            .navigationDestination(isPresented: $friends, destination: {
                FriendsView()
            })
            .navigationDestination(isPresented: $buildings, destination: {
                BuildingView()
            })
            .navigationDestination(isPresented: $group, destination: {
                GroupHabitView()
            })
            .navigationDestination(isPresented: $settings, destination: {
                          SettingsView()
                      })
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar()
    }
}
