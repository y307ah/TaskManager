//
//  windows.swift
//  firstProjectFromChatGpt
//
//  Created by Ярослав on 01.10.2026.
//


// только если разделишь смысл:
//- didLoad — попытка загрузки была
//- goodDownload — она завершилась успешно

import SwiftUI


enum StatesOfLoading {
    case notAttemptToLoad
    case isLoading
    case goodDownload
    case badDownload
}

//создаем родительский view чтобы свободно перекидываться данными между inputField и addTaskButton
struct addTaskView: View {
    
    @State private var bufferName = ""
    @State private var bufferPriority: priorities = .low
    @State private var searchName = ""
    @State private var bufferHasTerm: Bool = false
    @State private var bufferDate: Date = Date()
    
    
    @Binding var exampleOfManager: managerArrayOfTasks
    @Binding var isPresented: Bool
    @Binding var addressToSave: URL
    
    @Binding var typeOfSort: TypeSort
    @Binding var typeOfFilter: TypeFilter
    @Binding var typeOfFilterTerm: FilterOfTerm
    
    var body: some View {
        NavigationStack {
            if exampleOfManager.array.isEmpty {
                StartView(bufferName: $bufferName, bufferPriority: $bufferPriority, exampleOfManager: $exampleOfManager, isPresented: $isPresented, addressToSave: $addressToSave, bufferHasTerm: $bufferHasTerm, bufferDate: $bufferDate)
                
            } else {
                var countOfCompletedTasks = exampleOfManager.information().done
                var countOfActiveTasks = exampleOfManager.information().active
                
                VStack {
                    ListView(exampleOfManager: $exampleOfManager, isPresented: $isPresented, addressToSave: $addressToSave, typeOfSort: $typeOfSort, typeOfFilter: $typeOfFilter, typeOfFilterTerm: $typeOfFilterTerm, searchName: $searchName)
                        .padding()
                        .searchable(text: $searchName, placement: .navigationBarDrawer(displayMode: .always), prompt: "Поиск по названию")
//                    placement: — где желательно разместить поле поиска.
//                    .navigationBarDrawer(...) — в области навигационной панели, под заголовком экрана.
//                    displayMode: — когда показывать это поле.
//                    .always — показывать постоянно, а не открывать его только при протягивании списка вниз.
                    
                    DownView(
                        bufferName: $bufferName,
                        bufferPriority: $bufferPriority,
                        exampleOfManager: $exampleOfManager,
                        isPresented: $isPresented,
                        addressToSave: $addressToSave,
                        bufferTerm: $bufferDate,
                        countOfActiveTasks: countOfActiveTasks,
                        countOfCompletedTasks: countOfCompletedTasks,
                        bufferHasTerm: $bufferHasTerm,
                        typeOfSort: $typeOfSort,
                        typeOfFilter: $typeOfFilter,
                        typeOfFilterTerm: $typeOfFilterTerm,
                    )
                }
            }
        }
    }
}


struct DownView: View {
    @Binding var bufferName: String
    @Binding var bufferPriority: priorities
    @Binding var exampleOfManager: managerArrayOfTasks
    @Binding var isPresented: Bool
    @Binding var addressToSave: URL
    
    @Binding var bufferTerm: Date
    var countOfActiveTasks: Int
    var countOfCompletedTasks: Int
    @Binding var bufferHasTerm: Bool
    
    @Binding var typeOfSort: TypeSort
    @Binding var typeOfFilter: TypeFilter
    @Binding var typeOfFilterTerm: FilterOfTerm
    
    var body: some View {
        HStack {
            VStack {
                NavigationLink {
                    ParametersOfTaskView(bufferName: $bufferName, bufferPriority: $bufferPriority)
                } label: {
                    ParametersLabel(text: "Parameters of Task")
                }
                NavigationLink {
                    ParametersOfDateView(bufferDate: $bufferTerm, bufferHasTerm: $bufferHasTerm)
                } label: {
                    ParametersLabel(text: "Parameters of Date")
                }
                
                NavigationLink {
                    ParametersOfFilterOrSortView(typeOfSort: $typeOfSort, typeOfFilter: $typeOfFilter, typeOfFilterTerm: $typeOfFilterTerm)
                } label: {
                    ParametersLabel(text: "Parameters of Sort")
                }
            }
            addTaskButton(bufferName: $bufferName, exampleOfManager: $exampleOfManager, isPresented: $isPresented, bufferPriority: bufferPriority, addressToSave: addressToSave, bufferTerm: bufferTerm, bufferHasTerm: $bufferHasTerm)
        }
        .padding()
        
        counter(countOfTasks: countOfActiveTasks , counterOfWhat: "количество активных задач")
        counter(countOfTasks: countOfCompletedTasks , counterOfWhat: "количество завершенных задач")
    }
}

struct ParametersLabel: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "slider.horizontal.3")
                .font(.system(size: 14, weight: .semibold))
                .padding(8)
                .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 9))        // белый фон с непрозрачностью 18% и скругленный

            Text(text)
                .font(.subheadline.weight(.semibold))
                .multilineTextAlignment(.leading)

            Spacer(minLength: 4) 

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white.opacity(0.75))
        }                                                           // модификаторы отсюда - ко всему контейнеру
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
        .background(
            LinearGradient(colors: [.blue, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing),       // сверху-слева -> снизу-справа
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(.white.opacity(0.25), lineWidth: 1)
        }
        .shadow(color: .blue.opacity(0.16), radius: 6, x: 0, y: 3)
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))                       // форма области по которой можно нажимать
        // .continuous постепенная кривизна - угол меняется более плавно
    }
}


