# OOΠ-Prolog

## Autori
- Ali Farjad (829940)

## Introduzione
 OOΠ-Prolog è un'estensione Object-Oriented a Prolog

## Funzionalità
- Definizione e istanziazione di classi
- Ereditarietà
- Polimorfismo
- Overloading

## Limitazioni
- Il supporto all'overloading ha un suo costo
- Nessun supporto all'incapsulamento (Di facile implementazione)
- Diamond Problem (Risolto automaticamente utilizzando gli override delle superclassi che compaiono
  prima nella parent list)

## Specifiche Integrative
- I nomi di classi o identificatori di slots devono essere atomi.
- Se durante l'inizializzazione dei slot viene rilevato uno slot non definito nell class,
  il predicato fallisce.
- `getv` non controlla l'integrità dell'oggeto passato, si assume che sia ben formato. getv 
  accetta sia simboli che oggetti veri e propri nella forma ```nomeoggetto(classe, [Slot|Slots])```
- TODO Limitazioni overloading

## Compatibilità
OOΠ-Prolog è stato sviluppato e testato su SWI-Prolog.

## Utilizzo
```prolog
def_class(student, [parent1, parent2], [slot1 = "definition1", slot2 = method([MethodArg1, MethodArgN], (write(MethodArg1), ...))])
```