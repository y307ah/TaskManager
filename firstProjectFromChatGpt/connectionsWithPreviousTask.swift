import Foundation

var calendar = Calendar(identifier: .gregorian)                     // по умолч использует текущ часовой пояс (отдельно можно не задавать)


//let startComponents = DateComponents(
//    year: 2026,
//    month: 12,
//    day: 15,
//    hour: 12,
//    minute: 0
//)

let chosenDate = Date()
// ( распаковку можно производить внутри функции которая обращается к chosenDate )

struct task: Identifiable, Codable {
    var name: String
    
    let id: UUID                                                        // чтобы можно было декодировать делаю именно id: UUID и потом при добавлении создаю ID 
    
    var priority: priorities
    
    var status: executionStatus
    
    var term: Date?                                     // потому что может не существовать
}

struct managerArrayOfTasks: Codable {
    private(set) var array: [task] = []
    
    
    func checkStatusOfTask(whatTypeWeNeedToCheck: executionStatus) -> [task] {
        var answerArray: [task] = []
        
        for checkingTask in array {
            if checkingTask.status == whatTypeWeNeedToCheck {
                answerArray.append(checkingTask)
            }
        }
        return answerArray
    }
    
    mutating func changeTermOfTask(idTaskToChangeTerm: UUID, byAdding: Calendar.Component, howMuch: Int) {
        var moment = chosenDate
        
        if let currentIndex = findTaskById(needId: idTaskToChangeTerm) {                // let - тк не изменится (чистота кода)
            if let currentTerm = array[currentIndex].term {
                let newDate = calendar.date(byAdding: byAdding, value: howMuch, to: currentTerm)
                array[currentIndex].term = newDate
            } else {
                array[currentIndex].term = calendar.date(byAdding: byAdding, value: howMuch, to: moment)
            }
        } else {
            return
        }
    }
    
    mutating func makeNewTermOfTask(idTaskToMakeNewTerm: UUID, pYear: Int, pMonth: Int, pDay: Int) {
        let newDate = calendar.date(from: DateComponents(year: pYear, month: pMonth, day: pDay))
        
        if let currentIndex = findTaskById(needId: idTaskToMakeNewTerm) {
            array[currentIndex].term = newDate
        } else {
            return
        }
    }
    
    mutating func deleteTermOfTask(idTaskToDeleteTerm: UUID) {
        if let currentIndex = findTaskById(needId: idTaskToDeleteTerm) {
            array[currentIndex].term = nil
        } else {
            return
        }
    }

    
    func checkStatusTermOfTask(ourTask: task) -> StatusOfTerm {
        var moment = chosenDate
        
        if let currentTerm = ourTask.term {
            if calendar.isDate(currentTerm, inSameDayAs: moment) {                      // isSameDayAs - если мы хотим проверить равенство именно ДНЕЙ (today)
                return StatusOfTerm.today
            } else if currentTerm > moment {
                return StatusOfTerm.norm
            } else {
                if ourTask.status == .done {
                    return StatusOfTerm.norm
                } else {
                    return StatusOfTerm.overdue
                }
            }
        } else {
            return StatusOfTerm.withoutTerm
        }
    }
    
    func makeCountOfOverdueTasks(array: [task]) -> Int {
        var count = 0
        
        for task in array {
            if checkStatusTermOfTask(ourTask: task).rawValue == "Overdue" {
                count += 1
            }
        }
        return count
    }

//    func sortedTasksByPriority(typeWeWant: priorities) -> [task] {                           интересная функция (только по приоритету высветить)
//        let lowTasks = array.filter({ $0.priority == .low })
//        let highTasks = array.filter({ $0.priority == .high })
//        let middleTasks = array.filter({ $0.priority == .middle })
//        
//        switch typeWeWant {
//        case .low:
//            return lowTasks
//        case .middle:
//            return middleTasks
//        case .high:
//            return highTasks
//        }
//    }
    
