//
//  ResumeRealmService.swift
//  ResumeCreator
//
//  Created by Oleg Pustoshkin on 13.04.2022.
//

import RealmSwift

final class ResumeRealmService: ResumeServiceProtocol {
    enum Error: Swift.Error {
        case initializationError
        case storageError(underlyingError: Swift.Error)
    }

    private let realmConfiguration: Realm.Configuration
    private var realmInstance: Result<Realm, Swift.Error> {
        do {
            return .success(try Realm(configuration: realmConfiguration))
        } catch {
            assertionFailure("ResumeManager: failed to initialize realm instance: \(error)")
            return .failure(error)
        }
    }

    init(realmFileName: String) {
        realmConfiguration = Self.createRealmConfiguration(fileName: realmFileName)
    }

    func getResumeCount() -> Int {
        do {
            let instance = try self.realmInstance.get()
            let entities = instance.objects(ResumeEntity.self)
            return entities.count
        } catch {
            assertionFailure("ResumeManager: failed to instantiate realm instance: \(error)")
            return 0
        }
    }

    func getResume(index: Int) -> ResumeModel? {
        do {
            let instance = try self.realmInstance.get()
            let resumeEntity = instance.objects(ResumeEntity.self)
            return index < resumeEntity.count ? resumeEntity[index].model : nil
        } catch {
            assertionFailure("ResumeManager: failed to instantiate realm instance: \(error)")
            return nil
        }
    }

    func addResume(_ resume: ResumeModel) {
        do {
            let instance = try self.realmInstance.get()
            try instance.write {
                let entity = ResumeEntity()
                entity.update(from: resume)
                instance.add(entity, update: .modified)
            }
        } catch {
            assertionFailure("ResumeManager: failed to addResume: \(error)")
        }
    }

    func replaceResume(at index: Int, resume: ResumeModel) {
        do {
            let instance = try self.realmInstance.get()
            let resumeEntities = instance.objects(ResumeEntity.self)
            guard index < resumeEntities.count else { return }

            try instance.write{
                resumeEntities[index].update(from: resume)
            }
        } catch {
            assertionFailure("ResumeManager: failed to replaceResume: \(error)")
        }
    }

    func getResumeList() -> [ResumeModel] {
        do {
            let instance = try self.realmInstance.get()
            let resumeEntities = instance.objects(ResumeEntity.self)

            return resumeEntities.compactMap { resumeEntity in
                resumeEntity.model
            }
        } catch {
            assertionFailure("ResumeManager: failed to replaceResume: \(error)")
        }

        return []
    }

    func removeObject(_ resume: ResumeModel) {
        guard case let .existing(resumeID) = resume.id else { return }

        do {
            let instance = try self.realmInstance.get()
            if let resumeEntity = instance.objects(ResumeEntity.self).filter("id = %@", resumeID).first {
                try instance.write {
                    instance.delete(resumeEntity)
                }
            }
        } catch {
            assertionFailure("ResumeManager: failed to replaceResume: \(error)")
        }
    }
}

extension ResumeRealmService {
    static func createRealmConfiguration(fileName: String) -> Realm.Configuration {
        var config = Realm.Configuration(
            schemaVersion: 1,
            deleteRealmIfMigrationNeeded: true,
            objectTypes: [ResumeEntity.self, WorkInfoEntity.self, EducationDetailEntity.self, ProjectDetailEntity.self]
        )

        // Full url to real file
        let localRealmFilePath: URL?
        if let outputDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            localRealmFilePath = outputDir.appendingPathComponent(fileName)
        } else {
            localRealmFilePath = nil
        }

        config.fileURL = localRealmFilePath
        return config
    }
}