struct ParametersOfTaskView: View {
    @Binding var bufferName: String
    @Binding var bufferPriority: priorities
    
    var body: some View {
        HStack {
            inputField(userFacingText: "Название", ourInput: $bufferName)
            PriorityOfTaskField(userFacingText: "Приоритет", ourInput: $bufferPriority)
        }
    }
}

struct ParametersOfFilterOrSortView: View {
    @Binding var typeOfSort: TypeSort
    @Binding var typeOfFilter: TypeFilter
    
    @Binding var typeOfFilterTerm: FilterOfTerm
    
    var body: some View {
        HStack {
            SortField(ourInput: $typeOfSort)
            StatusFilterField(ourInput: $typeOfFilter)
            FilterTasksByStatusOfTermField(ourInput: $typeOfFilterTerm)
        }
    }
}

struct ParametersOfDateView: View {
    @Binding var bufferDate: Date
    @Binding var bufferHasTerm: Bool
    
    var body: some View {
        HStack {
            DateField(bufferDate: $bufferDate)
            IsSelectedToggle(isEnabled: $bufferHasTerm)
        }
    }
}


struct ListView: View {
    @Binding var exampleOfManager: managerArrayOfTasks
    @Binding var isPresented: Bool
    @Binding var addressToSave: URL
    
    @Binding var typeOfSort: TypeSort
    @Binding var typeOfFilter: TypeFilter
    
    @Binding var typeOfFilterTerm: FilterOfTerm
    
    
    @Binding var searchName: String
    var body: some View {
        var filteredArray = exampleOfManager.filterTasksByStatus(status: typeOfFilter, currentArray: exampleOfManager.array)
        
        var filteredOfTermsArray = exampleOfManager.filterTasksByStatusOfTerms(status: typeOfFilterTerm, currentArray: filteredArray)
        
        
        var sortedArray = exampleOfManager.sortedTasksByPriority(typeOfSort: typeOfSort, currentArray: filteredOfTermsArray)
        
        var finalArray = exampleOfManager.findTasksByName(searchName: searchName, currentArray: sortedArray)
        
        var countOfTasksOnView = finalArray.count
        
        var countOfOverdueTasks = exampleOfManager.makeCountOfOverdueTasks(array: exampleOfManager.array)
        
        if finalArray.count != 0 {
            List(finalArray) { exampleOfTask in
                
                var statusOfTerm: StatusOfTerm = exampleOfManager.checkStatusTermOfTask(ourTask: exampleOfTask)
                
                NavigationLink {
                    TaskDetailView(id: exampleOfTask.id, exampleOfManager: $exampleOfManager, isPresented: $isPresented, addressToSave: $addressToSave)
                } label: {
                    
                    if exampleOfTask.status == .done {
                        PresentationViewOfTask(task: exampleOfTask, colorOfBackground: .green, statusOfTerm: statusOfTerm.rawValue)
                    } else {
                        PresentationViewOfTask(task: exampleOfTask, colorOfBackground: .gray, statusOfTerm: statusOfTerm.rawValue)
                    }
                    
                    
                    DoneButton(manager: $exampleOfManager, isPresented: $isPresented, addressToSave: $addressToSave, exampleOfTask: exampleOfTask)
                    
                    DeleteButton(manager: $exampleOfManager, isPresented: $isPresented, addressToSave: $addressToSave, exampleOfTask: exampleOfTask)
                    
                }
            }
            .navigationTitle("Главный экран") // задаёт заголовок текущего экрана в навигационной панели
            
            VisibleTaskCountView(userText: "Показано", countOfTaskOnView: countOfTasksOnView, countOfAllTasks: exampleOfManager.array.count)
            VisibleTaskCountView(userText: "Просрочены", countOfTaskOnView: countOfOverdueTasks, countOfAllTasks: exampleOfManager.array.count)
        
        } else {
            Text("Ничего не найдено")
                .font(.subheadline)
                .bold()
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.black)
                .clipShape(Capsule())
            VisibleTaskCountView(userText: "Показано", countOfTaskOnView: 0, countOfAllTasks: exampleOfManager.array.count)
            VisibleTaskCountView(userText: "Просрочены", countOfTaskOnView: countOfOverdueTasks, countOfAllTasks: exampleOfManager.array.count)
        }
        
        
    }
}


struct VisibleTaskCountView: View {
    var userText: String
    var countOfTaskOnView: Int
    var countOfAllTasks: Int
    var body: some View {
        Text("\(userText) - \(countOfTaskOnView) из \(countOfAllTasks) задач")
            .font(.subheadline)
            .bold()
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(.black)
            .clipShape(Capsule())
    }
}


struct PresentationViewOfTask: View {
    var task: task
    var colorOfBackground: Color
    
    var statusOfTerm: String
    
    var body: some View {
        Text("nameTask: \(task.name)\npriority: \(task.priority.rawValue)\nstatus: \(task.status.rawValue)\ndate: \(task.term.map { $0.formatted(date: .numeric, time: .omitted) } ?? "нет срока")\nсрок: \(statusOfTerm)")
        // map - (если знач есть преобразуй его / если nil - оставь nil)
        // .formatted(...) — превращает её в строку / date: .numeric — дата цифрами, например 08.11.2026 / time: .omitted — время не показывать
            
        .foregroundColor(Color(red: 0.98, green: 0.96, blue: 0.90))
        .background(colorOfBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
