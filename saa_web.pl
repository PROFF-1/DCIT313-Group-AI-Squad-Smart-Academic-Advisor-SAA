:- consult('saa_knowledge_base.pl').
:- consult('saa_rules.pl').

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_files)).
:- use_module(library(http/http_header)).
:- use_module(library(lists)).

:- dynamic server_port/1.
:- dynamic custom_profile/6.

:- multifile user:file_search_path/2.
user:file_search_path(web, 'frontend/public').

:- http_handler(root(.), serve_index, []).
:- http_handler(root(api/students), api_students, []).
:- http_handler(root(api/careers), api_careers, []).
:- http_handler(root(api/courses), api_courses, []).
:- http_handler(root(api/advise), api_advise, []).
:- http_handler(root(api/prereq), api_prereq, []).
:- http_handler(root(api/career), api_career, []).
:- http_handler(root(api/evaluate), api_evaluate, []).
:- http_handler(root(api/profiles), api_profiles, []).

start_server :-
    start_server(8080).

start_server(Port) :-
    integer(Port),
    (   server_port(ExistingPort)
    ->  format('SAA web server is already running on http://localhost:~w~n', [ExistingPort])
    ;   http_server(http_dispatch, [port(Port)]),
        asserta(server_port(Port)),
        format('SAA web server running at http://localhost:~w~n', [Port]),
        writeln('Open the URL in your browser to use the GUI.')
    ).

stop_server :-
    (   retract(server_port(Port))
    ->  http_stop_server(Port, []),
        format('SAA web server stopped on port ~w.~n', [Port])
    ;   writeln('No SAA web server is currently running.')
    ).

serve_index(Request) :-
    http_reply_file(web('index.html'), [], Request).

api_students(_Request) :-
    findall(_{id: Id, name: Name, gpa: GPA, year: Year, completed: Completed},
        student(Id, Name, GPA, Year, Completed),
            Students),
    reply_json_dict(_{students: Students}).

api_careers(_Request) :-
    setof(Path, Course^elective(Course, Path), Paths),
    findall(_{id: Path, label: Label},
            (member(Path, Paths), career_label(Path, Label)),
            Careers),
    reply_json_dict(_{careers: Careers}).

api_courses(_Request) :-
    findall(_{id: ID, name: Name, credits: Credits, level: Level},
        course(ID, Name, Credits, Level),
        Courses),
    reply_json_dict(_{courses: Courses}).

api_advise(Request) :-
    http_parameters(Request, [student(StudentAtom, [atom])]),
    (   advise_dict(StudentAtom, Report)
    ->  reply_json_dict(_{ok: true, report: Report})
    ;   reply_json_dict(_{ok: false, error: 'Student not found.'}, [status(404)])
    ).

api_prereq(Request) :-
    http_parameters(Request, [student(StudentAtom, [atom]), course(CourseAtom, [atom])]),
    (   student(StudentAtom, _, _, _, _)
    ->  true
    ;   reply_json_dict(_{ok: false, error: 'Student not found.'}, [status(404)]),
        !, fail
    ),
    (   course(CourseAtom, _, _, _)
    ->  true
    ;   reply_json_dict(_{ok: false, error: 'Course not found.'}, [status(404)]),
        !, fail
    ),
    course(CourseAtom, CourseName, Credits, Level),
    (   can_register(StudentAtom, CourseAtom)
    ->  reply_json_dict(_{
            ok: true,
            result: 'approved',
            message: 'You may register for this course.',
            course: _{id: CourseAtom, name: CourseName, credits: Credits, level: Level}
        })
    ;   missing_prerequisites(StudentAtom, CourseAtom, Missing),
        maplist(course_to_dict, Missing, MissingCourses),
        reply_json_dict(_{
            ok: true,
            result: 'blocked',
            message: 'Missing prerequisite(s).',
            course: _{id: CourseAtom, name: CourseName, credits: Credits, level: Level},
            missing: MissingCourses
        })
    ).

api_career(Request) :-
    http_parameters(Request, [student(StudentAtom, [atom]), path(CareerPath, [atom])]),
    (   student(StudentAtom, _, _, _, _)
    ->  true
    ;   reply_json_dict(_{ok: false, error: 'Student not found.'}, [status(404)]),
        !, fail
    ),
    recommend_electives(StudentAtom, CareerPath, Electives),
    maplist(course_to_dict, Electives, ElectiveCourses),
    career_label(CareerPath, Label),
    reply_json_dict(_{
        ok: true,
        student: StudentAtom,
        path: _{id: CareerPath, label: Label},
        electives: ElectiveCourses
    }).

