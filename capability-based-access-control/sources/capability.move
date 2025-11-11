module cac::capability;

public struct Capability<phantom P> has key, store {
    id: UID,
    version: u64,
}

public fun new<P>(ctx: &mut TxContext): Capability<P> {
    Capability<P> {
        id: object::new(ctx),
        version: 0,
    }
}

public fun get_version<P>(self: &Capability<P>): u64 {
    self.version
}