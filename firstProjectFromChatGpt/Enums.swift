enum statusForCompletition {
    case doneBefore, notDoneYet, haveNotId, goodDone, notNumber
}

enum statusForDelete {
    case haveNotId, notNumber, good, notDoneYet
}


enum executionStatus: String, CaseIterable, Codable {
    case done
    case active
}


enum priorities: String, CaseIterable, Codable {                       // использовал raw values (чтобы можно было удачно сравнивать) (нужно задать что явл String)
    case low = "Low"
    case middle = "Middle"
    case high = "High"
}


enum TypeSort: String, CaseIterable {
    case HML = "HML"
    case usually = "usually"
    case soonerLater = "SL"
}


enum TypeFilter: String, CaseIterable {
    case done = "Done"
    case active = "Active"
    case all = "All"
}


enum StatusOfTerm: String, CaseIterable {
    case today = "Today"
    case norm = "Norm"
    case withoutTerm = "Without Term"
    case overdue = "Overdue"
}

enum FilterOfTerm: String, CaseIterable {
    case today = "Today"
    case norm = "Norm"
    case withoutTerm = "WithoutTerm"
    case overdue = "overdue"
    case all = "All"
}
