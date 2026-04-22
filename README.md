# DCIT313-Group AI Squad — Smart Academic Advisor (SAA)

**University of Ghana, Department of Computer Science**
Semester I, 2025/2026 | Supervisor: Prof. Kofi S. Adu-Manu

---

## Project Objective

The objective of this project is to design and implement a Knowledge-Based System (KBS) that functions as an Intelligent Agent. This Smart Academic Advisor (SAA) is an AI-powered Expert System designed to assist students in making informed academic decisions, such as course planning and prerequisite management. The system demonstrates a clear mapping from perceptions (student data/career interests) to actions (course recommendations/alerts).

---

## Group Members & Roles

| Name | Student ID | Primary Project Role | Username |
| :--- | :--- | :--- | :--- |
| *Frederick Kwaku Kankam* | 22015587 | Project Manager | N/A |
| *Victor Barnieh* | 22134010 | Knowledge/Expert Engineer | N/A
| *Effah Gilbert* | 22241265 | Knowledge/Expert Engineer | Kobby24
| *Moses Ampadu Danso* | 22043205 | Programmer/Developer | N/A |
| *Richmond Nyamedor* | 22173542 | Programmer/Developer | N/A |
| *Justice Osei Sarfo* | 22223502 | Programmer/Developer | N/A |
| *Stella Oforiwaa Bonsu* | 22232107 | Programmer/Developer | N/A |

---

## Overview

The SAA is a **Rule-Based Expert System** built in Prolog. It helps students make informed academic decisions by automatically checking prerequisites, assessing academic risk, recommending courses, and evaluating graduation eligibility — all driven by IF-THEN rules and Prolog's built-in inference engine.

---

## Project Structure

```
├── saa_knowledge_base.pl   # Facts: courses, prerequisites, students, career paths
├── saa_rules.pl            # Inference engine: all IF-THEN rules
├── saa_main.pl             # Entry point: query interface and print utilities
├── saa_web.pl              # Web server + JSON API
├── web/index.html          # Browser GUI
└── README.md
```

---

## Requirements

- [SWI-Prolog](https://www.swi-prolog.org/) version 8+

**Install on macOS:**
```bash
brew install swi-prolog
```

**Install on Ubuntu/Debian:**
```bash
sudo apt install swi-prolog
```

**Install on Windows:**
Download the installer from https://www.swi-prolog.org/download/stable

---

## How to Run

### Interactive Mode (recommended for demos)
```bash
swipl saa_main.pl
```

### Web GUI Mode (browser interface)
One-command launcher (macOS/Linux):
```bash
./run_web.sh
```
Optional port:
```bash
./run_web.sh 9090
```

Manual mode:
```bash
swipl saa_web.pl
```
Then in the Prolog prompt:
```prolog
start_server.
```
Open in browser:
```text
http://localhost:8080
```

Optional custom port:
```prolog
start_server(9090).
```

Stop the server:
```prolog
stop_server.
```

### Next.js App Mode (full frontend + Prolog backend)
1) Start Prolog backend in one terminal:
```bash
./run_web.sh 8080
```

2) Start Next frontend in another terminal:
```bash
cd frontend
npm install
PROLOG_API_BASE=http://localhost:8080/api npm run dev -- --port 3001
```

3) Open:
```text
http://localhost:3001
```

This mode supports:
- Creating custom student profiles
- Saving profiles in backend memory (`/api/profiles`)
- Evaluating profile progress and next steps with improved validation/error handling

### Run Full Demo (all sample students)
```bash
swipl -g "run_demo, halt" saa_main.pl
```

---

## Available Queries

Once the system is loaded in interactive mode, type any of these:

| Query | Description |
|---|---|
| `advise(StudentID).` | Full advisory report for a student |
| `career_advise(StudentID, CareerPath).` | Electives aligned to a career interest |
| `check_prereq(StudentID, CourseID).` | Check if a student can register for a course |
| `run_demo.` | Run reports for all sample students |

### Example Queries
```prolog
advise(s001).
advise(s002).
career_advise(s001, ai_and_ml).
career_advise(s004, cybersecurity).
check_prereq(s002, dcit313).
check_prereq(s003, dcit407).
```

### Available Career Paths
| Path | Description |
|---|---|
| `ai_and_ml` | Artificial Intelligence & Machine Learning |
| `cybersecurity` | Information Security |
| `software_engineering` | Software Development |
| `cloud_and_networks` | Cloud Computing & Networking |
| `data_science` | Data Science & Analytics |
| `mobile_development` | Mobile Application Development |

### Sample Student IDs
| ID | Name | GPA | Year |
|---|---|---|---|
| s001 | Kwame Asante | 3.6 | 3 |
| s002 | Ama Serwaa | 1.7 | 2 |
| s003 | Kofi Boateng | 2.4 | 3 |
| s004 | Abena Mensah | 3.1 | 4 |
| s005 | Yaw Darko | 2.8 | 2 |

---

## System Rules (Inference Engine)

| Rule | Logic |
|---|---|
| **Prerequisite Check** | IF all prerequisites not passed → THEN block registration |
| **GPA Classification** | IF GPA ≥ 3.6 → First Class; ≥ 3.0 → 2nd Upper; ≥ 2.5 → 2nd Lower; ≥ 2.0 → Pass; < 2.0 → Probation |
| **Academic Risk** | IF GPA < 1.5 → Critical; < 2.0 → High; < 2.5 → Moderate; ≥ 2.5 → Low |
| **Improvement Strategy** | IF risk level = X → THEN tailored advice list |
| **Course Recommendation** | IF prerequisites met AND course not taken → THEN recommend |
| **Graduation Eligibility** | IF credits ≥ 120 AND required courses done AND GPA ≥ 2.0 AND Year 4 → Eligible |

---

## Adding a New Student

Open `saa_knowledge_base.pl` and add a fact in this format:

```prolog
student(
    s006,                        % Student ID
    'Your Name',                 % Full name
    2.9,                         % Current GPA
    2,                           % Year level (1–4)
    [dcit101, dcit103, dcit105]  % List of completed course IDs
).
```

Then reload and query:
```prolog
advise(s006).
```
