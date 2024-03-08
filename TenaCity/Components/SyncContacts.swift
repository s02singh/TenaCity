//
//  SyncContacts.swift
//  TenaCity
//
//  Created by Sonali Bhattacharjee on 3/7/24.
//

import SwiftUI
import Contacts

class SyncContacts {
    let firestoreManager: FirestoreManager
    
    init(firestoreManager: FirestoreManager) {
        self.firestoreManager = firestoreManager
    }
    
    func sync() {
        requestContactsPermission()
    }
    
    private func requestContactsPermission() {
        CNContactStore().requestAccess(for: .contacts) { [weak self] granted, error in
            if granted {
                self?.fetchContacts()
            }
        }
    }
    
    private func fetchContacts() {
        let contactStore = CNContactStore()
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        
        do {
            try contactStore.enumerateContacts(with: request) { [weak self] contact, _ in
                self?.compareContactsWithAppUsers(contact: contact)
            }
        } catch {
            print("error fetching contacts")
        }
    }
    
    private func compareContactsWithAppUsers(contact: CNContact) {
        let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
        firestoreManager.checkUserExistence(phoneNumber: phoneNumber) { [weak self] exists in
            if exists {
                self?.showContactSuggestion(contact: contact)
            }
        }
    }
    
    private func showContactSuggestion(contact: CNContact) {
        let fullName = CNContactFormatter.string(from: contact, style: .fullName) ?? ""
        print("Contact suggestion \(fullName)")
    }
    
    func inviteContact(contact: CNContact) {
        let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
        print("Inviting contact with phone number: \(phoneNumber)")
    }
}

//#Preview {
//    SyncContacts()
//}