api_evaluate(Request) :-
    catch(http_read_json_dict(Request, Payload), _, fail),
    (   nonvar(Payload)
    ->  true
    ;   reply_json_dict(_{ok: false, error: 'Invalid JSON body.'}, [status(400)]),
        !, fail
    ),
    (   profile_from_payload(Payload, Profile)
    ->  evaluate_profile(Profile, Report),
        reply_json_dict(_{ok: true, report: Report})
    ;   reply_json_dict(_{ok: false, error: 'Invalid payload. Required: name, gpa, year, completed_courses.'}, [status(400)])
    ).

api_profiles(Request) :-
    option(method(get), Request),
    findall(_{
            id: ID,
            name: Name,
            gpa: GPA,
            year: Year,
            career_path: CareerPath,
            completed: Completed
        },
        custom_profile(ID, Name, GPA, Year, CareerPath, Completed),
        Profiles),
    reply_json_dict(_{profiles: Profiles}).

api_profiles(Request) :-
    option(method(post), Request),
    catch(http_read_json_dict(Request, Payload), _, fail),
    (   nonvar(Payload)
    ->  true
    ;   reply_json_dict(_{ok: false, error: 'Invalid JSON body.'}, [status(400)]),
        !, fail
    ),
    (   profile_fields_from_payload(Payload, Name, GPA, Year, CompletedAtoms, CareerPath)
    ->  profile_temp_id(ProfileID),
        assertz(custom_profile(ProfileID, Name, GPA, Year, CareerPath, CompletedAtoms)),
        reply_json_dict(_{
            ok: true,
            profile: _{
                id: ProfileID,
                name: Name,
                gpa: GPA,
                year: Year,
                career_path: CareerPath,
                completed: CompletedAtoms
            }
        }, [status(201)])
    ;   reply_json_dict(_{ok: false, error: 'Invalid payload. Required: name, gpa, year, completed_courses.'}, [status(400)])
    ).

advise_dict(StudentID, Report) :-
    student(StudentID, Name, GPA, Year, Completed),
    evaluate_profile(profile(StudentID, Name, GPA, Year, Completed, none), Report).

profile_from_payload(Payload, profile(TempID, Name, GPA, Year, CompletedAtoms, CareerPath)) :-
    profile_fields_from_payload(Payload, Name, GPA, Year, CompletedAtoms, CareerPath),
    profile_temp_id(TempID).

profile_fields_from_payload(Payload, Name, GPA, Year, CompletedAtoms, CareerPath) :-
    get_dict(name, Payload, RawName),
    get_dict(gpa, Payload, RawGpa),
    get_dict(year, Payload, RawYear),
    get_dict(completed_courses, Payload, RawCompleted),
    name_value(RawName, Name),
    numeric_value(RawGpa, GPA),
    numeric_value(RawYear, YearNumber),
    Year is round(YearNumber),
    Year >= 1,
    Year =< 4,
    GPA >= 0.0,
    GPA =< 4.0,
    is_list(RawCompleted),
    maplist(to_course_atom, RawCompleted, CompletedRaw),
    include(valid_course_id, CompletedRaw, CompletedFiltered),
    sort(CompletedFiltered, CompletedAtoms),
    extract_career_path(Payload, CareerPath).

name_value(Value, Name) :-
    string(Value),
    normalize_space(string(Trimmed), Value),
    Trimmed \= "",
    Name = Trimmed.
name_value(Value, Name) :-
    atom(Value),
    atom_string(Value, StringValue),
    normalize_space(string(Trimmed), StringValue),
    Trimmed \= "",
    Name = Trimmed.

numeric_value(Value, Number) :-
    number(Value),
    Number is Value.
numeric_value(Value, Number) :-
    string(Value),
    number_string(Number, Value).

to_course_atom(Value, Atom) :-
    atom(Value),
    Atom = Value, !.
to_course_atom(Value, Atom) :-
    string(Value),
    atom_string(Atom, Value).

valid_course_id(CourseID) :-
    course(CourseID, _, _, _).

profile_temp_id(TempID) :-
    get_time(Timestamp),
    format(atom(TempID), 'temp_~0f', [Timestamp]).

extract_career_path(Payload, CareerPath) :-
    (   get_dict(career_path, Payload, RawPath)
    ->  to_course_atom(RawPath, CareerPath)
    ;   CareerPath = none
    ).

