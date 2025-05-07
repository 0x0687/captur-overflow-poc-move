module token::capt;

use sui::coin::{Self, TreasuryCap};

public struct CAPT has drop {}

fun init(witness: CAPT, ctx: &mut TxContext) {
    let (treasury, metadata) = coin::create_currency(
        witness,
        6,
        b"CAPT",
        b"Captur",
        b"Earn by sharing driving data, unlock premium CapturGO features, and vote on network governance.",
        std::option::some<sui::url::Url>(
            sui::url::new_unsafe_from_bytes(
                b"https://captur-overflow-poc-nextjs.vercel.app/captur-icon.avif",
            ),
        ),
        ctx,
    );
    transfer::public_freeze_object(metadata);
    transfer::public_transfer(treasury, ctx.sender())
}

public fun mint(
    treasury_cap: &mut TreasuryCap<CAPT>,
    amount: u64,
    recipient: address,
    ctx: &mut TxContext,
) {
    let coin = coin::mint(treasury_cap, amount, ctx);
    transfer::public_transfer(coin, recipient)
}
