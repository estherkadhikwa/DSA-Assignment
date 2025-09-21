import ballerina/http;

import asset_management.models;
import asset_management.storage;
import asset_management.utils;

service /assets on new http:Listener(9090) {

    resource function post .(@http:Payload models:AssetCreateRequest newAsset) returns models:Asset|http:Response {
        models:Asset asset = {
            assetTag: newAsset.assetTag,
            name: newAsset.name,
            faculty: newAsset.faculty,
            department: newAsset.department,
            status: newAsset.status,
            acquiredDate: newAsset.acquiredDate,
            components: utils:cloneComponents(newAsset.components ?: []),
            schedules: utils:cloneSchedules(newAsset.schedules ?: []),
            workOrders: utils:normalizeWorkOrders(newAsset.workOrders ?: [])
        };

        if storage:createAsset(asset) {
            return asset;
        }
        return utils:errorResponse(http:STATUS_CONFLICT, "Asset already exists");
    }

    resource function get .(@http:Query string? faculty) returns models:Asset[] {
        models:Asset[] assets = [];
        foreach var asset in storage:getAllAssets() {
            if faculty is string && !utils:equalsIgnoreCase(asset.faculty, faculty) {
                continue;
            }
            _ = assets.push(asset);
        }
        return assets;
    }

    resource function get overdue() returns models:Asset[] {
        string today = utils:currentDateString();
        models:Asset[] overdue = [];
        foreach var asset in storage:getAllAssets() {
            if utils:hasOverdueSchedule(asset, today) {
                _ = overdue.push(asset);
            }
        }
        return overdue;
    }

    resource function get [string assetTag]() returns models:Asset|http:Response {
        models:Asset? asset = storage:getAsset(assetTag);
        if asset is models:Asset {
            return asset;
        }
        return utils:errorResponse(http:STATUS_NOT_FOUND, "Asset not found");
    }

    resource function put [string assetTag](@http:Payload models:AssetUpdateRequest update) returns models:Asset|http:Response {
        models:Asset? asset = storage:getAsset(assetTag);
        if asset is models:Asset {
            if update.name is string {
                asset.name = <string>update.name;
            }
            if update.faculty is string {
                asset.faculty = <string>update.faculty;
            }
            if update.department is string {
                asset.department = <string>update.department;
            }
            if update.status is models:AssetStatus {
                asset.status = <models:AssetStatus>update.status;
            }
            if update.acquiredDate is string {
                asset.acquiredDate = <string>update.acquiredDate;
            }
            storage:updateAsset(asset);
            return asset;
        }
        return utils:errorResponse(http:STATUS_NOT_FOUND, "Asset not found");
    }

    resource function delete [string assetTag]() returns http:Response {
        if storage:removeAsset(assetTag) {
            return utils:successResponse("Asset removed");
        }
        return utils:errorResponse(http:STATUS_NOT_FOUND, "Asset not found");
    }

    resource function post [string assetTag]/components(@http:Payload models:Component component) returns models:Component|http:Response {
        if utils:isBlank(component.id) {
            return utils:errorResponse(http:STATUS_BAD_REQUEST, "Component id is required");
        }

        models:Asset? asset = storage:getAsset(assetTag);
        if asset is models:Asset {
            if utils:hasComponent(asset, component.id) {
                return utils:errorResponse(http:STATUS_CONFLICT, "Component already exists");
            }
            _ = asset.components.push(component);
            storage:updateAsset(asset);
            return component;
        }
        return utils:errorResponse(http:STATUS_NOT_FOUND, "Asset not found");
    }

    resource function delete [string assetTag]/components/[string componentId]() returns http:Response {
        models:Asset? asset = storage:getAsset(assetTag);
        if asset is models:Asset {
            int index = utils:findIndexOfComponent(asset, componentId);
            if index >= 0 {
                _ = asset.components.remove(index);
                storage:updateAsset(asset);
                return utils:successResponse("Component removed");
            }
            return utils:errorResponse(http:STATUS_NOT_FOUND, "Component not found");
        }
        return utils:errorResponse(http:STATUS_NOT_FOUND, "Asset not found");
    }

    resource function post [string assetTag]/schedules(@http:Payload models:MaintenanceSchedule schedule) returns models:MaintenanceSchedule|http:Response {
        if utils:isBlank(schedule.id) {
            return utils:errorResponse(http:STATUS_BAD_REQUEST, "Schedule id is required");
        }

        models:Asset? asset = storage:getAsset(assetTag);
        if asset is models:Asset {
            if utils:hasSchedule(asset, schedule.id) {
                return utils:errorResponse(http:STATUS_CONFLICT, "Schedule already exists");
            }
            _ = asset.schedules.push(schedule);
            storage:updateAsset(asset);
            return schedule;
        }
        return utils:errorResponse(http:STATUS_NOT_FOUND, "Asset not found");
    }

    resource function delete [string assetTag]/schedules/[string scheduleId]() returns http:Response {
        models:Asset? asset = storage:getAsset(assetTag);
        if asset is models:Asset {
            int index = utils:findIndexOfSchedule(asset, scheduleId);
            if index >= 0 {
                _ = asset.schedules.remove(index);
                storage:updateAsset(asset);
                return utils:successResponse("Schedule removed");
            }
            return utils:errorResponse(http:STATUS_NOT_FOUND, "Schedule not found");
        }
        return utils:errorResponse(http:STATUS_NOT_FOUND, "Asset not found");
    }

    resource function post [string assetTag]/workOrders(@http:Payload models:WorkOrderCreateRequest workOrderReq) returns models:WorkOrder|http:Response {
        if utils:isBlank(workOrderReq.id) {
            return utils:errorResponse(http:STATUS_BAD_REQUEST, "Work order id is required");
        }

        models:Asset? asset = storage:getAsset(assetTag);
        if asset is models:Asset {
            if utils:hasWorkOrder(asset, workOrderReq.id) {
                return utils:errorResponse(http:STATUS_CONFLICT, "Work order already exists");
            }
            models:WorkOrder workOrder = {
                id: workOrderReq.id,
                title: workOrderReq.title,
                description: workOrderReq.description,
                status: workOrderReq.status,
                tasks: utils:cloneTasks(workOrderReq.tasks ?: [])
            };
            _ = asset.workOrders.push(workOrder);
            storage:updateAsset(asset);
            return workOrder;
        }
        return utils:errorResponse(http:STATUS_NOT_FOUND, "Asset not found");
    }

    resource function put [string assetTag]/workOrders/[string workOrderId](@http:Payload models:WorkOrderUpdateRequest update) returns models:WorkOrder|http:Response {
        models:Asset? asset = storage:getAsset(assetTag);
        if asset is models:Asset {
            int index = utils:findIndexOfWorkOrder(asset, workOrderId);
            if index >= 0 {
                models:WorkOrder workOrder = asset.workOrders[index];
                if update.title is string {
                    workOrder.title = <string>update.title;
                }
                if update.description is string {
                    workOrder.description = <string>update.description;
                }
                if update.status is models:WorkOrderStatus {
                    workOrder.status = <models:WorkOrderStatus>update.status;
                }
                asset.workOrders[index] = workOrder;
                storage:updateAsset(asset);
                return workOrder;
            }
            return utils:errorResponse(http:STATUS_NOT_FOUND, "Work order not found");
        }
        return utils:errorResponse(http:STATUS_NOT_FOUND, "Asset not found");
    }

    resource function post [string assetTag]/workOrders/[string workOrderId]/tasks(@http:Payload models:Task task) returns models:Task|http:Response {
        if utils:isBlank(task.id) {
            return utils:errorResponse(http:STATUS_BAD_REQUEST, "Task id is required");
        }

        models:Asset? asset = storage:getAsset(assetTag);
        if asset is models:Asset {
            int workOrderIdx = utils:findIndexOfWorkOrder(asset, workOrderId);
            if workOrderIdx >= 0 {
                models:WorkOrder workOrder = asset.workOrders[workOrderIdx];
                if utils:hasTask(workOrder, task.id) {
                    return utils:errorResponse(http:STATUS_CONFLICT, "Task already exists");
                }
                _ = workOrder.tasks.push(task);
                asset.workOrders[workOrderIdx] = workOrder;
                storage:updateAsset(asset);
                return task;
            }
            return utils:errorResponse(http:STATUS_NOT_FOUND, "Work order not found");
        }
        return utils:errorResponse(http:STATUS_NOT_FOUND, "Asset not found");
    }

    resource function delete [string assetTag]/workOrders/[string workOrderId]/tasks/[string taskId]() returns http:Response {
        models:Asset? asset = storage:getAsset(assetTag);
        if asset is models:Asset {
            int workOrderIdx = utils:findIndexOfWorkOrder(asset, workOrderId);
            if workOrderIdx >= 0 {
                models:WorkOrder workOrder = asset.workOrders[workOrderIdx];
                int taskIdx = utils:findIndexOfTask(workOrder, taskId);
                if taskIdx >= 0 {
                    _ = workOrder.tasks.remove(taskIdx);
                    asset.workOrders[workOrderIdx] = workOrder;
                    storage:updateAsset(asset);
                    return utils:successResponse("Task removed");
                }
                return utils:errorResponse(http:STATUS_NOT_FOUND, "Task not found");
            }
            return utils:errorResponse(http:STATUS_NOT_FOUND, "Work order not found");
        }
        return utils:errorResponse(http:STATUS_NOT_FOUND, "Asset not found");
    }
}
