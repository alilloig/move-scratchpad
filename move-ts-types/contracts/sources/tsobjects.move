module tsobjects::tsobjects;

use std::string::String;

public struct Outer has key, store {
    id: UID,
    inner: Inner,
}

public struct Inner has key, store {
    id: UID,
    name: String,
    count: u64,
}

fun init(ctx: &mut TxContext) {
    let object = Outer {
        id: object::new(ctx),
        inner: Inner {
            id: object::new(ctx),
            name: "Inner Object",
            count: 0,
        },
    };
    transfer::transfer(object, ctx.sender());
}