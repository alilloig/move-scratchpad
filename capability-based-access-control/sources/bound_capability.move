module cac::bound_capability;

public struct BoundCapability<phantom P> has key {
    id: UID,
    version: u64,
}

public fun new<P>(ctx: &mut TxContext): BoundCapability<P> {
    BoundCapability<P> {
        id: object::new(ctx),
        version: 0,
    }
}

public fun get_version<P>(self: &BoundCapability<P>): u64 {
    self.version
}