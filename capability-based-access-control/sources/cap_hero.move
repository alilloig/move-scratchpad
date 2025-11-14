module cac::cap_hero;

use std::type_name::{Self, TypeName};
use sui::package::{Self, Publisher};
use sui::vec_map::{Self, VecMap};
use cac::capability::{Capability};
use cac::factory::{Self, CapabilityFactory, CapabilityFactoryCap};

/// Abort code for not a minter.
const ENotMinter: u64 = 0;
/// Abort code for not a level up.
const ENotLevelUp: u64 = 1;
/// Abort code for not an increase HP.
const ENotIncreaseHP: u64 = 2;
/// Abort code for not an increase attack.
const ENotIncreaseAttack: u64 = 3;
/// Abort code for not an increase defense.
const ENotIncreaseDefense: u64 = 4;
/// Abort code for not an increase speed.
const ENotIncreaseSpeed: u64 = 5;
/// Abort code for not a burn.
const ENotBurn: u64 = 6;

// Permissions Types
public struct Mint {}
public struct LevelUp {}
public struct IncreaseHP {}
public struct IncreaseAttack {}
public struct IncreaseDefense {}
public struct IncreaseSpeed {}
public struct Burn {}

// OTW
public struct CAP_HERO has drop {}

// A dummy object for showcasing versioned permissions.
public struct Hero has key, store {
    id: UID,
    level: u64,
    hp: u64,
    attack: u64,
    defense: u64,
    speed: u64,
    cap_vers: VecMap<TypeName, u64>,
}

#[allow(lint(share_owned))]
// On init, we create a new CapabilityFactory for the Hero type and add the permissions to it.
fun init (otw: CAP_HERO, ctx: &mut TxContext) {
    // Claim the Publisher object.
    let publisher: Publisher = package::claim(otw, ctx);
    // Create a new CapabilityFactory, share it and transfer its capability to the publishing address
    let (mut factory, cap) = factory::new<Hero>(&publisher, ctx);
    // Add the permissions to the factory
    factory.add_permission<Hero>(&cap, type_name::with_defining_ids<Mint>());
    factory.add_permission<Hero>(&cap, type_name::with_defining_ids<LevelUp>());  
    factory.add_permission<Hero>(&cap, type_name::with_defining_ids<IncreaseHP>());
    factory.add_permission<Hero>(&cap, type_name::with_defining_ids<IncreaseAttack>());
    factory.add_permission<Hero>(&cap, type_name::with_defining_ids<IncreaseDefense>());
    factory.add_permission<Hero>(&cap, type_name::with_defining_ids<IncreaseSpeed>());
    factory.add_permission<Hero>(&cap, type_name::with_defining_ids<Burn>());
    // Share the factory and transfer its capability to the publishing address
    transfer::public_share_object(factory);
    transfer::public_transfer(cap, ctx.sender());
    // Send the publisher to the publishing address
    transfer::public_transfer(publisher, ctx.sender()); 
}

// Mints and shares a new Hero bc is controlled by a DAO or something idk so it needs to be shared.
public fun mint_hero(cap: &Capability<Hero, Mint>, factory: &CapabilityFactory<Hero>, ctx: &mut TxContext) {
    // Check if the mint capability is in effect.
    assert!(cap.get_version() == factory.get_permissions().get(&type_name::with_defining_ids<Mint>()), ENotMinter);
    let hero = Hero {
        id: object::new(ctx),
        level: 1,
        hp: 100,
        attack: 10,
        defense: 10,
        speed: 10,
        cap_vers: factory.get_permissions(),
    };
    transfer::public_share_object(hero);
}

public fun level_up(self: &mut Hero, cap: &Capability<Hero, LevelUp>) {
    assert!(cap.get_version() == self.cap_vers.get(&type_name::with_defining_ids<LevelUp>()), ENotLevelUp);
    self.level = self.level + 1;
}

public fun increase_hp(self: &mut Hero, cap: &Capability<Hero, IncreaseHP>) {
    assert!(cap.get_version() == self.cap_vers.get(&type_name::with_defining_ids<IncreaseHP>()), ENotIncreaseHP);
    self.hp = self.hp + 10;
}

public fun increase_attack(self: &mut Hero, cap: &Capability<Hero, IncreaseAttack>) {
    assert!(cap.get_version() == self.cap_vers.get(&type_name::with_defining_ids<IncreaseAttack>()), ENotIncreaseAttack);
    self.attack = self.attack + 1;
}

public fun increase_defense(self: &mut Hero, cap: &Capability<Hero, IncreaseDefense>) {
    assert!(cap.get_version() == self.cap_vers.get(&type_name::with_defining_ids<IncreaseDefense>()), ENotIncreaseDefense);
    self.defense = self.defense + 1;
}

public fun increase_speed(self: &mut Hero, cap: &Capability<Hero, IncreaseSpeed>) {
    assert!(cap.get_version() == self.cap_vers.get(&type_name::with_defining_ids<IncreaseSpeed>()), ENotIncreaseSpeed);
    self.speed = self.speed + 1;
}

public fun burn(self: Hero, cap: &Capability<Hero, Burn>) {
    assert!(cap.get_version() == self.cap_vers.get(&type_name::with_defining_ids<Burn>()), ENotBurn);
    let Hero { id, level, hp, attack, defense, speed, cap_vers } = self;
    id.delete();
}

// Issues a new capability for the recipient to perform the given permission P on Hero objects.
public fun issue_capability<P>(
    self: &CapabilityFactory<Hero>, 
    _cap: &CapabilityFactoryCap<Hero>,
    recipient: address,
    ctx: &mut TxContext
) {
    let cap = factory::issue_capability<Hero, P>(
        self, 
        _cap,
        ctx
    );
    transfer::public_transfer(cap, recipient);
}

// Revokes a capability for the given permission P by pumping the version of the permission
// both in the Hero and in the CapabilityFactory objects.
public fun revoke_capability<P>(
    self: &mut Hero,
    factory: &mut CapabilityFactory<Hero>, 
    _cap: &CapabilityFactoryCap<Hero>,
) {
    // Pump the version of the permission P in the Hero object.
    let hero_cap_ver = self.cap_vers.get_mut(&type_name::with_defining_ids<P>());
    *hero_cap_ver = *hero_cap_ver + 1;
    // Pump the version of the permission P in the CapabilityFactory object.
    factory.revoke_capability<Hero, P>(_cap);
}