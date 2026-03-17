% ============================================================
%  SMART ACADEMIC ADVISOR (SAA) - KNOWLEDGE BASE
%  University of Ghana, Department of Computer Science
%  DCIT313 AI Project - AI SQUAD
% ============================================================

% ------------------------------------------------------------
% COURSE FACTS: course(ID, Name, Credits, YearLevel)
% ------------------------------------------------------------
course(dcit101, 'Introduction to Computing',          3, 1).
course(dcit103, 'Programming Fundamentals',           3, 1).
course(dcit105, 'Mathematics for Computing I',        3, 1).
course(dcit107, 'Logic and Discrete Mathematics',     3, 1).
course(dcit109, 'Communication Skills',               2, 1).

course(dcit201, 'Data Structures and Algorithms',     3, 2).
course(dcit203, 'Object-Oriented Programming',        3, 2).
course(dcit205, 'Mathematics for Computing II',       3, 2).
course(dcit207, 'Computer Organization',              3, 2).
course(dcit209, 'Web Technologies',                   3, 2).

course(dcit301, 'Algorithm Analysis and Design',      3, 3).
course(dcit303, 'Database Systems',                   3, 3).
course(dcit305, 'Operating Systems',                  3, 3).
course(dcit307, 'Computer Networks',                  3, 3).
course(dcit309, 'Software Engineering',               3, 3).
course(dcit311, 'Human Computer Interaction',         2, 3).
course(dcit313, 'Artificial Intelligence',            3, 3).

course(dcit401, 'Compiler Design',                    3, 4).
course(dcit403, 'Distributed Systems',                3, 4).
course(dcit405, 'Information Security',               3, 4).
course(dcit407, 'Machine Learning',                   3, 4).
course(dcit409, 'Mobile Application Development',     3, 4).
course(dcit411, 'Cloud Computing',                    3, 4).
course(dcit413, 'Computer Graphics',                  3, 4).
course(dcit490, 'Final Year Project',                 6, 4).

course(dcit102, 'Computer Hardware Fundamentals',     3, 1).
course(dcit104, 'Programming with Python',            3, 1).
course(dcit202, 'Computer Networks',                  3, 2).
course(dcit204, 'Web Development',                    3, 2).
course(dcit302, 'Mobile Development',                 3, 3).
course(dcit304, 'Introduction to Data Science',       3, 3).
course(dcit402, 'Advanced Databases',                 3, 4).
course(dcit404, 'Cloud Computing',                    3, 4).

course(dcit415, 'Natural Language Processing', 3, 4).
course(dcit417, 'Computer Vision', 3, 4).
course(dcit419, 'Ethical Hacking', 3, 4).
course(dcit421, 'Digital Forensics', 3, 4).
course(dcit423, 'Software Testing and Quality Assurance', 3, 4).
course(dcit425, 'DevOps and CI/CD', 3, 4).
course(dcit427, 'Wireless and Mobile Networks', 3, 4).
course(dcit429, 'Network Automation', 3, 4).
course(dcit431, 'Big Data Analytics', 3, 4).
course(dcit433, 'Data Visualization', 3, 4).
course(dcit435, 'Cross-Platform Development', 3, 4).
course(dcit437, 'UI/UX for Mobile', 3, 4).

% ------------------------------------------------------------
% PREREQUISITE FACTS: prerequisite(Course, RequiredFirst)
% ------------------------------------------------------------
prerequisite(dcit102, dcit101).
prerequisite(dcit104, dcit103).
prerequisite(dcit202, dcit102).
prerequisite(dcit204, dcit209).
prerequisite(dcit302, dcit203).
prerequisite(dcit304, dcit205).
prerequisite(dcit402, dcit303).
prerequisite(dcit404, dcit307).

prerequisite(dcit415, dcit407).
prerequisite(dcit417, dcit413).
prerequisite(dcit419, dcit405).
prerequisite(dcit421, dcit405).
prerequisite(dcit423, dcit309).
prerequisite(dcit425, dcit309).
prerequisite(dcit427, dcit307).
prerequisite(dcit429, dcit307).
prerequisite(dcit431, dcit303).
prerequisite(dcit433, dcit304).
prerequisite(dcit435, dcit409).
prerequisite(dcit437, dcit311).

prerequisite(dcit201, dcit103).   % Data Structures requires Programming Fundamentals
prerequisite(dcit201, dcit105).   % Data Structures requires Maths I
prerequisite(dcit203, dcit103).   % OOP requires Programming Fundamentals
prerequisite(dcit205, dcit105).   % Maths II requires Maths I
prerequisite(dcit207, dcit101).   % Computer Org requires Intro to Computing
prerequisite(dcit209, dcit101).   % Web Tech requires Intro to Computing

