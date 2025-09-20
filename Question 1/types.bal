import ballerina/time;

// Define types for the asset management system
enum Status {
    ACTIVE,
    UNDER_REPAIR,
    DISPOSED
}

type Component record {| 
    string id;
    string name;
    string description;
|};

type MaintenanceSchedule record {| 
    string id;
    string description;
    string frequency;
    time:Date nextDueDate;
|};

type Task record {| 
    string id;
    string description;
    boolean completed;
|};

type WorkOrder record {| 
    string id;
    string description;
    Status status;
    Task[] tasks;
|};

type Asset record {| 
    string assetTag;
    string name;
    string faculty;
    string department;
    Status status;
    time:Date acquiredDate;
    Component[] components;
    MaintenanceSchedule[] schedules;
    WorkOrder[] workOrders;
|};