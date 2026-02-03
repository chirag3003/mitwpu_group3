//
//  DocDoctorService.swift
//  PHR_Project
//
//  Created by SDC-USER on 27/01/26.
//

import Foundation

class DocDoctorService {
    static let shared = DocDoctorService()

    private var doctors: [DocDoctor] = []

    private init() {
        fetchDoctorsFromAPI()
    }

    // MARK: - Public Methods

    func getDoctors() -> [DocDoctor] {
        return doctors
    }

    func fetchDoctorsFromAPI() {
        APIService.shared.request(endpoint: "/docDoctors", method: .get) {
            [weak self] (result: Result<[DocDoctor], Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let fetched):
                print("FETCHED", fetched)
                self.doctors = fetched
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("DoctorsUpdated"),
                        object: nil
                    )
                }
            case .failure(let error):
                print("Error fetching doctors: \(error)")
            }
        }
    }

    func createDoctor(name: String) {
        let newDoctor = DocDoctor(name: name)

        APIService.shared.request(
            endpoint: "/docDoctors",
            method: .post,
            body: newDoctor
        ) { [weak self] (result: Result<DocDoctor, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let createdDoctor):
                self.doctors.append(createdDoctor)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: NSNotification.Name("DoctorsUpdated"),
                        object: nil
                    )
                }
            case .failure(let error):
                print("Error creating doctor: \(error)")
            }
        }
    }

    func deleteDoctor(id: String) {
        // Optimistic delete
        doctors.removeAll { $0.apiID == id }
        NotificationCenter.default.post(
            name: NSNotification.Name("DoctorsUpdated"),
            object: nil
        )

        struct EmptyResponse: Decodable {}
        APIService.shared.request(
            endpoint: "/docDoctors/\(id)",
            method: .delete
        ) { (result: Result<EmptyResponse, Error>) in
            if case .failure(let error) = result {
                print("Error deleting doctor: \(error)")
            }
        }
    }
}
