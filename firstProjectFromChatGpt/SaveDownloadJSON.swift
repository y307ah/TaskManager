//
//  SaveDownloadJSON.swift
//  firstProjectFromChatGpt
//
//  Created by Ярослав on 11.10.2026.
//


//do-catch - че то сделай если что выкинь ошибку которая описывает именно то что ты попытался сделать

import Foundation

let manager = FileManager.default

var endProgram: Bool = false

enum GetJSONResult: Error {
    case fileNotFound
    case emptyInputForURL
    case emptyDataForSave

    case folderError(Error)             // хранит дополнительную информацию - исходную ошибку (значение Error будет тоже учит) - сможем потом разобрать эту доп инфу
    case encodingError(Error)
    case saveError(Error)
    case loadError(Error)
    case decodingError(Error)
}

func makeDataOfTasks(wantedData: managerArrayOfTasks) throws -> Data {
    // encode нужны конкретные данные экземпляра, чтобы записать их в JSON (тип передавать мы не можем)
    
    let bytes: Data
    do {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601                         // представляем Date в формате строки iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]        // 1ое - для переноса строк и отступов , 2ое - упорядоч ключи обьектов лексикографически
        
        bytes = try encoder.encode(wantedData)
    } catch {
        throw GetJSONResult.encodingError(error)
    }
    
    if bytes.isEmpty {
        throw GetJSONResult.emptyDataForSave
    }
    
    return bytes
}


struct Assistant {
    func createStorageFolder() throws -> URL {                  // убрали дохуя говна в начале теперь эта функция делает все сама и возвращает адрес SavedData
        var folder: URL
        do {
            let documents = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            // нужна системная папка Documents
            // ищем её в области текущего пользователя
            // доп адрес для поиска тут не нужен - nil
            // даем разрешение на создание запрашиваемой папки
            
            folder = documents.appendingPathComponent("Saved Data", isDirectory: true)
            try manager.createDirectory(at: folder, withIntermediateDirectories: true)
            
        } catch {
            throw GetJSONResult.folderError(error)
        }
        return folder
    }
    
    
    func saveJSON(whatWeSave: Data, whereWeSave: URL) throws {
        if whatWeSave.isEmpty {
            throw GetJSONResult.emptyDataForSave
        }

        do {
            try whatWeSave.write(to: whereWeSave, options: .atomic)
        } catch {
            throw GetJSONResult.saveError(error)
        }
    }

    
    func loadJSON(whereWeGet: URL) throws -> managerArrayOfTasks {
        let data: Data

        do {
            data = try Data(contentsOf: whereWeGet)                                     // пытаемся грузануть дату
        } catch let error as CocoaError where error.code == .fileReadNoSuchFile {       // если файла пока нет(код ошибки говорит об этом) - то пуст м создаем
            let newManager = managerArrayOfTasks(array: [])
            return newManager
        } catch {
            throw GetJSONResult.loadError(error)                                        // возвращаем ошибку которая может еще и передать тип
        }

        if data.isEmpty {
            throw GetJSONResult.emptyInputForURL
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(managerArrayOfTasks.self, from: data)
        } catch {
            throw GetJSONResult.decodingError(error)
        }
    }
}
