module captur::state;

use captur::subscription::{Self, Subscription};
use sui::table::{Self, Table};

// === Structs ===
public struct State has store {
    subscriptions: Table<address, Subscription>,
}

// === Public-Package Functions ===
public(package) fun new(ctx: &mut TxContext): State {
    let state = State {
        subscriptions: table::new(ctx),
    };
    state
}

public(package) fun subscribe(
    self: &mut State,
    address: address,
    nb_of_epochs: u64,
    ctx: &TxContext,
) {
    self.ensure_subscription(address);
    let subscription = self.subscriptions.borrow_mut(address);
    subscription.extend(nb_of_epochs, ctx);
}

// === Private Functions ===
fun ensure_subscription(self: &mut State, address: address) {
    if (!self.subscriptions.contains(address)) {
        self.subscriptions.add(address, subscription::new(address));
    };
}
