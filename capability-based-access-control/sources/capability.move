module cac::capability;

public struct Capability<phantom T, phantom P> has key, store {
    id: UID,
    version: u64,
}

public(package) fun new <T, P>(ctx: &mut TxContext): Capability<T, P> {
    Capability<T, P> {
        id: object::new(ctx),
        version: 0,
    }
}

public fun get_version<T, P>(self: &Capability<T,P>): u64 {
    self.version
}