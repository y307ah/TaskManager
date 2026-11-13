import SwiftUI

// свернуть option + command + left развернуть ... + right

struct StartView: View {
    @Binding var bufferName: String
    @Binding var bufferPriority: priorities
    @Binding var exampleOfManager: managerArrayOfTasks
    @Binding var isPresented: Bool
    @Binding var addressToSave: URL
    
    @Binding var bufferHasTerm: Bool
    @Binding var bufferDate: Date
    
    
    var body: some View {
        VStack {
            Text("Начальный экран")
                .font(.headline)
                .padding(20)
                .foregroundColor(.white)
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            Text("Нет добавленных задач")
                .font(.headline)
                .padding(20)
                .foregroundColor(.white)
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            VisibleTaskCountView(userText: "Показано", countOfTaskOnView: 0, countOfAllTasks: 0)
            addTaskButton(
                bufferName: $bufferName,
                exampleOfManager: $exampleOfManager,
                isPresented: $isPresented,
                bufferPriority: bufferPriority,
                addressToSave: addressToSave,
                bufferTerm: bufferDate,
                bufferHasTerm: $bufferHasTerm
            )
            inputField(userFacingText: "Название", ourInput: $bufferName)
            PriorityOfTaskField(userFacingText: "Приоритет", ourInput: $bufferPriority)
            DateField(bufferDate: $bufferDate)
            IsSelectedToggle(isEnabled: $bufferHasTerm)
        }
    }
}

// верхние параметры - свойства экземпляра , присваивание внутри инит сохранит параметр таким в экземпляре
struct TaskDetailView: View {
    
    let id: UUID                                          // просто для передачи статуса
    
    @State var bufferEditedName: String                      // отдельное состояние — черновик названия этого экрана редактирования
    @State  var bufferEditedPriority: priorities
    
    @Binding var exampleOfManager: managerArrayOfTasks
    @Binding var isPresented: Bool
    
    @Binding var addressToSave: URL
    
    
    @State private var hasTermInDetails: Bool
    @State private var dateInDetails: Date
    
    // нужно подготовить только хранимые ИЗНАЧАЛЬНО свойства
    init(id: UUID, exampleOfManager: Binding<managerArrayOfTasks>, isPresented: Binding<Bool>, addressToSave: Binding<URL>) {     // как только я пишу свой init - авто вариант перестает создаваться
        self.id = id
        self._exampleOfManager = exampleOfManager                                           // изм через эту связь попадут в источник
        self._isPresented = isPresented
        self._addressToSave = addressToSave

        if let currentIndex = exampleOfManager.wrappedValue.findTaskById(needId: id) {
            
            let currentTask = exampleOfManager.wrappedValue.array[currentIndex]
            self._bufferEditedName = State(initialValue: currentTask.name)
            self._bufferEditedPriority = State(initialValue: currentTask.priority)
            
            if let currentTerm = currentTask.term {
                self._hasTermInDetails = State(initialValue: true)
                self._dateInDetails = State(initialValue: currentTerm)
            } else {
                self._hasTermInDetails = State(initialValue: false)
                self._dateInDetails = State(initialValue: Date())
            }
        
        } else {
            self._bufferEditedName = State(initialValue: "")
            self._bufferEditedPriority = State(initialValue: .low)
            self._hasTermInDetails = State(initialValue: false)
            self._dateInDetails = State(initialValue: Date())
        }
    }
    
