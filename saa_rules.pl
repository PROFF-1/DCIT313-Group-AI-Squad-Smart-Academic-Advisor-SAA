% ============================================================
%  SMART ACADEMIC ADVISOR (SAA) - INFERENCE ENGINE / RULES
%  University of Ghana, Department of Computer Science
%  DCIT313 AI Project - AI SQUAD
% ============================================================

:- use_module(library(lists)).

% ============================================================
%  RULE 1: PREREQUISITE CHECK
%  A student can register for a course only if all its
%  prerequisites have been completed.
% ============================================================

% All prerequisites satisfied?
all_prerequisites_met(StudentID, CourseID) :-
    student(StudentID, _, _, _, Completed),
    findall(P, prerequisite(CourseID, P), Prereqs),
    all_in_list(Prereqs, Completed).

all_in_list([], _).
all_in_list([H|T], List) :-
    member(H, List),
    all_in_list(T, List).

% Can the student register?
can_register(StudentID, CourseID) :-
    student(StudentID, _, _, _, Completed),
    course(CourseID, _, _, _),
    \+ member(CourseID, Completed),      % not already taken
    all_prerequisites_met(StudentID, CourseID).

% Find missing prerequisites
missing_prerequisites(StudentID, CourseID, Missing) :-
    student(StudentID, _, _, _, Completed),
    findall(P,
        (prerequisite(CourseID, P), \+ member(P, Completed)),
        Missing).

% ============================================================
%  RULE 2: GPA CLASSIFICATION
%  Based on University of Ghana grading policy
% ============================================================

% IF GPA >= 3.6 THEN First Class Honours
gpa_class(GPA, 'First Class Honours') :- GPA >= 3.6.

% IF 3.0 =< GPA < 3.6 THEN Second Class Upper
gpa_class(GPA, 'Second Class (Upper Division)') :-
    GPA >= 3.0, GPA < 3.6.

% IF 2.5 =< GPA < 3.0 THEN Second Class Lower
gpa_class(GPA, 'Second Class (Lower Division)') :-
    GPA >= 2.5, GPA < 3.0.

% IF 2.0 =< GPA < 2.5 THEN Pass
gpa_class(GPA, 'Pass') :- GPA >= 2.0, GPA < 2.5.

% IF GPA < 2.0 THEN Academic Probation
gpa_class(GPA, 'Academic Probation') :- GPA < 2.0.

% ============================================================
%  RULE 3: ACADEMIC RISK ASSESSMENT
% ============================================================

% IF GPA < 1.5 THEN Risk Level = Critical
academic_risk(StudentID, critical) :-
    student(StudentID, _, GPA, _, _),
    GPA < 1.5.

% IF 1.5 =< GPA < 2.0 THEN Risk Level = High
academic_risk(StudentID, high) :-
    student(StudentID, _, GPA, _, _),
    GPA >= 1.5, GPA < 2.0.

% IF 2.0 =< GPA < 2.5 THEN Risk Level = Moderate
academic_risk(StudentID, moderate) :-
    student(StudentID, _, GPA, _, _),
    GPA >= 2.0, GPA < 2.5.

% IF GPA >= 2.5 THEN Risk Level = Low (on track)
academic_risk(StudentID, low) :-
    student(StudentID, _, GPA, _, _),
    GPA >= 2.5.

% ============================================================
%  RULE 4: IMPROVEMENT STRATEGIES
%  Based on risk level
% ============================================================

improvement_strategy(critical, [
    'Immediately meet with your academic advisor',
    'Enroll in the Academic Support and Tutoring Centre',
    'Register for no more than 3 courses next semester',
    'Consider course withdrawal to protect your GPA',
    'Attend all available extra classes and review sessions'
]).

improvement_strategy(high, [
    'Schedule a meeting with your academic advisor within one week',
    'Join a study group for your weakest subject areas',
    'Reduce course load to 4 courses maximum next semester',
    'Seek peer tutoring support for difficult courses',
    'Review your study habits and time management'
]).

improvement_strategy(moderate, [
    'Visit your academic advisor to review your progress',
    'Identify courses where your performance is weakest',
    'Attend office hours regularly for support',
    'Balance your course load carefully next semester'
]).

improvement_strategy(low, [
    'You are on track — maintain your current study habits',
    'Explore challenging electives aligned with your career path',
    'Consider undergraduate research or internship opportunities'
]).

% ============================================================
%  RULE 5: COURSE RECOMMENDATIONS
%  Recommend courses the student can register for at their level
% ============================================================

recommend_courses(StudentID, Recommended) :-
    student(StudentID, _, _, YearLevel, _),
    findall(CourseID,
        (course(CourseID, _, _, CourseLevel),
         CourseLevel =< YearLevel + 1,   % allow courses up to next level
         can_register(StudentID, CourseID)),
        Recommended).

% ============================================================
%  RULE 6: CAREER-ALIGNED ELECTIVE RECOMMENDATIONS
% ============================================================

recommend_electives(StudentID, CareerPath, RecommendedElectives) :-
    findall(CourseID,
        (elective(CourseID, CareerPath),
         can_register(StudentID, CourseID)),
        RecommendedElectives).

% ============================================================
%  RULE 7: GRADUATION ELIGIBILITY CHECK
% ============================================================

% Count credits earned from completed courses
total_credits(StudentID, TotalCredits) :-
    student(StudentID, _, _, _, Completed),
    findall(C,
        (member(CourseID, Completed), course(CourseID, _, C, _)),
        CreditList),
    sum_list(CreditList, TotalCredits).

% Check if all required courses are completed
all_required_completed(StudentID) :-
    student(StudentID, _, _, _, Completed),
    findall(R, required_course(R), Required),
    all_in_list(Required, Completed).

% Find missing required courses
missing_required_courses(StudentID, Missing) :-
    student(StudentID, _, _, _, Completed),
    findall(R,
        (required_course(R), \+ member(R, Completed)),
        Missing).

% Graduation eligibility
graduation_eligible(StudentID, eligible) :-
    student(StudentID, _, GPA, YearLevel, _),
    min_credits_to_graduate(MinCredits),
    min_year_to_graduate(MinYear),
    total_credits(StudentID, Earned),
    Earned >= MinCredits,
    YearLevel >= MinYear,
    GPA >= 2.0,
    all_required_completed(StudentID).

graduation_eligible(StudentID, not_eligible(Reasons)) :-
    student(StudentID, _, GPA, YearLevel, _),
    findall(Reason, graduation_issue(StudentID, GPA, YearLevel, Reason), Reasons),
    Reasons \= [].

graduation_issue(StudentID, _, _, missing_required_courses(Missing)) :-
    missing_required_courses(StudentID, Missing),
    Missing \= [].

graduation_issue(_, GPA, _, low_gpa(GPA)) :- GPA < 2.0.

graduation_issue(_, _, YearLevel, insufficient_year(YearLevel)) :-
    min_year_to_graduate(Min),
    YearLevel < Min.

graduation_issue(StudentID, _, _, insufficient_credits(Earned, Required)) :-
    total_credits(StudentID, Earned),
    min_credits_to_graduate(Required),
    Earned < Required.

% sum_list/2 is provided by library(lists)
