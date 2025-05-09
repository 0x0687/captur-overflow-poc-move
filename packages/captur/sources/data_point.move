module captur::data_point;

use captur::constants::{new_status, processed_status};
use std::string::String;
use sui::transfer::share_object;
use walrus::blob::Blob;

// === Errors ===
const EDataAlreadyProcessed: u64 = 1;

// === Structs ===
public struct DataPoint has key {
    id: UID,
    sender: address,
    age_range: String,
    gender: String,
    status: String,
    blob: Blob,
    value: u64,
}

// === Public-View Functions ===
public fun id(self: &DataPoint): ID {
    self.id.to_inner()
}

public fun sender(self: &DataPoint): address {
    self.sender
}

public fun status(self: &DataPoint): String {
    self.status
}

public fun is_processed(self: &DataPoint): bool {
    self.status != new_status()
}

// === Public-Package Functions ===
public(package) fun new(
    blob: Blob,
    age_range: String,
    gender: String,
    ctx: &mut TxContext,
): DataPoint {
    let sender = ctx.sender();
    let data = DataPoint {
        id: object::new(ctx),
        sender,
        age_range,
        gender,
        status: new_status(),
        blob: blob,
        value: 0,
    };
    data
}

public(package) fun share(self: DataPoint) {
    share_object(self)
}

public(package) fun process(self: &mut DataPoint, value: u64) {
    assert!(self.status == new_status(), EDataAlreadyProcessed);
    self.status = processed_status();
    self.value = value;
}
