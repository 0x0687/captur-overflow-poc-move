#[test_only]
module captur::vault_tests;

use captur::vault;
use sui::coin::mint_for_testing;
use sui::test_scenario::begin;
use sui::test_utils::destroy;
use token::capt::CAPT;

#[test]
public fun deposit_withdraw_ok() {
    let addr = @0xA;
    let mut scenario = begin(addr);

    // Create empty vault
    let mut vault = vault::empty();
    assert!(vault.balance() == 0);

    // Deposit 100
    let deposit = mint_for_testing<CAPT>(100, scenario.ctx());
    vault.deposit(deposit);
    assert!(vault.balance() == 100);

    // Withdraw 20
    let withdraw1 = vault.withdraw(20, scenario.ctx());
    assert!(vault.balance() == 80);

    // Deposit 20
    let deposit = mint_for_testing<CAPT>(20, scenario.ctx());
    vault.deposit(deposit);
    assert!(vault.balance() == 100);

    // Deposit 20
    let deposit = mint_for_testing<CAPT>(20, scenario.ctx());
    vault.deposit(deposit);
    assert!(vault.balance() == 120);

    // Withdraw all
    let withdraw2 = vault.withdraw(120, scenario.ctx());
    assert!(vault.balance() == 0);

    destroy(vault);
    destroy(withdraw1);
    destroy(withdraw2);
    scenario.end();
}

#[test, expected_failure(abort_code = vault::EInsufficientBalance)]
public fun withdraw_not_enough_funds() { let addr = @0xA; let mut scenario = begin(addr); {
        // Create empty vault
        let mut vault = vault::empty();
        assert!(vault.balance() == 0);

        // Fund vault
        let deposit_balance = mint_for_testing<CAPT>(100, scenario.ctx());
        vault.deposit(deposit_balance);
        assert!(vault.balance() == 100);

        // Activate game
        let _coin = vault.withdraw(101, scenario.ctx());
        abort 0
    } }
