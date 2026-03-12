% ============================================================
%  SMART ACADEMIC ADVISOR (SAA) - MAIN ENTRY POINT
%  University of Ghana, Department of Computer Science
%  DCIT313 AI Project - AI SQUAD
%
%  HOW TO RUN:
%    swipl saa_main.pl
%    Then call: advise(s001).   or   run_demo.
% ============================================================

:- consult('saa_knowledge_base.pl').
:- consult('saa_rules.pl').

% ============================================================
%  FULL STUDENT REPORT
%  advise(StudentID) - prints a complete advisory report
% ============================================================

advise(StudentID) :-
    student(StudentID, Name, GPA, Year, Completed),
    nl,
    writeln('============================================================'),
    writeln('        SMART ACADEMIC ADVISOR - STUDENT REPORT'),
    writeln('============================================================'),
    format("  Student   : ~w (~w)~n", [Name, StudentID]),
    format("  Year Level: ~w~n", [Year]),
    format("  GPA       : ~w~n", [GPA]),

    % GPA Classification
    gpa_class(GPA, Class),
    format("  Class     : ~w~n", [Class]),

    % Credits
    total_credits(StudentID, Credits),
    format("  Credits   : ~w completed~n", [Credits]),

    % Completed Courses
    length(Completed, NumDone),
    format("  Courses Completed: ~w~n", [NumDone]),

    nl,
    writeln('--- ACADEMIC RISK ASSESSMENT ---'),
    academic_risk(StudentID, Risk),
    format("  Risk Level: ~w~n", [Risk]),
    improvement_strategy(Risk, Strategies),
    writeln("  Recommendations:"),
    print_list(Strategies),

    nl,
    writeln('--- AVAILABLE COURSES TO REGISTER ---'),
    recommend_courses(StudentID, Available),
    (Available = [] ->
        writeln("  No eligible courses found at this time.")
    ;
        print_course_list(Available)
    ),

    nl,
    writeln('--- GRADUATION STATUS ---'),
    graduation_eligible(StudentID, GradStatus),
    print_graduation_status(GradStatus),

    nl,
    writeln('============================================================'),
    nl.

advise(StudentID) :-
    \+ student(StudentID, _, _, _, _),
    format("ERROR: Student '~w' not found in the database.~n", [StudentID]).


% ============================================================
%  CAREER ADVISING
%  career_advise(StudentID, CareerPath)
%  career_advise(s001, ai_and_ml).
% ============================================================

career_advise(StudentID, CareerPath) :-
    student(StudentID, Name, _, _, _),
    nl,
    writeln('--- CAREER-ALIGNED ELECTIVE RECOMMENDATIONS ---'),
    format("  Student   : ~w~n", [Name]),
    format("  Career Path: ~w~n", [CareerPath]),
    recommend_electives(StudentID, CareerPath, Electives),
    (Electives = [] ->
        writeln("  No available electives yet (check prerequisites).")
    ;
        writeln("  You can register for these electives:"),
        print_course_list(Electives)
    ), nl.


% ============================================================
%  PREREQUISITE CHECKER
%  check_prereq(StudentID, CourseID)
%  check_prereq(s002, dcit201).
% ============================================================

check_prereq(StudentID, CourseID) :-
    student(StudentID, Name, _, _, _),
    course(CourseID, CourseName, _, _),
    nl,
    format("  Student : ~w~n", [Name]),
    format("  Course  : ~w (~w)~n", [CourseName, CourseID]),
    (can_register(StudentID, CourseID) ->
        writeln("  RESULT  : APPROVED - You may register for this course.")
    ;
        missing_prerequisites(StudentID, CourseID, Missing),
        writeln("  RESULT  : BLOCKED - Missing prerequisites:"),
        print_course_list(Missing)
    ), nl.


% ============================================================
%  DEMO - runs reports for all sample students
% ============================================================

run_demo :-
    writeln('=== SMART ACADEMIC ADVISOR - FULL DEMO ==='),
    forall(student(ID, _, _, _, _), advise(ID)).


% ============================================================
%  HELPER PRINT UTILITIES
% ============================================================

print_list([]).
print_list([H|T]) :-
    format("    - ~w~n", [H]),
    print_list(T).

print_course_list([]).
print_course_list([CourseID|T]) :-
    (course(CourseID, Name, Credits, Level) ->
        format("    - ~w | ~w | ~w credits | Year ~w~n",
               [CourseID, Name, Credits, Level])
    ;
        format("    - ~w~n", [CourseID])
    ),
    print_course_list(T).

print_graduation_status(eligible) :-
    writeln("  STATUS: ELIGIBLE FOR GRADUATION").
print_graduation_status(not_eligible(Reasons)) :-
    writeln("  STATUS: NOT YET ELIGIBLE"),
    writeln("  Issues:"),
    print_grad_reasons(Reasons).

print_grad_reasons([]).
print_grad_reasons([missing_required_courses(List)|T]) :-
    writeln("    - Missing required courses:"),
    print_course_list(List),
    print_grad_reasons(T).
print_grad_reasons([low_gpa(GPA)|T]) :-
    format("    - GPA ~w is below minimum 2.0~n", [GPA]),
    print_grad_reasons(T).
print_grad_reasons([insufficient_year(Y)|T]) :-
    format("    - Currently Year ~w — must complete Year 4~n", [Y]),
    print_grad_reasons(T).
print_grad_reasons([insufficient_credits(Earned, Req)|T]) :-
    format("    - Only ~w/~w credits earned~n", [Earned, Req]),
    print_grad_reasons(T).


% ============================================================
%  ON LOAD - show usage help
% ============================================================

:- nl,
   writeln('=== Smart Academic Advisor (SAA) Loaded ==='),
   writeln('Available commands:'),
   writeln('  advise(StudentID).            % Full report, e.g. advise(s001).'),
   writeln('  career_advise(ID, Path).      % e.g. career_advise(s001, ai_and_ml).'),
   writeln('  check_prereq(ID, CourseID).   % e.g. check_prereq(s002, dcit201).'),
   writeln('  run_demo.                     % Run all sample students'),
   nl,
   writeln('Career paths: ai_and_ml | cybersecurity | software_engineering'),
   writeln('              cloud_and_networks | data_science | mobile_development'),
   nl,
   writeln('Sample student IDs: s001, s002, s003, s004, s005'),
   nl.
