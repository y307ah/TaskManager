//
//  ContentView.swift
//  firstProjectFromChatGpt
//
//  Created by Ярослав on 23.09.2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var typeOfSort: TypeSort = .usually
    @State private var typeOfFilter: TypeFilter = .all
    @State private var typeOfFilterTerm: FilterOfTerm = .all
    
    @State private var stateOfLoad: StatesOfLoading = .notAttemptToLoad
    @State private var isPresentedAlert: Bool = false 
    
    @State private var exampleOfManager = managerArrayOfTasks()     //владеет менеджером и хранит его состояние
    
    @State private var textForErrorMessage: String = ""
    
    @State private var address: URL? = nil                          // адреса в начале может не существовать!!!
    
    var body: some View {
        switch stateOfLoad {
        case .notAttemptToLoad:
            Text("not attempts")
                .onAppear {
                    stateOfLoad = .isLoading
                    do {
                        address = try Assistant().createStorageFolder().appendingPathComponent("tasks.json")            // надо будет распаковать опционал 
                        if let fileURL = address {
                            exampleOfManager = try Assistant().loadJSON(whereWeGet: fileURL)
                            stateOfLoad = .goodDownload
                        }
                    } catch {
                        switch error {
                        case GetJSONResult.fileNotFound:
                            stateOfLoad = .badDownload
                            textForErrorMessage = "we can't find file"
                            
                        case GetJSONResult.emptyInputForURL:
                            stateOfLoad = .badDownload
                            textForErrorMessage = "input for URL is empty"
                        
                        case GetJSONResult.decodingError(let cause):                           // есть ошибки декодирования - мы разбираем случ-какие они могут быть
                            stateOfLoad = .badDownload
                            switch cause {
                                case DecodingError.typeMismatch(_, _):
                                textForErrorMessage = "Несоответствие типов"

                                case DecodingError.dataCorrupted(let context):                                      // context = сведения об ошибке
                                textForErrorMessage = "Некорректные данные: \(context.debugDescription)"

                                default:
                                textForErrorMessage = "Другая причина: \(cause)"
                        }
                        default:
                            textForErrorMessage = "we don't know this type of error"
                            stateOfLoad = .badDownload
                        }
                    }
                }
        case .isLoading:
            Text("загрузка идет")  
        case .goodDownload:
            if let addressToSave = Binding($address) {
                addTaskView(exampleOfManager: $exampleOfManager, isPresented: $isPresentedAlert, addressToSave: addressToSave, typeOfSort: $typeOfSort, typeOfFilter: $typeOfFilter, typeOfFilterTerm: $typeOfFilterTerm)
            }
        case .badDownload:
            Text(textForErrorMessage)
                .onAppear()
                .font(.headline)
                .padding(10)
                .foregroundColor(.white)
                .background(.red)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}

struct ContentViewPreviewWrapper: View {

    var body: some View {
        ContentView()
    }
}

#Preview {
    ContentViewPreviewWrapper()
}

