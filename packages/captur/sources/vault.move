module captur::vault;

use sui::balance::{Self, Balance};
use sui::coin::Coin;
use token::capt::CAPT;

// === Errors ===
const EInsufficientBalance: u64 = 1;

// === Structs ===
public struct Vault has store {
    balance: Balance<CAPT>,
}

// === Public-View Functinso ===
public fun balance(self: &Vault): u64 {
    self.balance.value()
}

// === Public-Package Functions ===
public(package) fun empty(): Vault {
    Vault {
        balance: balance::zero(),
    }
}

public(package) fun deposit(self: &mut Vault, coin: Coin<CAPT>) {
    self.balance.join(coin.into_balance());
}

public(package) fun withdraw(self: &mut Vault, amount: u64, ctx: &mut TxContext): Coin<CAPT> {
    assert!(self.balance.value() >= amount, EInsufficientBalance);
    self.balance.split(amount).into_coin(ctx)
}
