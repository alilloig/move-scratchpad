# Capability-based Access Control
This package attempts to showcase how to enforce permissions based access control using [capability](https://en.wikipedia.org/wiki/Capability-based_security) objects, rather than mapping addresses to permissions.
This implementation allows revoking capabilities by tying them to a version number that can be pumped by the Admin to revoke all previously issued capabilities for a certain permission. This permissions can be used for restricting access to shared objects methods and for restricting it to other contract's `public fun`s.

Since it does not attempt to manage permissions based on addresses, mind that a capability cannot be revoked for a specific actor, but rather for the the whole permission `P`. If for any product reasons anyone would like to implement actor based revocation, a ledger will be needed, tracking capabilities `UID`s rather than addresses.

## Modules

### Capability Factory
The meat and potatoes of this package, allowing only the publisher of a module defining a type `T` to specify permissions `P` for performing actions on it, and to issue and revoke `Capability<P>`.
`CapabilityFactory<phantom T>` is the object that allows the holder of `CapabilityFactoryCap<phantom T>` to create a new permission with `add_permission<T>`, delete it with `remove_permission<T>`. Also to grant access to the action defined by the permission by `issue_capability<T, P>` or restrict back by `revoke_capability<T, P>`.

### Capability
Defines a simple capability object with the addition of a `version` field that enables revoking capabilities.

### Capability Hero
A dummy module consuming capabilities as an example of how to use them.
The admin of the module can grant any account the ability to mint new shared `Hero` objects. They can also grant permissions for mutating those objects and revoke those permissions.

#### (Bonus) Bound Capability
At this point you should have realized I'm quite against checking `msg.sender` in any way, but if you are into that, a `BoundCapability` has no `store` ability, so you can issue it with `factory::issue_bound_capability<T, P>` and whoever stores it will keep it forever.

#### TBD
1. Restore a capability after it has been revoked
1. Restrict capabilities per Hero (now a capability holder could do `P` on any shared hero)
