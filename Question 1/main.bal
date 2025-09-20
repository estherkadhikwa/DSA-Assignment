import ballerina/http;
import ballerina/time;
import ballerina/lang.'string;
import your_username/asset-management-api.types;

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

    // Create a new asset
    resource function post .(@http:Payload Asset asset) returns http:Created|http:BadRequest {
        if assetDB.hasKey(asset.assetTag) {
            return http:BadRequest("Asset with tag " + asset.assetTag + " already exists");
        }
        assetDB[asset.assetTag] = asset.cloneReadOnly();
        return http:Created("Asset created successfully");
    }

    // Get all assets
    resource function get .() returns Asset[]|http:NotFound {
        if assetDB.length() == 0 {
            return http:NotFound("No assets found");
        }
        return assetDB.toArray();
    }

    // Get asset by tag
    resource function get ./[string assetTag]() returns Asset|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NotFound("Asset with tag " + assetTag + " not found");
        }
        return assetDB[assetTag];
    }

    // Update an asset
    resource function put ./[string assetTag](@http:Payload Asset asset) returns http:Ok|http:BadRequest|http:NotFound {
        if assetTag != asset.assetTag {
            return http:BadRequest("Asset tag in path does not match payload");
        }
        if !assetDB.hasKey(assetTag) {
            return http:NotFound("Asset with tag " + assetTag + " not found");
        }
        assetDB[assetTag] = asset.cloneReadOnly();
        return http:Ok("Asset updated successfully");
    }

    // Delete an asset
    resource function delete ./[string assetTag]() returns http:Ok|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NotFound("Asset with tag " + assetTag + " not found");
        }
        _ = assetDB.remove(assetTag);
        return http:Ok("Asset deleted successfully");
    }

    // Get assets by faculty
    resource function get ./faculty/[string faculty]() returns Asset[]|http:NotFound {
        Asset[] facultyAssets = from var asset in assetDB.toArray()
            where asset.faculty == faculty
            select asset;
        
        if facultyAssets.length() == 0 {
            return http:NotFound("No assets found for faculty " + faculty);
        }
        return facultyAssets;
    }

    // Get assets with overdue maintenance
    resource function get .//maintenance/overdue() returns Asset[]|http:NotFound {
        time:Date currentDate = time:date(time:currentTime());
        Asset[] overdueAssets = [];
        
        foreach var asset in assetDB.toArray() {
            foreach var schedule in asset.schedules {
                if schedule.nextDueDate < currentDate {
                    overdueAssets.push(asset);
                    break;
                }
            }
        }
        
        if overdueAssets.length() == 0 {
            return http:NotFound("No assets with overdue maintenance");
        }
        return overdueAssets;
    }

    // Add a component to an asset
    resource function post .//[string assetTag]/components(@http:Payload Component component) returns http:Ok|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NotFound("Asset with tag " + assetTag + " not found");
        }
        
        Asset asset = assetDB[assetTag].clone();
        asset.components.push(component);
        assetDB[assetTag] = asset.cloneReadOnly();
        
        return http:Ok("Component added successfully");
    }

    // Remove a component from an asset
    resource function delete .//[string assetTag]/components/[string componentId]() returns http:Ok|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NotFound("Asset with tag " + assetTag + " not found");
        }
        
        Asset asset = assetDB[assetTag].clone();
        int index = -1;
        
        foreach int i in 0 ... asset.components.length() - 1 {
            if asset.components[i].id == componentId {
                index = i;
                break;
            }
        }
        
        if index == -1 {
            return http:NotFound("Component with ID " + componentId + " not found");
        }
        
        _ = asset.components.remove(index);
        assetDB[assetTag] = asset.cloneReadOnly();
        
        return http:Ok("Component removed successfully");
    }

    // Add a maintenance schedule to an asset
    resource function post .//[string assetTag]/schedules(@http:Payload MaintenanceSchedule schedule) returns http:Ok|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NotFound("Asset with tag " + assetTag + " not found");
        }
        
        Asset asset = assetDB[assetTag].clone();
        asset.schedules.push(schedule);
        assetDB[assetTag] = asset.cloneReadOnly();
        
        return http:Ok("Maintenance schedule added successfully");
    }

    // Remove a maintenance schedule from an asset
    resource function delete .//[string assetTag]/schedules/[string scheduleId]() returns http:Ok|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NotFound("Asset with tag " + assetTag + " not found");
        }
        
        Asset asset = assetDB[assetTag].clone();
        int index = -1;
        
        foreach int i in 0 ... asset.schedules.length() - 1 {
            if asset.schedules[i].id == scheduleId {
                index = i;
                break;
            }
        }
        
        if index == -1 {
            return http:NotFound("Schedule with ID " + scheduleId + " not found");
        }
        
        _ = asset.schedules.remove(index);
        assetDB[assetTag] = asset.cloneReadOnly();
        
        return http:Ok("Maintenance schedule removed successfully");
    }

    // Add a work order to an asset
    resource function post .//[string assetTag]/workorders(@http:Payload WorkOrder workOrder) returns http:Ok|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NotFound("Asset with tag " + assetTag + " not found");
        }
        
        Asset asset = assetDB[assetTag].clone();
        asset.workOrders.push(workOrder);
        assetDB[assetTag] = asset.cloneReadOnly();
        
        return http:Ok("Work order added successfully");
    }

    // Add a task to a work order
    resource function post .//[string assetTag]/workorders/[string workOrderId]/tasks(@http:Payload Task task) returns http:Ok|http:NotFound {
        if !assetDB.hasKey(assetTag) {
            return http:NotFound("Asset with tag " + assetTag + " not found");
        }
        
        Asset asset = assetDB[assetTag].clone();
        int woIndex = -1;
        
        foreach int i in 0 ... asset.workOrders.length() - 1 {
            if asset.workOrders[i].id == workOrderId {
                woIndex = i;
                break;
            }
        }
        
        if woIndex == -1 {
            return http:NotFound("Work order with ID " + workOrderId + " not found");
        }
        
        asset.workOrders[woIndex].tasks.push(task);
        assetDB[assetTag] = asset.cloneReadOnly();
        
        return http:Ok("Task added successfully");
    }
}