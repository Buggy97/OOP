%Farjad Ali 829940 
/*
:-  def_class(university,   [],     [
                                    name = undefined,
                                    address = undefined,
                                    total_students = undefined,
                                    email = undefined,
                                    number = undefined,
                                    print = method([],  (
                                                        getv(this, name, Name),
                                                        getv(this, address, Address),
                                                        getv(this, email, Email),
                                                        getv(this, number, Number),
                                                        write('Name: '),
                                                        write(Name),
                                                        nl,
                                                        write('Address: '),
                                                        write(Address),
                                                        nl,
                                                        write('Contacts: '),
                                                        write(Email),
                                                        write(' '),
                                                        write(Number)
                                                        )
                                                )
                                    ]
            ).
                                        
:-  def_class(person,   [],     [
                                name = undefined,
                                surname = undefined,
                                number = undefined,
                                address = undefined,
                                age = undefined,
                                print = method([],  (
                                                    getv(this, name, Name),
                                                    getv(this, age, Age),
                                                    getv(this, surname, Surname),
                                                    getv(this, number, Number),
                                                    getv(this, address, Address),
                                                    write('Name: '),
                                                    write(Name),
                                                    nl,
                                                    write('Surname: '),
                                                    write(Surname),
                                                    nl,
                                                    write('Age: '),
                                                    write(Age),
                                                    nl, 
                                                    write('Number: '),
                                                    write(Number),
                                                    nl,
                                                    write('Address: '),
                                                    write(Address),
                                                    nl
                                                    )
                                                )
                                ]
            ).

:- def_class(student,  [person],     [
                                universita = undefined,
                                matricola = undefined,
                                print = method([],  (
                                                    getv(this, name, Name),
                                                    getv(this, surname, Surname),
                                                    getv(this, age, Age),
                                                    getv(this, number, Number),
                                                    getv(this, address, Address),
                                                    getv(this, matricola, Matricola),
                                                    getvx(this, [universita, name], NomeUniversita),
                                                    write('Name: '),
                                                    write(Name),
                                                    nl,
                                                    write('Surname: '),
                                                    write(Surname),
                                                    nl,
                                                    write('Age: '),
                                                    write(Age),
                                                    nl,
                                                    write('Number: '),
                                                    write(Number),
                                                    nl,
                                                    write('Address: '),
                                                    write(Address),
                                                    nl,
                                                    write('Matricola: '),
                                                    write(Matricola),
                                                    nl,
                                                    write('University\': '),
                                                    write(NomeUniversita)
                                                    )
                                            )
                                ]
            ).                                  

:- new(bicocca, university, [
                            name = 'Universita\' degli studi di Milano-Bicocca',
                            address = 'Via Cantalupa 4, 56070 Napoli (NA)',
                            total_students = 4242,
                            email = 'info@unimib.it',
                            number = 035679824
                            ]).

:- new(studente1, student, [
                            name = 'Marco',
                            surname = 'Rossi',
                            age = 42,
                            number = 3207874578,
                            universita = bicocca,
                            matricola = 867045,
                            address = 'Via della pace 42, Sesto San Giovanni (MI)']).

:- new(studente1, student, [
                            name = 'Marco2',
                            surname = 'Rossi2',
                            age = 422,
                            number = 32078745782,
                            universita = bicocca(university, [name = 'Bicocca']),
                            matricola = 867045,
                            address = 'Via della pace 42, Sesto San Giovanni (MI)']).*/

:- def_class(person, [], [name = 'Eve', age = undefined]).

:- def_class(student, [person],
[name = 'Eva Lu Ator',
university = 'Berkeley',
talk = method([],
(write('My name is '),
getv(this, name, N),
write(N),
nl,
write('My age is '),
getv(this, age, A),
write(A),
nl))]).

:- def_class(studente_bicocca, [student],
        [
        talk = method([], 
                (
                write('Mi chiamo '),
                getv(this, name, N),
                write(N),
                nl,
                write(' e studio alla Bicocca. '),
                nl)),
        to_string = method([ResultString],
                (
                with_output_to(string(ResultString),
                (getv(this, name, N),
                getv(this, university, U),
                format('#<~w Student ~w', [U, N]))))),
                university = 'UNIMIB']).