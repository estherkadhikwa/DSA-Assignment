import ballerina/http;
import ballerina/io;
public function main() returns error? {
    http:Client assetClient = check new ("http://localhost:9090/assets", {
        timeout: 5
    });

    string assetTag = "EQ-001";

    json createAssetRequest = {
        assetTag: assetTag,
        name: "3D Printer",
        faculty: "Computing & Informatics",
        department: "Software Engineering",
        status: "ACTIVE",
        acquiredDate: "2024-03-10",
        components: [],
        schedules: [],
        workOrders: []
    };

    io:println("Creating asset...");
    json createdAsset = check assetClient->post("/", createAssetRequest, targetType = json);
    printJson("Created asset", createdAsset);

    json updateAssetRequest = {
        status: "UNDER_REPAIR"
    };
    io:println("Updating asset status...");
    json updatedAsset = check assetClient->put(string `/${assetTag}`, updateAssetRequest, targetType = json);
    printJson("Updated asset", updatedAsset);

    json componentRequest = {
        id: "COMP-001",
        name: "Extruder",
        description: "Replacement extruder assembly"
    };
    io:println("Adding component...");
    json addedComponent = check assetClient->post(string `/${assetTag}/components`, componentRequest, targetType = json);
    printJson("Added component", addedComponent);

    json scheduleRequest = {
        id: "SCH-001",
        description: "Quarterly maintenance",
        frequency: "Quarterly",
        nextDueDate: "2024-01-01"
    };
    io:println("Adding maintenance schedule...");
    json addedSchedule = check assetClient->post(string `/${assetTag}/schedules`, scheduleRequest, targetType = json);
    printJson("Added schedule", addedSchedule);

    io:println("Fetching all assets...");
    json allAssets = check assetClient->get("/", targetType = json);
    printJson("All assets", allAssets);

    io:println("Fetching assets for faculty...");
    json facultyAssets = check assetClient->get("/?faculty=Computing%20%26%20Informatics", targetType = json);
    printJson("Assets for Computing & Informatics", facultyAssets);

    io:println("Checking overdue schedules...");
    json overdueAssets = check assetClient->get("/overdue", targetType = json);
    printJson("Overdue assets", overdueAssets);
}

function printJson(string title, json payload) {
    io:println(title);
    io:println(payload);
    io:println();
}

{
    
}
