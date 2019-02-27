/* Useless codereplace(_, _, [], []) :- !.
replace(O, R, [O|T], [R|T2]) :- replace(O, R, T, T2).
replace(O, R, [H|T], [H|T2]) :- H \= O, replace(O, R, T, T2).

%replace_occurrence(M, O, F, M1) :-  M =.. [X|T],  
%                                    replace(O, F, T, M1_),
%                                    M1 =.. [X|M1_].

replace_occurrence(M, O, F, M1) :-  M =.. [X|T],  
                                    replace(O, F, T, M1_),
                                    M1 =.. [X|M1_].

replace_occurrence_list([], _, _, []) :- !.
replace_occurrence_list([M|T],O, F, [M1|T1]) :- replace_occurrence(M, O, F, M1),
                                                replace_occurrence_list(T, O, F, T1).


replace_occurrence_method(Method, Occ, Val, NewMethod) :- 
                            Method =.. [Name|Vals],
                            replace_occurrence_list(Vals, Occ, Val, NewVals),
                            NewMethod =.. [Name|NewVals]. 
                            
replace_occurrence_list(_, _, [], []) :- !.
replace_occurrence_list(Subterm0, Subterm, [First|Rest], [NFirst|NRest]) :- 
            replace_occurrence(Subterm0, Subterm, First, NFirst),
            replace_occurrence_list(Subterm0, Subterm, Rest, NRest).

replace_occurrence_method(Subterm0, Subterm, Method0, Method) :-
            Method0 =.. [Name|Clauses],
            replace_occurrence_list(Subterm0, Subterm, Clauses, NClauses),
            Method =.. [Name|NClauses].
                            */

atomic_list([]).
atomic_list([X|T]) :- atomic(X), atomic_list(T).

indexOf([Element|_], Element, 0):- !.
indexOf([_|Tail], Element, Index):-
  indexOf(Tail, Element, Index1),
  !,
  Index is Index1+1.

get_slot(Slot, Name, Value) :-  term_to_atom(Slot, A),
                                    atom_chars(A, L),
                                    indexOf(L, =, H),
                                    sub_atom(A, 0, H, J, Name_),
                                    HN is (H+1), JN is (J-1),
                                    sub_atom(A, HN, JN, 0, Value_),
                                    term_to_atom(Name, Name_),
                                    term_to_atom(Value, Value_).
get_slots([],[],[]).
get_slots([First|Rest], [FirstName|RestNames], [FirstValue|RestValues]) :-
            get_slot(First, FirstName, FirstValue),
            get_slots(Rest, RestNames, RestValues).

build_class_methods(Class) :-
        get_attribs([Class], Attribs),
        build_method_list(Class, Attribs).

def_class(Name, Parents, Slots) :-  get_slots(Slots, Names, _),
                                    atomic_list(Names),
                                    atomic_list(Parents),
                                    Class =.. [Name, Parents, Slots],
                                    abolish(Name, 2),
                                    asserta(Class),
                                    build_class_methods(Name).

replace(Subterm0, Subterm, Term0, Term) :- 
            Term0 == Subterm0 -> Term = Subterm.
replace(_,  _, Term0, Term) :- 
            var(Term0) -> Term = Term0.
replace(Subterm0, Subterm, Term0, Term) :- 
            Term0 =.. [F|Args0],
            maplist(replace(Subterm0,Subterm), Args0, Args),
            Term =.. [F|Args], !.

 reverse([],Z,Z) :- !.
 reverse([H|T],Z,Acc) :- reverse(T,Z,[H|Acc]).

get_attribs([], []) :- !.
get_attribs([Class|RClass], NAttrib) :-
        Goal =.. [Class, NClass, Attrib],
        clause(Goal, _),
        call(Goal),
        append(NClass, RClass, FClass),
        get_attribs(FClass, Rest),
        append(Attrib, Rest, NAttrib).
    
split_id([], []) :- !.
split_id([Slot|RSlot], [Id|RId]) :-
        Slot =.. [=, Id, _],
        split_id(RSlot, RId).
    
in_list(_, []) :- !.
    
in_list(Base, [X|T]) :-
        member(X, Base),
        in_list(Base, T).
    
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
    
instance_of(Instance, Class) :-
        atom(Instance),
        Goal =.. [Instance, Class, _],
        call(Goal).

instance_of(Instance, Class) :-
        compound(Instance),
        Instance =.. [_, Class, _].
    
getv(Instance, Slot, Val) :-
            atom(Instance),
            Goal =.. [Instance, _, Slots],
            Var =.. [=, Slot, Val],
            clause(Goal, _),
            call(Goal),
            member(Var, Slots),
            !.

getv(Goal, Slot, Val) :-
            compound(Goal),
            Goal =.. [_, _, Slots],
            Var =.. [=, Slot, Val],
            member(Var, Slots).

getvx(R, [], R) :- !.
getvx(Instance, [Slot|RSlots], R) :-
        getv(Instance, Slot, V),
        getvx(V, RSlots, R).
    
process_method(X, Final) :-
        X =.. [=, MethodName, Method0],
        replace(this, _obj, Method0, Method),
        Method =.. [method, Arg, Code],
        append([MethodName], [_obj|Arg], HeadF),
        Head =.. HeadF,
        Final =.. [->, (Code), Head].
   
build_method(FinalMethodName, Class, Arg2, Goal) :-
        Head =.. [FinalMethodName, Caller | Arg2],
        Goal =.. [:-, Head, (instance_of(Caller, Class), 
                        getv(Caller, FinalMethodName, Val), 
                    replace(this, Caller, Val, NVal), NVal =.. [method, Args, Code],
                     Args = Arg2, call(Code), !)],
        asserta(Goal).
    
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

build_methods(Instance) :-
        Goal =.. [Instance, Class, Slots],
        call(Goal),
        build_method_list(Class, Slots).

new(InstanceName, Class, Slots) :-
        get_attribs([Class], Attribs),
        %%%%reverse(Attribs1, Attribs),
        split_id(Attribs, SplitAttribs),
        split_id(Slots, SplitSlots),
        in_list(SplitAttribs, SplitSlots),
        append(Slots, Attribs, Members),
        list_to_set([], Members, FinalMemmbers),
        Instance =.. [InstanceName, Class, FinalMemmbers],
        abolish(InstanceName, 2),
        asserta(Instance),
        build_methods(InstanceName), 
        !.
    
new(InstanceName, Class) :-
        Slots = [],
        get_attribs([Class], Attribs),
        %%%%reverse(Attribs1, Attribs),
        split_id(Attribs, SplitAttribs),
        split_id(Slots, SplitSlots),
        in_list(SplitAttribs, SplitSlots),
        append(Slots, Attribs, Members),
        list_to_set([], Members, FinalMemmbers),
        Instance =.. [InstanceName, Class, FinalMemmbers],
        abolish(InstanceName, 2),
        asserta(Instance),
        build_methods(InstanceName).
    
