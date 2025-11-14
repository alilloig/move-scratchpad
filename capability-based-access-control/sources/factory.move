module cac::factory;

use std::type_name::{Self, TypeName};
use sui::package::{Self, Publisher};
use sui::vec_map::{Self, VecMap};
use cac::capability::{Self, Capability};
use cac::bound_capability::{Self, BoundCapability};

/// Abort code for invalid capability type.
const ENotOwner: u64 = 0;
/// Abort code for invalid permission.
const EInvalidPermission: u64 = 1;

// A shared object that only the publisher of a module can create. 
// Manages the issuance of capabilities of a certain permission typename P for a given type T.
// Keeps track of the version of each permission.
public struct CapabilityFactory<phantom T> has key, store {
    id: UID,
    perms: VecMap<TypeName, u64>,
}

// The capability that grants the ability to issue and revoke capabilities for a given type T.
public struct CapabilityFactoryCap<phantom T> has key, store {
    id: UID,
    factory_id: ID,
}

// Creates and returns a new CapabilityFactory for a given type T and its corresponding CapabilityFactoryCap.
public fun new<T>(pub: &Publisher, ctx: &mut TxContext): (CapabilityFactory<T>, CapabilityFactoryCap<T>) {
    // Only the package publisher can create a CapabilityFactory for any T type defined in the package.
    assert!(package::from_package<T>(pub), ENotOwner);
    let factory = CapabilityFactory<T> {
        id: object::new(ctx),
        perms: vec_map::empty<TypeName, u64>(),
    };
    let cap = CapabilityFactoryCap<T> {
        id: object::new(ctx),
        factory_id: object::id(&factory),
    };
    (factory, cap)
}

#[allow(lint(self_transfer, share_owned))]
// Auxiliary method for quick storage of factory and cap
entry fun default<T>(pub: &Publisher, ctx: &mut TxContext) {
    let (factory, cap) = new<T>(pub, ctx);
    transfer::share_object(factory);
    transfer::transfer(cap, ctx.sender());
}

// Adds a new permission to the CapabilityFactory. Insert aborts if the permission already exists.
public fun add_permission<T>(self: &mut CapabilityFactory<T>, _cap: &CapabilityFactoryCap<T>, perm: TypeName) {
    self.perms.insert(perm, 0);
}

// Removes a permission from the CapabilityFactory. Remove aborts if the permission does not exist.
public fun remove_permission<T>(self: &mut CapabilityFactory<T>, _cap: &CapabilityFactoryCap<T>, perm: TypeName) {
    self.perms.remove(&perm);
}

// Get the permissions along with their versions.
public fun get_permissions<T>(self: &CapabilityFactory<T>): VecMap<TypeName, u64> {
    self.perms
}

// Issues a new capability for a recipient address.
public fun issue_capability<T, P>(
    self: &CapabilityFactory<T>, 
    _cap: &CapabilityFactoryCap<T>, 
    ctx: &mut TxContext
): Capability<T, P> {
    // Check if the permission is valid
    assert!(self.perms.contains(&type_name::with_defining_ids<P>()), EInvalidPermission);
    // Issue a new capability
    capability::new<T, P>(ctx)
}

// Pumps the version of the permission so previously issued capabilities are invalidated.
public fun revoke_capability<T, P>(
    self: &mut CapabilityFactory<T>, 
    _cap: &CapabilityFactoryCap<T>, 
) {
    // Check if the permission is valid
    assert!(self.perms.contains(&type_name::with_defining_ids<P>()), EInvalidPermission);
    // Pump the version of the permission
    let capability_version = self.perms.get_mut(&type_name::with_defining_ids<P>());
    *capability_version = *capability_version + 1;
}

// Issues a new capability for a recipient address.
public fun issue_bound_capability<T, P>(
    self: &CapabilityFactory<T>, 
    _cap: &CapabilityFactoryCap<T>,
    ctx: &mut TxContext
): BoundCapability<T, P> {
    // Check if the permission is valid
    assert!(self.perms.contains(&type_name::with_defining_ids<P>()), EInvalidPermission);
    // Issue a new capability
    bound_capability::new<T, P>(ctx)
}