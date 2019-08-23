# OOΠ-Prolog

## Introduzione
 OOΠ-Prolog is a prolog extension to Object Oriented Programming.

## Funcionality
- Class definition and instantiation
- Inheritance
- Polymorphism 
- Overloading

## Limitations
- No support for incapsulation

## Some rules
- Class names or identifiers must be atoms..
- The `new` predicate fails if a non existent member is specified in the initilization.
- `getv` does not check for object integrity, the object passed must be well-formed. `getv` accepts
  object symbols or object representation e.g. ```objectName(class, [Slot|Slots])```

## Compatibility
OOΠ-Prolog was developed and tested on SWI-Prolog.

## Use
Class definition

```prolog
def_class(ClassName, [parent1, parent2], [slot1 = "definition1", slot2 = method([MethodArg1, MethodArgN], (write(MethodArg1), ...))]).
```

Class instatiation

```prolog
new(ObjectName, ClassName, [slot1 = 'slot1Val', slotN = 'slotNVal']).
```

Getter

```prolog
getv(ObjectName, SlotName, SlotValue).
```
