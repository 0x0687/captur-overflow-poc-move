module captur::constants;

use std::string::{String, utf8};

// === Constant ===
const DEFAULT_PRICE_PER_EPOCH: u64 = 1_000_000;

// === Public-View Functions ===
public fun new_status(): String {
    utf8(b"New")
}

public fun processed_status(): String {
    utf8(b"Processed")
}

public fun default_price_per_epoch(): u64 {
    DEFAULT_PRICE_PER_EPOCH
}
