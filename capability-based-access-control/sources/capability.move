module cac::capability;

use std::internal::{Self, Permit};

public struct Capability<phantom P> has key, store {
    id: UID,
    permit: Permit<P>,
    version: u64,
}

public(package) fun new <P>(ctx: &mut TxContext): Capability<P> {
    Capability<P> {
        id: object::new(ctx),
        permit: internal::permit<P>(),
        version: 0,
    }
}

public fun get_version<P>(self: &Capability<P>): u64 {
    self.version
}