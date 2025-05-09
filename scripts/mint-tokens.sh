TOKEN_PACKAGE_ID="0xb59c78b60ac25947a203c582792f1cd28f20bf76518d24cb30edd086680df9d4"
TREASURY_CAP_ID="0x9108d0fe1a86ea860a99a6f5bec02dd8bbfe80393c3717fa3ea40bc038972bab"


# mint tokens to yourself
sui client ptb \
--move-call sui::tx_context::sender \
--assign sender \
--move-call $TOKEN_PACKAGE_ID::capt::mint @$TREASURY_CAP_ID 100 sender

# mint tokens to another address
sui client ptb \
--move-call $TOKEN_PACKAGE_ID::capt::mint @$TREASURY_CAP_ID 1000000 @0xa6ede838b7c43ea539e9872fb8e171b1144bc3e59628b92ce2d9284e85029eb3
