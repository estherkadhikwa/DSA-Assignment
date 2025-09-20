import ballerina/http;
import ballerina/io;
import ballerina/time;
import your_username/asset-management-api.types;

const string BASE_URL = "http://localhost:9090/assets";

// Function to create an asset
function createAsset(Asset asset) returns error? {
    http:Client client = check new (BASE_URL);
    http:Response resp = check client->post("/", asset);
    io:println("Create Asset Response: ", resp.statusCode, " - ", resp.getTextPayload());
}

// Function to get all assets
function getAllAssets() returns error? {
    http:Client client = check new (BASE_URL);
    http:Response resp = check client->get("/");
    io:println("Get All Assets Response: ", resp.getJsonPayload());
}

// Function to get asset by tag
function getAssetByTag(string assetTag) returns error? {
    http:Client client = check new (BASE_URL);
    http:Response resp = check client->get("/" + assetTag);
    io:println("Get Asset By Tag Response: ", resp.getJsonPayload());
}

// Function to update asset
function updateAsset(string assetTag, Asset asset) returns error? {
    http:Client client = check new (BASE_URL);
    http:Response resp = check client->put("/" + assetTag, asset);
    io:println("Update Asset Response: ", resp.statusCode, " - ", resp.getTextPayload());
}

// Function to delete asset
function deleteAsset(string assetTag) returns error? {
    http:Client client = check new (BASE_URL);
    http:Response resp = check client->delete("/" + assetTag);
    io:println("Delete Asset Response: ", resp.statusCode, " - ", resp.getTextPayload());
}

// Function to get assets by faculty
function getAssetsByFaculty(string faculty) returns error? {
    http:Client client = check new (BASE_URL);
    http:Response resp = check client->get("/faculty/" + faculty);
    io:println("Get Assets By Faculty Response: ", resp.getJsonPayload());
}

// Function to get overdue assets
function getOverdueAssets() returns error? {
    http:Client client = check new (BASE_URL);
    http:Response resp = check client->get("/maintenance/overdue");
    io:println("Get Overdue Assets Response: ", resp.getJsonPayload());
}

// Function to add a component
function addComponent(string assetTag, Component component) returns error? {
    http:Client client = check new (BASE_URL);
    http:Response resp = check client->post("/" + assetTag + "/components", component);
    io:println("Add Component Response: ", resp.statusCode, " - ", resp.getTextPayload());
}

// Function to add a maintenance schedule
function addSchedule(string assetTag, MaintenanceSchedule schedule) returns error? {
    http:Client client = check new (BASE_URL);
    http:Response resp = check client->post("/" + assetTag + "/schedules", schedule);
    io:println("Add Schedule Response: ", resp.statusCode, " - ", resp.getTextPayload());
}

public function main() returns error? {
    // Example asset
    time:Date acquiredDate = check time:dateFromString("2024-03-10");
    Asset asset = {
        assetTag: "A001",
        name: "Projector",
        faculty: "Engineering",
        department: "Electrical",
        status: ACTIVE,
        acquiredDate: acquiredDate,
        components: [],
        schedules: [],
        workOrders: []
    };

    // Test all operations
    check createAsset(asset);
    check getAllAssets();
    check getAssetByTag("A001");
    
    // Update the asset
    asset.name = "Updated Projector";
    check updateAsset("A001", asset);
    
    check getAssetsByFaculty("Engineering");
    check getOverdueAssets();
    
    // Add a component
    Component component = {
        id: "COMP-001",
        name: "Lens",
        description: "Projector lens component"
    };
    check addComponent("A001", component);
    
    // Add a maintenance schedule
    time:Date nextDueDate = check time:dateFromString("2024-06-15");
    MaintenanceSchedule schedule = {
        id: "SCHED-001",
        description: "Quarterly maintenance",
        frequency: "QUARTERLY",
        nextDueDate: nextDueDate
    };
    check addSchedule("A001", schedule);
    
    // Get asset again to see changes
    check getAssetByTag("A001");
    
    // Finally delete the asset
    check deleteAsset("A001");
    
    io:println("All operations completed successfully!");
}