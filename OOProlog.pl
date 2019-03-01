%Farjad ali 829940

%%%True if list has only defined classes.
is_valid_parents([]) :- !.
is_valid_parents([Parent1|Parents]) :- Goal =.. [Parent1, P1P, Attribs],
                                       clause(Goal, _),
                                       call(Goal),
                                       is_list(P1P),
                                       is_list(Attribs),
                                       is_valid_parents(Parents).

%%%True il list has only atomic elements
atomic_list([]).
atomic_list([X|T]) :- atomic(X), atomic_list(T).

%%%True if Arg1 has Arg2 at index Arg3
indexOf([Element|_], Element, 0):- !.
indexOf([_|Tail], Element, Index):-
  indexOf(Tail, Element, Index1),
  !,
  Index is Index1+1.

%%%True if Slot has indentifier Name and value Value
get_slot(Slot, Name, Value) :-  term_to_atom(Slot, A),
                                atom_chars(A, L),
                                indexOf(L, =, H),
                                sub_atom(A, 0, H, J, Name_),
                                HN is (H+1), JN is (J-1),
                                sub_atom(A, HN, JN, 0, Value_),
                                term_to_atom(Name, Name_),
                                term_to_atom(Value, Value_).

%%%Applies get_slot to a list gives a list of identifiers
%%%and its values                        
get_slots([],[],[]).
get_slots([First|Rest], [FirstName|RestNames], [FirstValue|RestValues]) :-
            get_slot(First, FirstName, FirstValue),
            get_slots(Rest, RestNames, RestValues).

%%%Given a class (and Attributes of the class),
%%%this predicate build every method it finds in
%%%the class definition attributes, the reason we do 
%%%this here and not in the instantiation of an object 
%%%is that a user can redefine methods in new, so it must
%%%be made sure that default methods always exist.
build_class_methods(Class) :-
        get_attribs([Class], Attribs),
        build_method_list(Class, Attribs).
build_class_methods(Class, Attribs) :- 
        build_method_list(Class, Attribs).

%%%Define a class given name and attributes of it,
%%%it first makes sure that name and slots are valid,
%%%and finally builds its methods.
def_class(Name, Parents, Slots) :-  get_slots(Slots, Names, _),
                                    atomic_list(Names),
                                    atomic_list(Parents),
                                    is_valid_parents(Parents),
                                    Class =.. [Name, Parents, Slots],
                                    abolish(Name, 2),
                                    asserta(Class),
                                    build_class_methods(Name, Slots).

%%%Replaces an atom within a term
replace(Subterm0, Subterm, Term0, Term) :- 
            Term0 == Subterm0 -> Term = Subterm.
replace(_,  _, Term0, Term) :- 
            var(Term0) -> Term = Term0.
replace(Subterm0, Subterm, Term0, Term) :- 
            Term0 =.. [F|Args0],
            maplist(replace(Subterm0,Subterm), Args0, Args),
            Term =.. [F|Args], !.

%%%True if Arg1 is a class that has Arg2 as attributes
get_attribs([], []) :- !.
get_attribs([Class|RClass], NAttrib) :-
        Goal =.. [Class, NClass, Attrib],
        clause(Goal, _),
        call(Goal),
        is_list(Attrib),
        is_list(NClass),
        append(NClass, RClass, FClass),
        get_attribs(FClass, Rest),
        append(Attrib, Rest, NAttrib).

%%%True if Arg1 is a list of attributes and Arg2 is a
%%%list with its identifiers.
split_id([], []) :- !.
split_id([Slot|RSlot], [Id|RId]) :-
        Slot =.. [=, Id, _],
        split_id(RSlot, RId).

%%%True if Arg1 is in list Arg2    
in_list(_, []) :- !.
in_list(Base, [X|T]) :-
        member(X, Base),
        in_list(Base, T).

%%%Converts a list to a set in a stable way  
list_to_set(_, [], []) :- !.  
list_to_set(Dict, [X|T], TN) :-
        X =.. [_, N | _],
        member(N, Dict),
        list_to_set(Dict, T, TN),
        !.
list_to_set(Dict, [X|T], [X|TN]) :-
        X =.. [_, N | _],
        append(Dict, [N], DictN),
        list_to_set(DictN, T, TN).

%%%True if Instance if an instance of Class
instance_of(Instance, Class) :-
        atom(Instance),
        Goal =.. [Instance, Class, Attribs],
        clause(Goal, _),
        call(Goal).
instance_of(Instance, Class) :-
        compound(Instance),
        Instance =.. [_, Class, _].

%%%True if instance has an attribute with value Val
%%%and indentifier Slot
getv(Instance, Slot, Val) :-
            atom(Instance),
            Goal =.. [Instance, Class, Slots],
            Var =.. [=, Slot, Val],
            clause(Goal, _),
            call(Goal),
            atom(Class),
            member(Var, Slots),
            !.
