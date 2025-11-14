module cac::bound_capability;

public struct BoundCapability<phantom T, phantom P> has key {
    id: UID,
    version: u64,
}

public fun new<T, P>(ctx: &mut TxContext): BoundCapability<T, P> {
    BoundCapability<T, P> {
        id: object::new(ctx),
        version: 0,
    }
}

public fun get_version<T, P>(self: &BoundCapability<T, P>): u64 {
    self.version
}