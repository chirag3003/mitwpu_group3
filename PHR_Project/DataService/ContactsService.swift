import Contacts
import Foundation

class ContactsService {
    static let shared = ContactsService()

    private let contactStore = CNContactStore()
    private var contacts: [Contact] = []

    private init() {}

    // MARK: - Permission Handling

    func requestAccess(completion: @escaping (Bool) -> Void) {
        let status = CNContactStore.authorizationStatus(for: .contacts)

        switch status {
        case .authorized:
            completion(true)
        case .notDetermined:
            contactStore.requestAccess(for: .contacts) { granted, _ in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .denied, .restricted:
            completion(false)
        case .limited:
            completion(true)
        @unknown default:
            completion(false)
        }
    }

    // MARK: - Fetch Contacts

    func fetchContacts(completion: @escaping ([Contact]) -> Void) {
        requestAccess { [weak self] granted in
            guard granted else {
                completion([])
                return
            }

            self?.loadContactsFromDevice(completion: completion)
        }
    }

    private func loadContactsFromDevice(
        completion: @escaping ([Contact]) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            var deviceContacts: [Contact] = []

            let keysToFetch: [CNKeyDescriptor] = [
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactPhoneNumbersKey as CNKeyDescriptor,
                CNContactThumbnailImageDataKey as CNKeyDescriptor,
            ]

            let request = CNContactFetchRequest(keysToFetch: keysToFetch)
            request.sortOrder = .givenName

            do {
                try self?.contactStore.enumerateContacts(with: request) {
                    cnContact,
                    _ in
                    let name = "\(cnContact.givenName) \(cnContact.familyName)"
                        .trimmingCharacters(in: .whitespaces)
                    let phoneNumber =
                        cnContact.phoneNumbers.first?.value.stringValue ?? ""

                    // Skip contacts without name or phone
                    guard !name.isEmpty, !phoneNumber.isEmpty else { return }

                    let contact = Contact(
                        name: name,
                        image: nil,
                        phoneNum: phoneNumber,
                        imageData: cnContact.thumbnailImageData
                    )
                    deviceContacts.append(contact)
                }

                self?.contacts = deviceContacts

                DispatchQueue.main.async {
                    completion(deviceContacts)
                }
            } catch {
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }
    }

    // MARK: - Cached Contacts

    func getCachedContacts() -> [Contact] {
        return contacts
    }

    // MARK: - Search

    func searchContacts(query: String) -> [Contact] {
        guard !query.isEmpty else { return contacts }

        return contacts.filter { contact in
            contact.name.lowercased().contains(query.lowercased())
                || contact.phoneNum.contains(query)
        }
    }
}
