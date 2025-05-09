module captur::captur;

use captur::constants::default_price_per_epoch;
use captur::data_point::{Self, DataPoint};
use captur::vault::{Self, Vault};
use std::string::String;
use sui::coin::Coin;
use sui::event::emit;
use sui::transfer::{share_object, public_transfer};
use token::capt::CAPT;
use walrus::blob::Blob;
use captur::subscription::Subscription;

// === Errors ===
const ENoAccess: u64 = 1;

// === Structs ===
public struct BlobSubmittedEvent has copy, drop {
    capture_id: ID,
    sender: address,
}

public struct DataProcessedEvent has copy, drop {
    capture_id: ID,
    value: u64,
}

public struct Captur has key {
    id: UID,
    vault: Vault,
    price_per_epoch: u64,
}

/// The cap that is used to perform administrator functions.
public struct CapturAdminCap has key, store {
    id: UID,
}

/// The cap that can be used to process user blobs
public struct ProcessingCap has key, store {
    id: UID
}

// OTW
public struct CAPTUR has drop {}

// === Public-View Functinos ===
public fun price_per_epoch(self: &Captur): u64 {
    self.price_per_epoch
}

// === Public-Mutative Functions ===
public fun submit_data(blob: Blob, age_range: String, gender: String, ctx: &mut TxContext) {
    let data = data_point::new(blob, age_range, gender, ctx);

    emit(BlobSubmittedEvent {
        capture_id: data.id(),
        sender: ctx.sender(),
    });

    data_point::share(data);
}

#[allow(lint(self_transfer))]
public fun subscribe(self: &mut Captur, subscription: &mut Subscription, coin: Coin<CAPT>, ctx: &mut TxContext) {
    let mut balance = coin.into_balance();

    // Calculate the maxmimum number of epochs
    let nb_of_epochs = balance.value() / self.price_per_epoch();
    let sender = ctx.sender();
    subscription.extend( nb_of_epochs, ctx);

    // Process the payment in vault
    let price = nb_of_epochs * self.price_per_epoch();
    let payment = balance.split(price).into_coin(ctx);
    self.vault.deposit(payment);

    // Return the remainder if any
    if (balance.value() == 0) {
        balance.destroy_zero();
    } else {
        let remainder = balance.into_coin(ctx);
        public_transfer(remainder, sender);
    }
}

// === Admin Functions ===
public fun deposit(self: &mut Captur, _cap: &CapturAdminCap, coin: Coin<CAPT>) {
    self.vault.deposit(coin);
}

public fun mint_processing_cap(_cap: &CapturAdminCap, ctx: &mut TxContext): ProcessingCap {
    let cap = ProcessingCap {
        id: object::new(ctx)
    };
    cap
}

public fun approve_data(
    self: &mut Captur,
    _cap: &ProcessingCap,
    data_point: &mut DataPoint,
    value: u64,
    ctx: &mut TxContext,
) {
    data_point.process(value);
    // Pay the user
    let coin = self.vault.withdraw(value, ctx);
    public_transfer(coin, data_point.sender());
    // Emit event
    emit(DataProcessedEvent {
        capture_id: data_point.id(),
        value,
    });
}

// === Private Functions ===
fun init(_: CAPTUR, ctx: &mut TxContext) {
    // Create and share a Captur instance
    let captur = Captur {
        id: object::new(ctx),
        vault: vault::empty(),
        price_per_epoch: default_price_per_epoch(),
    };
    share_object(captur);
    // Create and transfer the admin cap
    let admin = CapturAdminCap {
        id: object::new(ctx),
    };
    transfer::public_transfer(admin, ctx.sender());
}

// === Access control ===
/// Processors can only read unprocess data
entry fun seal_approve(_id: vector<u8>, _cap: &ProcessingCap, data: &DataPoint) {
    assert!(!data.is_processed(), ENoAccess);
}