import ballerina/http;
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
    string frequency; // e.g., "QUARTERLY", "YEARLY"
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
    Status status; // ACTIVE, COMPLETED, CANCELLED
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

// Database simulation using a map
final map<Asset> assetDB = {};

// Service definition

service /assets on new http:Listener(9090) {
    resource function post .(http:Caller caller, http:Request req, Asset asset) returns error? {
        if assetDB.hasKey(asset.assetTag) {
            return caller->respond({ message: "Asset with tag " + asset.assetTag + " already exists" });
        }
        assetDB[asset.assetTag] = asset.cloneReadOnly();
        return caller->respond({ message: "Asset created successfully" });
    }

    resource function get .(http:Caller caller, http:Request req) returns error? {
        if assetDB.length() == 0 {
            return caller->respond({ message: "No assets found" });
        }
        Asset[] assets = assetDB.toArray();
        json[] jsonAssets = []; 
        foreach Asset asset in assets {
            jsonAssets.push(<json>asset);
        }
        return caller->respond(jsonAssets);
    }

    resource function get assetTag(http:Caller caller, http:Request req, string assetTag) returns error? {
        if !assetDB.hasKey(assetTag) {
            return caller->respond({ message: "Asset with tag " + assetTag + " not found" });
        }
        Asset? asset = assetDB[assetTag];
        if asset is Asset {
            return caller->respond(<json>asset);
        } else {
            return caller->respond({ message: "Asset with tag " + assetTag + " not found" });
        }
    }

    resource function put assetTag(http:Caller caller, http:Request req, string assetTag, Asset asset) returns error? {
        if assetTag != asset.assetTag {
            return caller->respond({ message: "Asset tag in path does not match payload" });
        }
        if !assetDB.hasKey(assetTag) {
            return caller->respond({ message: "Asset with tag " + assetTag + " not found" });
        }
        assetDB[assetTag] = asset.cloneReadOnly();
        return caller->respond({ message: "Asset updated successfully" });
    }

    resource function delete assetTag(http:Caller caller, http:Request req, string assetTag) returns error? {
        if !assetDB.hasKey(assetTag) {
            return caller->respond({ message: "Asset with tag " + assetTag + " not found" });
        }
        _ = assetDB.remove(assetTag);
        return caller->respond({ message: "Asset deleted successfully" });
    }

    resource function get faculty(http:Caller caller, http:Request req, string faculty) returns error? {
        Asset[] facultyAssets = from var asset in assetDB.toArray()
            where asset.faculty == faculty
            select asset;
        if facultyAssets.length() == 0 {
            return caller->respond({ message: "No assets found for faculty " + faculty });
        }
        json[] jsonFacultyAssets = [];
        foreach Asset asset in facultyAssets {
            jsonFacultyAssets.push(<json>asset);
        }
        return caller->respond(jsonFacultyAssets);
    }

    resource function get overdue(http:Caller caller, http:Request req) returns error? {
        time:Utc currentUtc = time:utcNow();
        int currentMillis = currentUtc[0];
        Asset[] overdueAssets = [];
        foreach var asset in assetDB.toArray() {
            foreach var schedule in asset.schedules {
                int dueMillis = 0;
                if schedule.nextDueDate.hasKey("time") {
                    var maybeTime = schedule.nextDueDate["time"];
                    if maybeTime is int {
                        dueMillis = maybeTime;
                    }
                }
                if dueMillis < currentMillis {
                    overdueAssets.push(asset);
                    break;
                }
            }
        }
        if overdueAssets.length() == 0 {
            return caller->respond({ message: "No assets with overdue maintenance" });
        }
        json[] jsonOverdueAssets = [];
        foreach Asset asset in overdueAssets {
            jsonOverdueAssets.push(<json>asset);
        }
        return caller->respond(jsonOverdueAssets);
    }

    resource function post addComponent(http:Caller caller, http:Request req, string assetTag, Component component) returns error? {
        if !assetDB.hasKey(assetTag) {
            return caller->respond({ message: "Asset with tag " + assetTag + " not found" });
        }
        Asset? assetOpt = assetDB[assetTag];
        if assetOpt is Asset {
            Asset asset = assetOpt.clone();
            asset.components.push(component);
            assetDB[assetTag] = asset.cloneReadOnly();
            return caller->respond({ message: "Component added successfully" });
        } else {
            return caller->respond({ message: "Asset with tag " + assetTag + " not found" });
        }
    }

    resource function delete removeComponent(http:Caller caller, http:Request req, string assetTag, string componentId) returns error? {
        if !assetDB.hasKey(assetTag) {
            return caller->respond({ message: "Asset with tag " + assetTag + " not found" });
        }
        Asset? assetOpt = assetDB[assetTag];
        if assetOpt is Asset {
            Asset asset = assetOpt.clone();
            int index = -1;
            foreach int i in 0 ... asset.components.length() - 1 {
                if asset.components[i].id == componentId {
                    index = i;
                    break;
                }
            }
            if index == -1 {
                return caller->respond({ message: "Component with ID " + componentId + " not found" });
            }
            _ = asset.components.remove(index);
            assetDB[assetTag] = asset.cloneReadOnly();
            return caller->respond({ message: "Component removed successfully" });
        } else {
            return caller->respond({ message: "Asset with tag " + assetTag + " not found" });
        }
    }

    resource function post addSchedule(http:Caller caller, http:Request req, string assetTag, MaintenanceSchedule schedule) returns error? {
        if !assetDB.hasKey(assetTag) {
            return caller->respond({ message: "Asset with tag " + assetTag + " not found" });
        }
        Asset? assetOpt = assetDB[assetTag];
        if assetOpt is Asset {
            Asset asset = assetOpt.clone();
            asset.schedules.push(schedule);
            assetDB[assetTag] = asset.cloneReadOnly();
            return caller->respond({ message: "Maintenance schedule added successfully" });
        } else {
            return caller->respond({ message: "Asset with tag " + assetTag + " not found" });
        }
    }

    resource function delete removeSchedule(http:Caller caller, http:Request req, string assetTag, string scheduleId) returns error? {
        if !assetDB.hasKey(assetTag) {
            return caller->respond({ message: "Asset with tag " + assetTag + " not found" });
        }
        Asset? assetOpt = assetDB[assetTag];
        if assetOpt is Asset {
            Asset asset = assetOpt.clone();
            int index = -1;
            foreach int i in 0 ... asset.schedules.length() - 1 {
                if asset.schedules[i].id == scheduleId {
                    index = i;
                    break;
                }
            }
            if index == -1 {
                return caller->respond({ message: "Schedule with ID " + scheduleId + " not found" });
            }
            _ = asset.schedules.remove(index);
            assetDB[assetTag] = asset.cloneReadOnly();
            return caller->respond({ message: "Maintenance schedule removed successfully" });
        } else {
            return caller->respond({ message: "Asset with tag " + assetTag + " not found" });
        }
    }

    resource function post addWorkOrder(http:Caller caller, http:Request req, string assetTag, WorkOrder workOrder) returns error? {
        if !assetDB.hasKey(assetTag) {
            return caller->respond({ message: "Asset with tag " + assetTag + " not found" });
        }
        Asset? assetOpt = assetDB[assetTag];
        if assetOpt is Asset {
            Asset asset = assetOpt.clone();
            asset.workOrders.push(workOrder);
            assetDB[assetTag] = asset.cloneReadOnly();
            return caller->respond({ message: "Work order added successfully" });
        } else {
            return caller->respond({ message: "Asset with tag " + assetTag + " not found" });
        }
    }

    resource function post addTask(http:Caller caller, http:Request req, string assetTag, string workOrderId, Task task) returns error? {
        if !assetDB.hasKey(assetTag) {
            return caller->respond({ message: "Asset with tag " + assetTag + " not found" });
        }
        Asset? assetOpt = assetDB[assetTag];
        if assetOpt is Asset {
            Asset asset = assetOpt.clone();
            int woIndex = -1;
            foreach int i in 0 ... asset.workOrders.length() - 1 {
                if asset.workOrders[i].id == workOrderId {
                    woIndex = i;
                    break;
                }
            }
            if woIndex == -1 {
                return caller->respond({ message: "Work order with ID " + workOrderId + " not found" });
            }
            asset.workOrders[woIndex].tasks.push(task);
            assetDB[assetTag] = asset.cloneReadOnly();
            return caller->respond({ message: "Task added successfully" });
        } else {
            return caller->respond({ message: "Asset with tag " + assetTag + " not found" });
        }
    }
}