prerequisite(dcit301, dcit201).   % Algorithm Analysis requires Data Structures
prerequisite(dcit303, dcit201).   % Database requires Data Structures
prerequisite(dcit305, dcit207).   % OS requires Computer Organization
prerequisite(dcit307, dcit207).   % Networks requires Computer Organization
prerequisite(dcit309, dcit203).   % Software Eng requires OOP
prerequisite(dcit313, dcit201).   % AI requires Data Structures
prerequisite(dcit313, dcit107).   % AI requires Logic and Discrete Maths

prerequisite(dcit401, dcit305).   % Compiler Design requires OS
prerequisite(dcit401, dcit301).   % Compiler Design requires Algorithm Analysis
prerequisite(dcit403, dcit307).   % Distributed Systems requires Networks
prerequisite(dcit405, dcit307).   % Info Security requires Networks
prerequisite(dcit407, dcit313).   % Machine Learning requires AI
prerequisite(dcit407, dcit205).   % Machine Learning requires Maths II
prerequisite(dcit409, dcit203).   % Mobile Dev requires OOP
prerequisite(dcit411, dcit307).   % Cloud Computing requires Networks
prerequisite(dcit413, dcit205).   % Computer Graphics requires Maths II
prerequisite(dcit490, dcit309).   % Final Year Project requires Software Engineering

% ------------------------------------------------------------
% REQUIRED CORE COURSES (must pass to graduate)
% ------------------------------------------------------------
required_course(dcit101).
required_course(dcit102).
required_course(dcit103).
required_course(dcit104).
required_course(dcit105).
required_course(dcit107).
required_course(dcit201).
required_course(dcit202).
required_course(dcit203).
required_course(dcit204).
required_course(dcit205).
required_course(dcit207).
required_course(dcit301).
required_course(dcit302).
required_course(dcit303).
required_course(dcit304).
required_course(dcit305).
required_course(dcit307).
required_course(dcit309).
required_course(dcit313).
required_course(dcit401).
required_course(dcit402).
required_course(dcit403).
required_course(dcit404).
required_course(dcit405).
required_course(dcit490).

% ------------------------------------------------------------
% ELECTIVE COURSES BY CAREER PATH
% elective(CourseID, CareerPath)
% ------------------------------------------------------------
elective(dcit407, ai_and_ml).
elective(dcit313, ai_and_ml).
elective(dcit301, ai_and_ml).

elective(dcit405, cybersecurity).
elective(dcit307, cybersecurity).
elective(dcit403, cybersecurity).

elective(dcit409, software_engineering).
elective(dcit309, software_engineering).
elective(dcit203, software_engineering).

elective(dcit411, cloud_and_networks).
elective(dcit403, cloud_and_networks).
elective(dcit307, cloud_and_networks).

elective(dcit413, data_science).
elective(dcit407, data_science).
elective(dcit205, data_science).

elective(dcit409, mobile_development).
elective(dcit203, mobile_development).
elective(dcit209, mobile_development).

elective(dcit415, ai_and_ml).
elective(dcit417, ai_and_ml).
elective(dcit419, cybersecurity).
elective(dcit421, cybersecurity).
elective(dcit423, software_engineering).
elective(dcit425, software_engineering).
elective(dcit427, cloud_and_networks).
elective(dcit429, cloud_and_networks).
elective(dcit431, data_science).
elective(dcit433, data_science).
elective(dcit435, mobile_development).
elective(dcit437, mobile_development).

% ------------------------------------------------------------
% MINIMUM CREDITS TO GRADUATE
% ------------------------------------------------------------
min_credits_to_graduate(120).

% ------------------------------------------------------------
% GRADUATION YEAR REQUIREMENT (must be at least year 4)
% ------------------------------------------------------------
min_year_to_graduate(4).

% ============================================================
%  SAMPLE STUDENT DATABASE
%  student(ID, Name, CurrentGPA, YearLevel, [CompletedCourses])
% ============================================================

student(s001, 'Kwame Asante',       3.6, 3,
    [dcit101, dcit103, dcit105, dcit107, dcit109,
     dcit201, dcit203, dcit205, dcit207, dcit209]).

student(s002, 'Ama Serwaa',         1.7, 2,
    [dcit101, dcit103, dcit105]).

student(s003, 'Kofi Boateng',       2.4, 3,
    [dcit101, dcit103, dcit105, dcit107, dcit109,
     dcit201, dcit203]).

student(s004, 'Abena Mensah',       3.1, 4,
    [dcit101, dcit103, dcit105, dcit107, dcit109,
     dcit201, dcit203, dcit205, dcit207, dcit209,
     dcit301, dcit303, dcit305, dcit307, dcit309,
     dcit311, dcit313]).

student(s005, 'Yaw Darko',          2.8, 2,
    [dcit101, dcit103, dcit105, dcit107, dcit109,
     dcit201, dcit203, dcit205]).