    var body: some View {
            Form {
                Section("Задача") {
                    if let currentIndex = exampleOfManager.findTaskById(needId: id) {
                        inputField(userFacingText: "Название - \(exampleOfManager.array[currentIndex].name)", ourInput: $bufferEditedName)
                        PriorityOfTaskField(userFacingText: "Приоритет - \(exampleOfManager.array[currentIndex].priority)", ourInput: $bufferEditedPriority)
                    } else {
                        Text("Задача не была найдена")
                    }
                }
                Section("Статус") {
                    if let currentIndex = exampleOfManager.findTaskById(needId: id) {
                        Text(exampleOfManager.array[currentIndex].status.rawValue)
                    } else {
                        Text("Задача не была найдена")
                    }
                }
                Section("Срок") {
                    if let currentIndex = exampleOfManager.findTaskById(needId: id) {
                        
                        DateField(bufferDate: $dateInDetails)
                        IsSelectedToggle(isEnabled: $hasTermInDetails)
                    } else {
                        Text("Задача не была найдена")
                    }
                }
                if hasTermInDetails == false {
                    SaveButton(bufferName: $bufferEditedName, bufferPriority: $bufferEditedPriority, manager: $exampleOfManager, isPresented: $isPresented, addressToSave: $addressToSave, bufferDate: nil, id: id)
                } else {
                    SaveButton(bufferName: $bufferEditedName, bufferPriority: $bufferEditedPriority, manager: $exampleOfManager, isPresented: $isPresented, addressToSave: $addressToSave, bufferDate: dateInDetails, id: id)
                }
            }
    }
}


struct counter: View {
    var countOfTasks: Int
    let counterOfWhat: String
    
    var body: some View {
        HStack {
            Text("\(counterOfWhat) - ")
            Text("\(countOfTasks)")
                .font(.headline)
                .padding(10)
                .foregroundColor(.white)
                .background(.black)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }
}


struct PriorityOfTaskField: View {
    let userFacingText: String
    @Binding var ourInput: priorities
    
    var body: some View {
        Picker("\(userFacingText)", selection: $ourInput) {                     // удобно для enum в которых куча хуйни
            ForEach(priorities.allCases, id: \.self) { priority in
                Text(priority.rawValue)
                    .tag(priority) // .tag(option) связывает созданный Text с конкретным значением enum.
            }
        }
        .padding()
        .background(.yellow)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}


struct inputField: View {
    let userFacingText: String
    @Binding var ourInput: String                     // хранит ДОСТУП к строке родителя
    //строка находится где то снаружи - есть возможность ее читать и изменять
    
    
    var body: some View {
        TextField("\(userFacingText)", text: $ourInput)
            .padding()
            .background(.yellow)
            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
            .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}


struct SortField: View {
    @Binding var ourInput: TypeSort
    
    var body: some View {
        Picker("Choose type of sort", selection: $ourInput) {                     // заголовок виден в Form например - а в меню мы видим чисто выборы 
            ForEach(TypeSort.allCases, id: \.self) { sort in
                Text(sort.rawValue)
                    .tag(sort)                                                      // .tag(option) связывает созданный Text с конкретным значением enum.
            }
        }
        .padding()
        .background(.yellow)
        .tint(.black)                                                   // надпись  на PIcker будет черного цвета
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}


struct FilterTasksByStatusOfTermField: View {
    @Binding var ourInput: FilterOfTerm
    
    var body: some View {
        Picker("Choose type of filter", selection: $ourInput) {
            ForEach(FilterOfTerm.allCases, id: \.self) { filter in
                Text(filter.rawValue)
                    .tag(filter)
            }
        }
        .padding()
        .background(.yellow)
        .tint(.black)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}


struct StatusFilterField: View {
    @Binding var ourInput: TypeFilter
    
    var body: some View {
        Picker("Choose type of filter", selection: $ourInput) {                     // заголовок виден в Form например - а в меню мы видим чисто выборы
            ForEach(TypeFilter.allCases, id: \.self) { filter in
                Text(filter.rawValue)
                    .tag(filter) // .tag(option) связывает созданный Text с конкретным значением enum.
            }
        }
        .padding()
        .background(.yellow)
        .tint(.black)
        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
        .clipShape(RoundedRectangle(cornerRadius: 30))
    }
}


struct DateField: View {
    @Binding var bufferDate: Date
    
    var body: some View {
        DatePicker("Срок задачи", selection: $bufferDate, displayedComponents: [.date])
        .datePickerStyle(.compact)
        .labelsHidden()
        .fixedSize()
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.gray)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}


struct IsSelectedToggle: View {
    @Binding var isEnabled: Bool
    
    var body: some View {
        Toggle("Cрок", isOn: $isEnabled)
            .toggleStyle(.switch)
            .tint(.orange)                                      // цвет включённого переключателя
            .font(.headline)                                    // шрифт подписи
            .padding()
            .background(Color.gray.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
