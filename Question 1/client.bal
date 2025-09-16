
import ballerina/http;
import ballerina/io;
import ballerina/time;

// Type definitions (should match service)
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

const string BASE_URL = "http://localhost:9090/assets";

// Example: Create an asset
    http:Client client = check new http:Client(BASE_URL);
    var resp = check client.post(".", asset);
    io:println("Create Asset Response: ", resp.getJsonPayload());
}

// Example: Get all assets
    http:Client client = check new http:Client(BASE_URL);
    var resp = check client.get(".");
    io:println("Get All Assets Response: ", resp.getJsonPayload());
}

// Example: Get asset by tag
    http:Client client = check new http:Client(BASE_URL);
    var resp = check client.get("/" + assetTag);
    io:println("Get Asset By Tag Response: ", resp.getJsonPayload());
}

// Example: Update asset
    http:Client client = check new http:Client(BASE_URL);
    var resp = check client.put("/" + assetTag, asset);
    io:println("Update Asset Response: ", resp.getJsonPayload());
}

// Example: Delete asset
    http:Client client = check new http:Client(BASE_URL);
    var resp = check client.delete("/" + assetTag);
    io:println("Delete Asset Response: ", resp.getJsonPayload());
}

// Example: Get assets by faculty
    http:Client client = check new http:Client(BASE_URL);
    var resp = check client.get("/faculty/" + faculty);
    io:println("Get Assets By Faculty Response: ", resp.getJsonPayload());
}

// Example: Get overdue assets
    http:Client client = check new http:Client(BASE_URL);
    var resp = check client.get("/overdue");
    io:println("Get Overdue Assets Response: ", resp.getJsonPayload());
}

public function main() returns error? {
    // Example asset
    Asset asset = {
        assetTag: "A001",
        name: "Projector",
        faculty: "Engineering",
        department: "Electrical",
        status: Status.ACTIVE,
        acquiredDate: time:currentTime().toDate(),
        components: [],
        schedules: [],
        workOrders: []
    };

    check createAsset(asset);
    check getAllAssets();
    check getAssetByTag("A001");
    check updateAsset("A001", asset);
    check getAssetsByFaculty("Engineering");
    check getOverdueAssets();
    check deleteAsset("A001");
}