    func sortedTasksByPriority(typeOfSort: TypeSort, currentArray: [task]) -> [task] {                            // High->Middle->Low (идем сверху вниз)
        let lowTasks = currentArray.filter({ $0.priority == .low })
        let highTasks = currentArray.filter({ $0.priority == .high })
        let middleTasks = currentArray.filter({ $0.priority == .middle })
        
        let answerArray = highTasks + middleTasks + lowTasks
        
        let answerArrayOfSortByTerms = sortedTasksByStatusOfTerms(typeOfSort: typeOfSort, currentArray: currentArray)
        
        
        switch typeOfSort {
        case .HML:
            return answerArray
        case .usually:
            return currentArray
        case .soonerLater:
            return answerArrayOfSortByTerms
        }
    }
    
    
    func sortedTasksByStatusOfTerms(typeOfSort: TypeSort, currentArray: [task]) -> [task] {
        var TasksWithTerm: [task] = []
        var other: [task] = []
        
        for currentTask in currentArray {
            if let currentTerm = currentTask.term {
                TasksWithTerm.append(currentTask)
            } else {
                other.append(currentTask)
            }
        }
        
        let sortedTaskWithTerm = TasksWithTerm.sorted { first, second in                    // ПРО return true/false почитать еще
            if let currentTask1Term = first.term {
                if let currentTask2Term = second.term {
                    let comparison = calendar.compare(currentTask1Term, to: currentTask2Term, toGranularity: .day) // сравниваем даты по дням
                    let firstDayBefore = comparison == .orderedAscending
                    return firstDayBefore
                }
                return true
            } else {
                if let currentTask2Term = second.term {
                    return false
                }
                return false
            }
        }
        
        var answerArray = sortedTaskWithTerm + other
        
        switch typeOfSort {
        case .soonerLater:
            return answerArray
        case .usually:
            return currentArray
        case .HML:
            return currentArray
        }
    }
    
    
    func filterTasksByStatus(status: TypeFilter, currentArray: [task]) -> [task] {
        let doneTasks = currentArray.filter({ $0.status == .done })
        let activeTasks = currentArray.filter({ $0.status == .active })

        switch status {
        case .done:
            return doneTasks
        case .active:
            return activeTasks
        case .all:
            return currentArray
        }
    }
    
    func filterTasksByStatusOfTerms(status: FilterOfTerm, currentArray: [task]) -> [task] {
        let withoutTermTasks = currentArray.filter({ currentTask in
            return checkStatusTermOfTask(ourTask: currentTask) == .withoutTerm
        })
        let normTermTasks = currentArray.filter({ currentTask in
            return checkStatusTermOfTask(ourTask: currentTask) == .norm
        })
        let overdueTermTasks = currentArray.filter({ currentTask in
            return checkStatusTermOfTask(ourTask: currentTask) == .overdue
        })
        let todayTermTasks = currentArray.filter({ currentTask in
            return checkStatusTermOfTask(ourTask: currentTask) == .today
        })
        
        switch status {
        case .today:
            return todayTermTasks
        case .norm:
            return normTermTasks
        case .withoutTerm:
            return withoutTermTasks
        case .overdue:
            return overdueTermTasks
        case .all:
            return currentArray
        }
    }
     
    
    func findTasksByName(searchName: String, currentArray: [task]) -> [task] {
        var searching = searchName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        var answerArray: [task] = []
        
        for currentTask in currentArray {
            if searching != "" {
                if currentTask.name.localizedCaseInsensitiveContains(searching) {
                    answerArray.append(currentTask)
                }
            } else {
                return currentArray
            }
        }
        return answerArray
    }
    
    
    func information() -> (all: Int, active: Int, done: Int) {          // параметр убран - цикл работает с внутренним array
        
        var answerActive: Int = 0
        var answerDone: Int = 0
        
        for currentTask in array {
            if currentTask.status == .active {
                answerActive += 1
            } else {
                answerDone += 1
            }
        }
        return (all: array.count, active: answerActive, done: answerDone)
    }
    
    
    mutating func addTaskToArray(currentName: String, currentPriority: priorities, currentDate: Date?) {        // если параметр нельзя менять - создать копию/поменять параметр/добавить копию
        let currentTask: task = task.init(name: currentName, id: UUID(), priority: currentPriority, status: .active, term: currentDate)        // здесь задаем id
        array.append(currentTask)
    }
    
    
    func findTaskById(needId: UUID) -> Int? {
        return array.firstIndex {
            $0.id == needId                                                    // идентификатор текущей задачи - needId??
        }
    }
    

    mutating func completitionMark(idTaskToBeFlagged: UUID) -> statusForCompletition {
        if let currentIndex = findTaskById(needId: idTaskToBeFlagged) {                 // let - тк не изменится (чистота кода)
            if array[currentIndex].status == .done {
                return statusForCompletition.doneBefore
            } else {
                array[currentIndex].status = .done
                return statusForCompletition.goodDone
            }
        } else {
            return statusForCompletition.haveNotId
        }
    }
    
    
    mutating func changeParametersOfTask(idTaskToChangeParameters: UUID, newName: String, newPriority: priorities, newDate: Date?) {
        if let currentIndex = findTaskById(needId: idTaskToChangeParameters) {
            array[currentIndex].name = newName
            array[currentIndex].priority = newPriority
            array[currentIndex].term = newDate
        } else {
            return
        }
    } // нихуя себе пришлось добавить новую функцию чтобы можно было менять array и не обращаться к private (set) хуйням снаружи - а только изнутри 
    
    mutating func deleteTaskFromArray(idOfOurTask: UUID) -> statusForDelete {                           // работаем по ID-шнику
        if let currentIndex = findTaskById(needId: idOfOurTask) {
            array.remove(at: currentIndex)
            return statusForDelete.good
        } else {
            return statusForDelete.haveNotId
        }
    }

}
