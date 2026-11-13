//
//  Buttons.swift
//  firstProjectFromChatGpt
//
//  Created by Ярослав on 26.10.2026.
//

import SwiftUI

struct addTaskButton: View {
    
    @Binding var bufferName: String
    @Binding var exampleOfManager: managerArrayOfTasks
    @Binding var isPresented: Bool
    
    var bufferPriority: priorities
    var addressToSave: URL
    var bufferTerm: Date?
    @Binding var bufferHasTerm: Bool
    
    var body: some View {
        Button("Add") {
            if bufferName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {     // просто исследую строку
                return
            } else {
                if bufferHasTerm {
                    exampleOfManager.addTaskToArray(currentName: bufferName, currentPriority: bufferPriority, currentDate: bufferTerm)
                } else {
                    exampleOfManager.addTaskToArray(currentName: bufferName, currentPriority: bufferPriority, currentDate: nil)
                }
                bufferName = ""
                bufferHasTerm = false
                do {
                    let dataOfTasks = try makeDataOfTasks(wantedData: exampleOfManager)
                    try Assistant().saveJSON(whatWeSave: dataOfTasks, whereWeSave: addressToSave)
                } catch {
                    isPresented = true
                    switch error {
                    
                    case GetJSONResult.encodingError:
                        message = "encodingError"
                    
                    case GetJSONResult.saveError:
                        message = "saveError"
                    
                    default:
                        message = "another error"
                    }
                }
            }
        }
        .font(.headline)
        .padding(20)
        .foregroundColor(.white)
        .background(.blue)
        .clipShape(RoundedRectangle(cornerRadius: 12))  // обрезает результат по форме
        .alert("у нас ошибка при сохранении файла", isPresented: $isPresented) {
                    Button("OK") { }
        } message: {
                    Text(message)
        }
    }
}


var message = ""

struct SaveButton: View {
    @Binding var bufferName: String
    @Binding var bufferPriority: priorities
    
    @Binding var manager: managerArrayOfTasks
    @Binding var isPresented: Bool
    
    @Binding var addressToSave: URL
    var bufferDate: Date?
    
    let id: UUID
    
    var body: some View {
        Button("Save") {
            if bufferName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {     // просто исследую строку
                return
            } else {
                manager.changeParametersOfTask(idTaskToChangeParameters: id, newName: bufferName, newPriority: bufferPriority, newDate: bufferDate)
                do {
                    let dataOfTasks = try makeDataOfTasks(wantedData: manager)
                    try Assistant().saveJSON(whatWeSave: dataOfTasks, whereWeSave: addressToSave)
                } catch {
                    isPresented = true
                    
                    switch error {
                        case GetJSONResult.encodingError:
                            message = "encodingError"
                            
                        case GetJSONResult.saveError:
                            message = "saveError"
                            
                        default:
                            message = "another error"
                    }
                }
            }
        }
        .font(.headline)
        .padding(20)
        .foregroundColor(.white)
        .background(.gray)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .alert("у нас ошибка при сохранении файла", isPresented: $isPresented) {
                    Button("OK") { }
        } message: {
                    Text(message)
        }
    }
}


struct DoneButton: View {
    @Binding var manager: managerArrayOfTasks
    @Binding var isPresented: Bool
    @Binding var addressToSave: URL
    
    var exampleOfTask: task
    
    var body: some View {
        Button("Done") {
            manager.completitionMark(idTaskToBeFlagged: exampleOfTask.id)
            do {
                let dataOfTasks = try makeDataOfTasks(wantedData: manager)
                try Assistant().saveJSON(whatWeSave: dataOfTasks, whereWeSave: addressToSave)
            } catch {
                isPresented = true
                switch error {
                
                case GetJSONResult.encodingError:
                    message = "encodingError"
                
                case GetJSONResult.saveError:
                    message = "saveError"
                
                default:
                    message = "another error"
                }
            }
        }
        .font(.headline)
        .padding(20)
        .foregroundColor(.white)
        .background(.green)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .buttonStyle(.borderless)
        .alert("у нас ошибка при сохранении файла", isPresented: $isPresented) {
                    Button("OK") { }
        } message: {
                    Text(message)
        }
    }
}


struct DeleteButton: View {
    @Binding var manager: managerArrayOfTasks
    @Binding var isPresented: Bool
    @Binding var addressToSave: URL
    
    var exampleOfTask: task
    
    var body: some View {
        Button("Delete") {
            manager.deleteTaskFromArray(idOfOurTask: exampleOfTask.id)
            do {
                let dataOfTasks = try makeDataOfTasks(wantedData: manager)
                try Assistant().saveJSON(whatWeSave: dataOfTasks, whereWeSave: addressToSave)
            } catch {
                isPresented = true
                switch error {
                
                case GetJSONResult.encodingError:
                    message = "encodingError"
                
                case GetJSONResult.saveError:
                    message = "saveError"
                
                default:
                    message = "another error"
                }
            }
        }
        .font(.headline)
        .padding(20)
        .foregroundColor(.white)
        .background(.red)
        .buttonStyle(.borderless)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .alert("у нас ошибка при сохранении файла", isPresented: $isPresented) {
                    Button("OK") { }
        } message: {
                    Text(message)
        }
    }
}
