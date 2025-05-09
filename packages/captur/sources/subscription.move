module captur::subscription;

// === Errors ===
use captur::data_point::DataPoint;

const EInvalidNumberOfEpochs: u64 = 1;
const ENoAccess: u64 = 2;

// === Structs ===
public struct Subscription has key, store {
    id: UID,
    start_epoch: u64,
    end_epoch: u64,
}

// === Public-Mutative Functions ====
public fun new(ctx: &mut TxContext): Subscription {
    let subscription = Subscription {
        id: object::new(ctx),
        start_epoch: 0,
        end_epoch: 0,
    };
    subscription
}

public fun is_active(self: &Subscription, ctx: &TxContext): bool {
    let current_epoch = ctx.epoch();
    self.end_epoch >= current_epoch
}

// === Public-Package Functinos ===
public(package) fun extend(self: &mut Subscription, nb_of_epochs: u64, ctx: &TxContext) {
    // You need to subscribe for at least 1 epoch
    assert!(nb_of_epochs > 0, EInvalidNumberOfEpochs);

    let current_epoch = ctx.epoch();
    if (self.end_epoch < current_epoch) {
        // There is currently no active subscription
        self.start_epoch = current_epoch;
        self.end_epoch = current_epoch + nb_of_epochs - 1; // Current epoch also counts
    } else {
        // There is an ongoing subscription
        self.end_epoch = self.end_epoch + nb_of_epochs;
    }
}


// === Access control ===
/// Subscribers can only read processed data
entry fun seal_approve(_id: vector<u8>, subscription: &Subscription, data: &DataPoint, ctx: &TxContext) {
    // Processors can only read unprocess data
    assert!(data.is_processed() && subscription.is_active(ctx), ENoAccess);
}