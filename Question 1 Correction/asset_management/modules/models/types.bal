public type AssetStatus "ACTIVE"|"UNDER_REPAIR"|"DISPOSED";

public type TaskStatus "PENDING"|"IN_PROGRESS"|"DONE";

public type WorkOrderStatus "OPEN"|"IN_PROGRESS"|"COMPLETED"|"CLOSED";

public type Component record {
    string id;
    string name;
    string description?;
    string status?;
};

public type MaintenanceSchedule record {
    string id;
    string description?;
    string frequency;
    string nextDueDate;
};

public type Task record {
    string id;
    string description;
    TaskStatus status = "PENDING";
};

public type WorkOrder record {
    string id;
    string title;
    string description?;
    WorkOrderStatus status = "OPEN";
    Task[] tasks = [];
};

public type Asset record {
    string assetTag;
    string name;
    string faculty;
    string department;
    AssetStatus status = "ACTIVE";
    string acquiredDate;
    Component[] components = [];
    MaintenanceSchedule[] schedules = [];
    WorkOrder[] workOrders = [];
};

public type AssetCreateRequest record {
    string assetTag;
    string name;
    string faculty;
    string department;
    AssetStatus status = "ACTIVE";
    string acquiredDate;
    Component[] components?;
    MaintenanceSchedule[] schedules?;
    WorkOrder[] workOrders?;
};

public type AssetUpdateRequest record {
    string name?;
    string faculty?;
    string department?;
    AssetStatus status?;
    string acquiredDate?;
};

public type WorkOrderCreateRequest record {
    string id;
    string title;
    string description?;
    WorkOrderStatus status = "OPEN";
    Task[] tasks?;
};

public type WorkOrderUpdateRequest record {
    string title?;
    string description?;
    WorkOrderStatus status?;
};