evaluate_profile(profile(StudentID, Name, GPA, Year, Completed, CareerPath), Report) :-
    gpa_class(GPA, Class),
    academic_risk_from_gpa(GPA, Risk),
    improvement_strategy(Risk, Strategies),
    completed_credits(Completed, Credits),
    length(Completed, CompletedCount),
    recommend_courses_from_profile(Completed, Year, RecommendedIDs),
    maplist(course_to_dict, RecommendedIDs, RecommendedCourses),
    missing_required_courses_from_profile(Completed, MissingRequired),
    maplist(course_to_dict, MissingRequired, MissingRequiredCourses),
    missed_courses_for_level(Completed, Year, MissedNowIDs),
    maplist(course_to_dict, MissedNowIDs, MissedNowCourses),
    next_level_blockers(Completed, Year, Blockers),
    graduation_status_from_profile(GPA, Year, Credits, MissingRequired, GradStatus),
    grad_status_dict(GradStatus, GradDict),
    career_electives_for_profile(Completed, CareerPath, CareerAdvice),
    build_forward_plan(Risk, MissedNowIDs, RecommendedIDs, CareerAdvice, ForwardPlan),
    Report = _{
        student: _{id: StudentID, name: Name, gpa: GPA, year: Year},
        summary: _{
            class: Class,
            credits: Credits,
            completed_courses: CompletedCount,
            risk: Risk
        },
        progress: _{
            missed_out_courses: MissedNowCourses,
            missing_required_courses: MissingRequiredCourses,
            next_level_blockers: Blockers
        },
        recommendations: _{
            improvement: Strategies,
            courses: RecommendedCourses,
            career: CareerAdvice,
            next_steps: ForwardPlan
        },
        graduation: GradDict
    }.

academic_risk_from_gpa(GPA, critical) :- GPA < 1.5, !.
academic_risk_from_gpa(GPA, high) :- GPA < 2.0, !.
academic_risk_from_gpa(GPA, moderate) :- GPA < 2.5, !.
academic_risk_from_gpa(_, low).

completed_credits(Completed, TotalCredits) :-
    findall(Credit,
        (member(CourseID, Completed), course(CourseID, _, Credit, _)),
        CreditList),
    sum_list(CreditList, TotalCredits).

recommend_courses_from_profile(Completed, YearLevel, Recommended) :-
    findall(CourseID,
        (course(CourseID, _, _, CourseLevel),
         CourseLevel =< YearLevel + 1,
         can_register_from_profile(Completed, CourseID)),
        Recommended).

can_register_from_profile(Completed, CourseID) :-
    course(CourseID, _, _, _),
    \+ member(CourseID, Completed),
    all_prerequisites_met_from_profile(Completed, CourseID).

all_prerequisites_met_from_profile(Completed, CourseID) :-
    findall(P, prerequisite(CourseID, P), Prereqs),
    all_in_list(Prereqs, Completed).

missing_prerequisites_from_profile(Completed, CourseID, Missing) :-
    findall(P,
        (prerequisite(CourseID, P), \+ member(P, Completed)),
        Missing).

missing_required_courses_from_profile(Completed, Missing) :-
    findall(R,
        (required_course(R), \+ member(R, Completed)),
        Missing).

missed_courses_for_level(Completed, Year, Missed) :-
    findall(CourseID,
        (required_course(CourseID),
         course(CourseID, _, _, Level),
         Level =< Year,
         \+ member(CourseID, Completed)),
        Missed).

next_level_blockers(Completed, Year, Blockers) :-
    NextYear is Year + 1,
    findall(_{course: CourseDict, missing_prerequisites: MissingDicts},
        (course(CourseID, _, _, NextYear),
         \+ member(CourseID, Completed),
         missing_prerequisites_from_profile(Completed, CourseID, Missing),
         Missing \= [],
         course_to_dict(CourseID, CourseDict),
         maplist(course_to_dict, Missing, MissingDicts)),
        Blockers).

graduation_status_from_profile(GPA, Year, Credits, MissingRequired, eligible) :-
    min_credits_to_graduate(MinCredits),
    min_year_to_graduate(MinYear),
    Credits >= MinCredits,
    Year >= MinYear,
    GPA >= 2.0,
    MissingRequired = [], !.
graduation_status_from_profile(GPA, Year, Credits, MissingRequired, not_eligible(Reasons)) :-
    min_credits_to_graduate(MinCredits),
    min_year_to_graduate(MinYear),
    findall(Reason,
        graduation_issue_from_profile(GPA, Year, Credits, MinCredits, MinYear, MissingRequired, Reason),
        Reasons).

graduation_issue_from_profile(_, _, _, _, _, MissingRequired, missing_required_courses(MissingRequired)) :-
    MissingRequired \= [].
graduation_issue_from_profile(GPA, _, _, _, _, _, low_gpa(GPA)) :-
    GPA < 2.0.
