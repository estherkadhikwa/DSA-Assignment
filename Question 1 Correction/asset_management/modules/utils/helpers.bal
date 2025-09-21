import ballerina/http;
import ballerina/time;

import asset_management.models;

public function currentDateString() returns string {
    time:Utc now = time:utcNow();
    time:Civil civil = time:utcToCivil(now);
    return string `${civil.year}-${formatTwoDigits(civil.month)}-${formatTwoDigits(civil.day)}`;
}

public function isBlank(string value) returns boolean {
    return value.trim().length() == 0;
}

public function equalsIgnoreCase(string left, string right) returns boolean {
    return left.toLowerAscii() == right.toLowerAscii();
}

public function hasOverdueSchedule(models:Asset asset, string today) returns boolean {
    foreach var schedule in asset.schedules {
        if schedule.nextDueDate < today {
            return true;
        }
    }
    return false;
}

public function hasComponent(models:Asset asset, string componentId) returns boolean {
    foreach var component in asset.components {
        if equalsIgnoreCase(component.id, componentId) {
            return true;
        }
    }
    return false;
}

public function hasSchedule(models:Asset asset, string scheduleId) returns boolean {
    foreach var schedule in asset.schedules {
        if equalsIgnoreCase(schedule.id, scheduleId) {
            return true;
        }
    }
    return false;
}

public function hasWorkOrder(models:Asset asset, string workOrderId) returns boolean {
    return findIndexOfWorkOrder(asset, workOrderId) >= 0;
}

public function hasTask(models:WorkOrder workOrder, string taskId) returns boolean {
    return findIndexOfTask(workOrder, taskId) >= 0;
}

public function findIndexOfComponent(models:Asset asset, string componentId) returns int {
    int idx = 0;
    foreach var component in asset.components {
        if equalsIgnoreCase(component.id, componentId) {
            return idx;
        }
        idx += 1;
    }
    return -1;
}

public function findIndexOfSchedule(models:Asset asset, string scheduleId) returns int {
    int idx = 0;
    foreach var schedule in asset.schedules {
        if equalsIgnoreCase(schedule.id, scheduleId) {
            return idx;
        }
        idx += 1;
    }
    return -1;
}

public function findIndexOfWorkOrder(models:Asset asset, string workOrderId) returns int {
    int idx = 0;
    foreach var workOrder in asset.workOrders {
        if equalsIgnoreCase(workOrder.id, workOrderId) {
            return idx;
        }
        idx += 1;
    }
    return -1;
}

public function findIndexOfTask(models:WorkOrder workOrder, string taskId) returns int {
    int idx = 0;
    foreach var task in workOrder.tasks {
        if equalsIgnoreCase(task.id, taskId) {
            return idx;
        }
        idx += 1;
    }
    return -1;
}

public function cloneComponents(models:Component[] components) returns models:Component[] {
    models:Component[] copy = [];
    foreach var component in components {
        _ = copy.push(component);
    }
    return copy;
}

public function cloneSchedules(models:MaintenanceSchedule[] schedules) returns models:MaintenanceSchedule[] {
    models:MaintenanceSchedule[] copy = [];
    foreach var schedule in schedules {
        _ = copy.push(schedule);
    }
    return copy;
}

public function cloneTasks(models:Task[] tasks) returns models:Task[] {
    models:Task[] copy = [];
    foreach var task in tasks {
        _ = copy.push(task);
    }
    return copy;
}

public function normalizeWorkOrders(models:WorkOrder[] workOrders) returns models:WorkOrder[] {
    models:WorkOrder[] normalized = [];
    foreach var workOrder in workOrders {
        models:WorkOrder normalizedOrder = {
            id: workOrder.id,
            title: workOrder.title,
            description: workOrder.description,
            status: workOrder.status,
            tasks: cloneTasks(workOrder.tasks)
        };
        _ = normalized.push(normalizedOrder);
    }
    return normalized;
}

public function successResponse(string message) returns http:Response {
    http:Response response = new;
    response.statusCode = http:STATUS_OK;
    error? payloadError = response.setJsonPayload({ message: message });
    if payloadError is error {
        panic payloadError;
    }
    return response;
}

public function errorResponse(int status, string message) returns http:Response {
    http:Response response = new;
    response.statusCode = status;
    error? payloadError = response.setJsonPayload({ message: message });
    if payloadError is error {
        panic payloadError;
    }
    return response;
}

function formatTwoDigits(int value) returns string {
    if value < 10 {
        return string `0${value}`;
    }
    return value.toString();
}
