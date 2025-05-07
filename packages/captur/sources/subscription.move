module captur::subscription;

// === Errors ===
const EInvalidNumberOfEpochs: u64 = 1;

// === Structs ===
public struct Subscription has store {
    address: address,
    start_epoch: u64,
    end_epoch: u64,
}

// === Public-Package Functinos ===
public(package) fun new(address: address): Subscription {
    let subscription = Subscription {
        address,
        start_epoch: 0,
        end_epoch: 0,
    };
    subscription
}

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