graduation_issue_from_profile(_, Year, _, _, MinYear, _, insufficient_year(Year)) :-
    Year < MinYear.
graduation_issue_from_profile(_, _, Credits, MinCredits, _, _, insufficient_credits(Credits, MinCredits)) :-
    Credits < MinCredits.

career_electives_for_profile(_, none, _{path: _{id: none, label: 'Not selected'}, electives: []}) :- !.
career_electives_for_profile(Completed, CareerPath, _{path: _{id: CareerPath, label: Label}, electives: ElectiveDicts}) :-
    career_label(CareerPath, Label),
    findall(CourseID,
        (elective(CourseID, CareerPath), can_register_from_profile(Completed, CourseID)),
        Electives),
    maplist(course_to_dict, Electives, ElectiveDicts).

build_forward_plan(Risk, MissedNowIDs, RecommendedIDs, CareerAdvice, Steps) :-
    risk_action(Risk, RiskAction),
    missed_action(MissedNowIDs, MissedAction),
    recommend_action(RecommendedIDs, RecommendAction),
    career_action(CareerAdvice, CareerAction),
    Steps = [RiskAction, MissedAction, RecommendAction, CareerAction].

risk_action(critical, 'Meet an academic advisor immediately and reduce your load next semester.').
risk_action(high, 'Prioritize GPA recovery with focused tutoring and a lighter, manageable load.').
risk_action(moderate, 'Maintain steady improvement by addressing weak subjects before adding heavy electives.').
risk_action(low, 'Keep your current performance and add strategic higher-level courses.').

missed_action([], 'No overdue core courses at your current level.').
missed_action(Missed, Message) :-
    length(Missed, Count),
    format(atom(Message), 'You have ~w overdue core course(s); prioritize these first.', [Count]).

recommend_action([], 'No immediate course registrations available; complete prerequisite gaps first.').
recommend_action(Recommended, Message) :-
    length(Recommended, Count),
    format(atom(Message), 'You can register ~w course(s) right now based on your profile.', [Count]).

career_action(CareerAdvice, 'Select a career path to get personalized elective advice.') :-
    get_dict(path, CareerAdvice, Path),
    get_dict(id, Path, none), !.
career_action(CareerAdvice, Message) :-
    get_dict(path, CareerAdvice, Path),
    get_dict(label, Path, Label),
    get_dict(electives, CareerAdvice, []), !,
    format(atom(Message), 'No elective currently available for ~w; complete prerequisite blockers first.', [Label]).
career_action(CareerAdvice, Message) :-
    get_dict(path, CareerAdvice, Path),
    get_dict(label, Path, Label),
    get_dict(electives, CareerAdvice, Electives),
    length(Electives, Count),
    format(atom(Message), 'You already qualify for ~w elective(s) in ~w.', [Count, Label]).

course_to_dict(CourseID, _{id: CourseID, name: Name, credits: Credits, level: Level}) :-
    course(CourseID, Name, Credits, Level), !.
course_to_dict(CourseID, _{id: CourseID, name: 'Unknown Course', credits: 0, level: 0}).

grad_status_dict(eligible, _{status: eligible, reasons: []}).
grad_status_dict(not_eligible(Reasons), _{status: not_eligible, reasons: ReasonDicts}) :-
    maplist(grad_reason_to_dict, Reasons, ReasonDicts).

grad_reason_to_dict(missing_required_courses(Courses), _{type: missing_required_courses, courses: CourseDicts}) :-
    maplist(course_to_dict, Courses, CourseDicts), !.
grad_reason_to_dict(low_gpa(GPA), _{type: low_gpa, gpa: GPA, minimum: 2.0}) :- !.
grad_reason_to_dict(insufficient_year(Year), _{type: insufficient_year, current_year: Year, required_year: 4}) :- !.
grad_reason_to_dict(insufficient_credits(Earned, Required), _{type: insufficient_credits, earned: Earned, required: Required}) :- !.
grad_reason_to_dict(Other, _{type: unknown, value: Other}).

career_label(ai_and_ml, 'AI and ML').
career_label(cybersecurity, 'Cybersecurity').
career_label(software_engineering, 'Software Engineering').
career_label(cloud_and_networks, 'Cloud and Networks').
career_label(data_science, 'Data Science').
career_label(mobile_development, 'Mobile Development').
career_label(Other, Label) :- atom_string(Other, Label).

:- nl,
   writeln('=== Smart Academic Advisor Web Layer Loaded ==='),
   writeln('Start server: start_server.            % default port 8080'),
   writeln('Start custom: start_server(9090).'),
   writeln('Stop server : stop_server.'),
   nl.
