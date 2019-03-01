%%%% -*- Mode: Prolog -*-

/*
 * Prolog test suitcases for the project OOP
 */
:-begin_tests(oop).
:-use_module(library(plunit)).
:-include('OOProlog.pl').

test(createClass) :-
        def_class(person, [], [name = "", age = undefined, sex = undefined]).

test(createInheritClasses) :-
	def_class(student, [person],
                  [subject = "",
                   study = method([Hours], (
                                      write("Oggi studio "),
                                      getv(this, subject, S),
                                      write(S),
                                      write(" per "),
                                      write(Hours),
                                      write(" ore"),
				      nl
                                  ))]),
        def_class(worker, [person], [work = undefined]),
        def_class(unimib_s, [student], [years = 3]),
        def_class(unimi_s, [student], [years = 5]),
        def_class(worker_s, [student, worker], [job_type = undefined]),
        def_class(it_student, [unimib_s, unimi_s, worker_s], [course = "EQ5452",
                                                          study = method([AgeStartUni, Y],
                                                                          (getv(this, age, A),
									   Y is A - AgeStartUni
									  )),
                                                             friend = undefined]),
        def_class(mu, [], [p = 42, sex = "M"]),
        def_class(prof, [mu, person], [course = undefined]),
        def_class(i_prof, [person, mu], [course = undefined]),
        def_class(lp_prof, [prof], [course = "LP", tortura = method([Student], (
                                                                        getv(Student, name, N),
                                                                        getv(Student, age, A),
                                                                        getv(this, age, AP),
                                                                        getv(this, name, NP),
                                                                        write(N),
                                                                        D is AP - A,
                                                                        write(" ho "),
                                                                        write(D),
                                                                        write(" anni in piu di te. -"),
                                                                        write(NP),
									nl
								    )), triggeredBy = undefined]).


test(createSimpleInstance) :-
        new(davide, student, [subject = "Statistica"]),
        new(manzo, i_prof).

test(createInstanceWithStrongMethod) :-
        new(gianlo, it_student, [work = "PartTime", name="Gianlo", age=20, sex="M", subject="IT", friend = marco]),
        new(marco, it_student, [work = "Stage", sex = "F", study = method([Destination, Friend], (
                                                                              write("Vado a studiare a "),
                                                                              write(Destination),
                                                                              write(" a differenza di "),
                                                                              getv(Friend, name, N),
                                                                              write(N),
                                                                              write(" che studia da "),
                                                                              study(Friend, 18, Uni),
                                                                              write(Uni),
                                                                              write(" anni."),
                                                                              nl
                                                                          )),
                               friend = michele]),
        new(michele, it_student, [friend = gianlo]),
        new(am, lp_prof, [name = "AM", age=56, triggeredBy = marco]),
        new(chris, unimi_s).

test(callClassMethod) :-
        study(davide, 5), /* Stampa: Oggi studio Statistica per 5 ore*/
        tortura(am, gianlo), /* Stampa: Gianlo ho 36 anni in piu di te. -AM */
        study(marco, "Bordeaux", gianlo). /*Stampa: Vado a studiare a  Bordeauxnl a differenza di Gianlo che studia da -2 anni. */
        %\+study(marco, "Napoli", chris). /*Deve fallire perchè chris eredita da student il metodo study con 1 solo args*/

test(simpleGetV) :-
        getv(gianlo, work, "PartTime"),
        getv(gianlo, age, 20),
        getv(am, name, "AM"),
        getv(chris, years, 5).

test(strongGetV) :-
        getv(gianlo, years, 3),
        getv(am, triggeredBy, marco),
        getv(am, sex, "M"),
        getv(manzo, sex, undefined).

test(getvx) :-
        getv(am, triggeredBy, GIT),
        getv(GIT, friend, GG),
        getv(GG, friend, GOAL),
        getv(GOAL, friend, HIGUAIN),
        getv(HIGUAIN, friend, SILVA),
        getv(SILVA, subject, MUNTARI),
        getvx(am, [triggeredBy, friend, friend, friend, friend, subject], MUNTARI).

test(clearAll) :-
        retractall(class(_,_,_)),
        retractall(instance(_,_,_)),
        retractall(study(_,_,_)),
        retractall(study(_,_)),
        retractall(tortura(_,_)).

:-end_tests(oop).

