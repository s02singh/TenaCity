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
    var top_space: CGFloat = 30
    var bottom_space: CGFloat = 0
    
    var body: some View {
            VStack {
                HStack {
                    Spacer()
                    Button {
                        //link to view
                    } label: {
                        Spacer()
                        Image(systemName: "storefront")
//                            .resizable()
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: top_space, leading: left_space, bottom: bottom_space, trailing: right_space))
                    }
                    Spacer()
                    Button {
                        //link to view
                    } label: {
                        Image(systemName: "person.2")
//                            .resizable()
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: top_space, leading: left_space, bottom: bottom_space, trailing: right_space))
                    }
                    Spacer()
                    Button {
                        //link to view
                    } label: {
                        Image(systemName: "building.2")
//                            .resizable()
                            .foregroundColor(.white)
                            .padding(EdgeInsets(top: top_space, leading: left_space, bottom: bottom_space, trailing: right_space))
                    }
                    Spacer()
                    Button {
                        //link to view
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
            .frame(width: .infinity, height: 50, alignment: .bottom)
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar()
    }
}