getv(Goal, Slot, Val) :-
            compound(Goal),
            Goal =.. [_, Class, Slots],
            atom(Class),
            Var =.. [=, Slot, Val],
            member(Var, Slots).

%%%Same function of getv applied to multiple objects
getvx(R, [], R) :- !.
getvx(Instance, [Slot|RSlots], R) :-
        getv(Instance, Slot, V),
        getvx(V, RSlots, R).

%%%Build a method given its name, class, arguments (Arg2) and
%%%the definition of the method is in Goal.
build_method(FinalMethodName, Class, Arg2, Goal) :-
        Head =.. [FinalMethodName, Caller | Arg2],
        Goal =.. [:-, Head, (instance_of(Caller, Class), 
                        getv(Caller, FinalMethodName, Val), 
                    replace(this, Caller, Val, NVal), NVal =.. [method, Args, Code],
                     Args = Arg2, call(Code), !)],
        asserta(Goal).

%%%Does the same thing build_method does but adds a clause to the 
%%%method in order to be sure that only objects that have defined
%%%this method can use it
build_method_custom(FinalMethodName, Class, ObjectName, Arg2, Goal) :-
        Head =.. [FinalMethodName, Caller | Arg2],
        Goal =.. [:-, Head, (instance_of(Caller, Class),
                        Caller =.. [CallerName|_],
                        CallerName = ObjectName, 
                        getv(Caller, FinalMethodName, Val), 
                    replace(this, Caller, Val, NVal), NVal =.. [method, Args, Code],
                     Args = Arg2, call(Code), !)],
        asserta(Goal).
    
%%%Build method applied to a list of slots, the slots can either
%%%be simple values of methods, it ignores the slot if it's the
%%%first case.
build_method_list(_, []) :- !.
build_method_list(Class, [Slot|RSlots]) :-
        Slot =.. [=, MethodName, Method],
        compound(Method),
        Method =.. [method, Arg, _],
        build_method(MethodName, Class, Arg, _),
        build_method_list(Class, RSlots), 
        !.
build_method_list(Class, [Slot|RSlots]) :-
        Slot =.. [=, _, Method],
        atomic(Method),
        build_method_list(Class, RSlots).

%%%
build_method_list_custom(_, _, []) :- !.
build_method_list_custom(Class, Object, [Slot|RSlots]) :-
        Slot =.. [=, MethodName, Method],
        compound(Method),
        Method =.. [method, Arg, _],
        build_method_custom(MethodName, Class, Object, Arg, _),
        build_method_list_custom(Class, Object, RSlots), 
        !.
build_method_list_custom(Class, Object, [Slot|RSlots]) :-
        Slot =.. [=, _, Method],
        atomic(Method),
        build_method_list_custom(Class, Object, RSlots).

%%%Given an instance symbol or its components,
%%%this predicate builds its methods
build_methods(Instance) :-
        Goal =.. [Instance, Class, Slots],
        clause(Goal, _),
        call(Goal),
        build_method_list(Class, Slots).
build_methods(Class, Slots) :-
        build_method_list(Class, Slots).

%%%Creates and instance name InstanceName given the
%%%Class of the instance and the definition for its
%%%slots. Slots and Class must be valid, if a class
%%%has no definition or a Slots has an unknown slot
%%%this predicate fails.
new(InstanceName, Class, Slots) :-
        write(1),
        get_attribs([Class], Attribs),
        split_id(Attribs, SplitAttribs),
        split_id(Slots, SplitSlots),
        in_list(SplitAttribs, SplitSlots),
        append(Slots, Attribs, Members),
        list_to_set([], Members, FinalMemmbers),
        Instance =.. [InstanceName, Class, FinalMemmbers],
        ToYeet =.. [InstanceName, C, K],
        clause(ToYeet, _),
        write(1),
        call(ToYeet),
        atom(C),
        is_list(K),
        atom(C),
        is_list(K),
        retract(ToYeet),
        asserta(Instance),
        build_method_list_custom(Class, InstanceName, FinalMemmbers),
        !.
new(InstanceName, Class, Slots) :-
        write(2),
        get_attribs([Class], Attribs),
        split_id(Attribs, SplitAttribs),
        split_id(Slots, SplitSlots),
        in_list(SplitAttribs, SplitSlots),
        append(Slots, Attribs, Members),
        list_to_set([], Members, FinalMemmbers),
        Instance =.. [InstanceName, Class, FinalMemmbers],
        asserta(Instance),
        build_method_list_custom(Class, InstanceName, FinalMemmbers),
        !.
new(InstanceName, Class) :-
        new(InstanceName, Class, []),
        !.
    
