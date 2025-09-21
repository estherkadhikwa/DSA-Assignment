import asset_management.models;

map<models:Asset> assetStore = {};

public function createAsset(models:Asset asset) returns boolean {
    lock {
        if assetStore.hasKey(asset.assetTag) {
            return false;
        }
        assetStore[asset.assetTag] = asset;
        return true;
    }
}

public function getAsset(string assetTag) returns models:Asset? {
    lock {
        return assetStore[assetTag];
    }
}

public function updateAsset(models:Asset asset) {
    lock {
        assetStore[asset.assetTag] = asset;
    }
}

public function removeAsset(string assetTag) returns boolean {
    lock {
        if assetStore.hasKey(assetTag) {
            _ = assetStore.remove(assetTag);
            return true;
        }
    }
    return false;
}

public function getAllAssets() returns models:Asset[] {
    lock {
        models:Asset[] assets = [];
        foreach var [_, asset] in assetStore.entries() {
            _ = assets.push(asset);
        }
        return assets;
    }
}
