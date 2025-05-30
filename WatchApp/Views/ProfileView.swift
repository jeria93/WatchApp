//
//  ProfileView.swift
//  WatchApp
//
//  Created by Frida Eriksson on 2025-05-27.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var showEditEmail = false
    @State private var showEditUsername = false
    @State private var showDeleteAccount = false
    
    var body: some View {
        ZStack{
            Color.BG
                .ignoresSafeArea(.all)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 10){
                    HStack(alignment: .center, spacing: 10) {
                        Text(authVM.currentUsername ?? "🤷")
                            .foregroundStyle(.white)
                            .fontDesign(.rounded)
                            .font(.title)
                            .fontWeight(.bold)
                            .padding(.top, 85)
                        
                        Spacer()
                        
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "photo.circle.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .background{
                                    Circle()
                                        .fill(Color(.systemGray6))
                                        .frame(width: 128, height: 128)
                                        .shadow(radius: 10)
                                }
                            
                            Image(systemName: "pencil")
                                .imageScale(.small)
                                .foregroundStyle(.red)
                                .background{
                                    Circle()
                                        .fill(.white)
                                        .frame(width: 32, height: 32)
                                }
                                .offset(x: -8, y: 10)
                        }
                    }
                    .padding(.horizontal, 35)
                    .padding(.bottom, 20)
                    .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Button(action: {
                            showEditUsername = true
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "person")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal)
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Username")
                                        .foregroundStyle(.white)
                                        .fontWeight(.semibold)
                                    Text(authVM.currentUsername ?? "No user")
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.primary)
                            .cornerRadius(10)
                        }
                        
                        Button(action: {
                            showEditEmail = true
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "envelope")
                                    .resizable()
                                    .frame(width: 40, height: 30)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal)
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Email")
                                        .foregroundStyle(.white)
                                        .fontWeight(.semibold)
                                    Text(authVM.user?.email ?? "No user")
                                        .foregroundStyle(.white)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.primary)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    
                    ZStack {
                        Image("popbox_white")
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity, maxHeight: 500)
                            .opacity(0.8)
                        
                        VStack{
                            Text("Your Top 5")
                                .foregroundStyle(.popcornYellow)
                                .font(.title2)
                                .fontWeight(.bold)
                                .fontDesign(.rounded)
                                .padding(.top)
                            
                            
                            //Byt ut mot lista med personliga top 5 highest rated
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundStyle(.gray)
                                
                            
                            HStack {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundStyle(.gray)
                                    
                                
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundStyle(.gray)
                            }
                            .padding()
                            
                            HStack {
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundStyle(.gray)
                                
                                Image(systemName: "photo")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .foregroundStyle(.gray)
                            }
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity)
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            showDeleteAccount = true
                        }) {
                            HStack{
                                Image(systemName: "trash")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(.red)
                                Text("Delete Account")
                                    .foregroundStyle(.red)
                            }
                            .padding()
                        }
                        Spacer()
                    }
                }
                .ignoresSafeArea(.all, edges: .top)
                .padding(.top, 44)
            }
            
            if showEditEmail {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showEditEmail = false
                        }
                    }
                
                EditEmailView(
                    newEmail: authVM.user?.email ?? "",
                    showModal: $showEditEmail
                )
                .environmentObject(authVM)
                .transition(.scale)
            }
            
            if showEditUsername {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showEditUsername = false
                        }
                    }
                
                EditUsernameView(
                    username: Binding(get: {authVM.currentUsername}, set: { authVM.currentUsername = $0}),
                    showModal: $showEditUsername
                )
                .environmentObject(authVM)
                .transition(.scale)
            }
            if showDeleteAccount {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            showDeleteAccount = false
                        }
                    }
                
                DeleteAccountView(showModal: $showDeleteAccount)
                    .environmentObject(authVM)
                    .transition(.scale)
            }
        }
    }

    
    struct EditUsernameView: View {
        @Binding var username: String?
        @EnvironmentObject var authVM: AuthViewModel
        @Binding var showModal: Bool
        
        var body: some View {
            VStack(spacing: 20){
                Text("Edit Username")
                    .font(.title2)
                    .foregroundStyle(.popcornYellow)
                    .fontWeight(.bold)
                
                Divider()
                
                TextField("Username", text: Binding(get: { username ?? "" },
                                                    set: { username = $0.isEmpty ? nil : $0}))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .foregroundStyle(.black)
            
                HStack{
                    Button("Cancel") {
                        withAnimation{
                            showModal = false
                        }
                    }
                    Button("Save") {
                        authVM.updateUsername(newUsername: username ?? "") { success in
                            if success {
                                withAnimation{
                                    showModal = false
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .background(.BG)
                    .foregroundStyle(.popcornYellow)
                    .cornerRadius(20)
                    .fontWeight(.semibold)
        
                }
            }
            .frame(height: 300)
            .background(.black)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
        }
    }
    
    struct EditEmailView: View {
        @State var newEmail: String
        @EnvironmentObject var authVM: AuthViewModel
        @Binding var showModal: Bool
    
        var body: some View {
            
            VStack(spacing: 20){
                Text("Edit Email")
                    .font(.title2)
                    .foregroundStyle(.popcornYellow)
                    .fontWeight(.bold)
                
                TextField("Email", text: $newEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                
                if let successMessage = authVM.successMessage {
                    Text(successMessage)
                        .foregroundStyle(.green)
                        .padding()
                }
                
                if let errorMessage = authVM.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .padding()
                }
                
                HStack{
                    Button("Cancel") {
                        withAnimation{
                            showModal = false
                        }
                    }
                    
                    Button("Save") {
                        authVM.updateEmail(newEmail: newEmail) { success in
                            if success {
                            }
                        }
                    }
                    .padding(.horizontal)
                    .background(.BG)
                    .foregroundStyle(.popcornYellow)
                    .cornerRadius(20)
                    .fontWeight(.semibold)
                }
            }
            .frame(height: 300)
            .background(.black)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
        }
    }
    
    struct DeleteAccountView: View {
        @EnvironmentObject var authVM: AuthViewModel
        @Binding var showModal: Bool
        @State private var email: String = ""
        @State private var password: String = ""
        @State private var showReauthentication: Bool = false
        
        var body: some View {
            VStack(spacing: 20){
                Text("Delete Account")
                    .font(.title2)
                    .foregroundStyle(.popcornYellow)
                    .fontWeight(.bold)
                
                if showReauthentication {
                    Text("Confirm your userlogin to confirm account deletion.")
                        .foregroundStyle(.red)
                        .padding()
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                        .textContentType(.password)
                } else{
                    Text("Are you sure you want to delete your account? This action cannot be undone.")
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                if let successMessage = authVM.successMessage {
                    Text(successMessage)
                        .foregroundStyle(.green)
                        .padding()
                }
                
                if let errorMessage = authVM.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .padding()
                }
                
                HStack{
                    Button("Cancel") {
                        withAnimation{
                            showModal = false
                        }
                    }
                    .padding(.horizontal)
                    .background(.BG)
                    .foregroundStyle(.popcornYellow)
                    .cornerRadius(20)
                    .fontWeight(.semibold)
                    
                    Button("Delete") {
                        if showReauthentication {
                            authVM.deleteAccount(email: email, password: password) { success in
                                if success {
                                    withAnimation{
                                        showModal = false
                                    }
                                }
                            }
                        }else {
                            authVM.deleteAccount { success in
                                if !success, authVM.errorMessage?.contains("Login again") ?? false {
                                    showReauthentication = true
                                } else if success {
                                    withAnimation {
                                        showModal = false
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .foregroundStyle(.red)
                    .fontWeight(.bold)
                }
            }
            .frame(height: 300)
            .background(.black)
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding()
        }
    }
}



#Preview {
    ProfileView()
        .environmentObject(AuthViewModel())
}
