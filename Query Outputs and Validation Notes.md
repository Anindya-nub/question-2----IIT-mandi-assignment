# Query Outputs and Validation Notes

This file documents the output observed after running `queries.sql` on the raw SQLite database imported from the supplied CodeJudge CSV files.

The tables were imported with flexible text columns because the source dataset intentionally contains messy records such as inconsistent statuses and orphan references.

## Q01. List all active students with student ID, name, email, batch, and admission date.

**Purpose:** List all active students with student ID, name, email, batch, and admission date.

**Result summary:** 232 row(s) returned.

**Sample output:**

| student_id | full_name | email | batch | admission_date |
| --- | --- | --- | --- | --- |
| S0001 | Vivaan Gupta | vivaan.gupta001@codejudge.edu | CSE2025B | 2025-02-13 |
| S0002 | Harsh Das | harsh.das002@codejudge.edu | MCA2025A | 2025-04-08 |
| S0004 | Ananya Bose | ananya.bose004@codejudge.edu | CSE2026A | 2025-02-19 |
| S0005 | Ayaan Gupta |  | AIML2025A | 2025-01-27 |
| S0006 | Isha Mehta | isha.mehta006@codejudge.edu | CSE2025A | 2025-03-14 |

**Validation note:** 232 active students were returned. The query joins students to batches using batch_id, so the readable batch_code is shown beside each active student. The typo status value actve is intentionally not counted as active.

## Q02. Find students whose email is missing or appears invalid.

**Purpose:** Find students whose email is missing or appears invalid.

**Result summary:** 2 row(s) returned.

**Sample output:**

| student_id | full_name | email |
| --- | --- | --- |
| S0005 | Ayaan Gupta |  |
| S0018 | Anika Patel | ravi.no-at-symbol.codejudge.edu |

**Validation note:** 2 students were returned: one blank email and one email-like string without the @ symbol. This matches the expected data-quality issue in the student master table.

## Q03. List all problems with difficulty level Easy or Medium.

**Purpose:** List all problems with difficulty level Easy or Medium.

**Result summary:** 60 row(s) returned.

**Sample output:**

| problem_id | problem_code | title | difficulty | max_score |
| --- | --- | --- | --- | --- |
| P0002 | CS101_P02 | Dynamic Programming Basics 2 | Easy | 50 |
| P0003 | CS101_P03 | Dynamic Programming Basics 3 | Easy | 50 |
| P0004 | CS101_P04 | Normalization Check 4 | Easy | 50 |
| P0005 | CS101_P05 | Queue using Stacks 5 | Easy | 50 |
| P0012 | CS102_P03 | Queue using Stacks 12 | Easy | 50 |

**Validation note:** 60 problems were returned. The dataset has 36 Easy problems and 24 Medium problems, so the total is logically correct.

## Q04. Display the latest 20 submissions based on submission timestamp.

**Purpose:** Display the latest 20 submissions based on submission timestamp.

**Result summary:** 20 row(s) returned.

**Sample output:**

| submission_id | student_id | problem_id | language | status | score | submitted_at |
| --- | --- | --- | --- | --- | --- | --- |
| SUB001091 | S0074 | P0025 | C++ | Runtime Error | 12 | 2025-08-12 03:44:00 |
| SUB001593 | S0007 | P0005 | Go | Accepted | 50 | 2025-08-05 20:47:00 |
| SUB000123 | S0002 | P0067 | C | Accepted | 50 | 2025-08-04 15:30:00 |
| SUB001144 | S0007 | P0006 | Go | Compilation Error | 0 | 2025-07-31 02:49:00 |
| SUB000878 | S0142 | P0066 | Go | Accepted | 75 | 2025-07-31 01:38:00 |

**Validation note:** 20 rows were returned because of LIMIT 20. The first row has the latest submitted_at value in the raw submissions table: 2025-08-12 03:44:00.

## Q05. Find submissions where the status is not successful.

**Purpose:** Find submissions where the status is not successful.

**Result summary:** 1374 row(s) returned.

**Sample output:**

| submission_id | student_id | problem_id | language | status | score | submitted_at |
| --- | --- | --- | --- | --- | --- | --- |
| SUB001091 | S0074 | P0025 | C++ | Runtime Error | 12 | 2025-08-12 03:44:00 |
| SUB001144 | S0007 | P0006 | Go | Compilation Error | 0 | 2025-07-31 02:49:00 |
| SUB000751 | S0120 | P0015 | Python | Wrong Answer | 28 | 2025-07-27 01:11:00 |
| SUB001740 | S0052 | P0047 | Go | Compilation Error | 0 | 2025-07-24 17:14:00 |
| SUB001072 | S0283 | P0062 | Go | Runtime Error | 15 | 2025-07-23 08:44:00 |

**Validation note:** 1374 unsuccessful submissions were returned. This equals total submissions minus Accepted submissions: 2501 - 1127 = 1374.

## Q06. Display each submission with student name, problem title, language, status, score, and submitted time.

**Purpose:** Display each submission with student name, problem title, language, status, score, and submitted time.

**Result summary:** 2499 row(s) returned.

**Sample output:**

| submission_id | student_name | problem_title | language | status | score | submitted_at |
| --- | --- | --- | --- | --- | --- | --- |
| SUB001091 | Neil Ghosh | Trie Search 25 | C++ | Runtime Error | 12 | 2025-08-12 03:44:00 |
| SUB001593 | Reyansh Kulkarni | Queue using Stacks 5 | Go | Accepted | 50 | 2025-08-05 20:47:00 |
| SUB000123 | Harsh Das | Reverse String 67 | C | Accepted | 50 | 2025-08-04 15:30:00 |
| SUB001144 | Reyansh Kulkarni | Graph Traversal 6 | Go | Compilation Error | 0 | 2025-07-31 02:49:00 |
| SUB000878 | Amit Gupta | Database Indexing 66 | Go | Accepted | 75 | 2025-07-31 01:38:00 |

**Validation note:** 2499 joined rows were returned from 2501 raw submissions. Two submissions are dropped by INNER JOIN because the raw data contains one orphan student_id and one orphan problem_id.

## Q07. Display all students and their enrollments, including students who are not enrolled in any course.

**Purpose:** Display all students and their enrollments, including students who are not enrolled in any course.

**Result summary:** 718 row(s) returned.

**Sample output:**

| student_id | full_name | course_code | course_title | enrollment_status | final_grade |
| --- | --- | --- | --- | --- | --- |
| S0001 | Vivaan Gupta | CS101 | Programming Fundamentals | active |  |
| S0001 | Vivaan Gupta | CS203 | Computer Networks | active | C |
| S0001 | Vivaan Gupta | CS203 | Computer Networks | active | C |
| S0002 | Harsh Das | CS103 | Object Oriented Programming | active | A |
| S0002 | Harsh Das | CS205 | Software Engineering | active | C |

**Validation note:** 718 rows were returned. Every valid student has at least one enrollment in this dataset, and the raw orphan enrollment for S9999 is not shown because the query starts from students.

## Q08. Display all courses with the number of enrolled students.

**Purpose:** Display all courses with the number of enrolled students.

**Result summary:** 10 row(s) returned.

**Sample output:**

| course_id | course_code | course_title | enrolled_student_count |
| --- | --- | --- | --- |
| C002 | CS102 | Data Structures | 101 |
| C005 | CS202 | Operating Systems | 99 |
| C007 | CS204 | Algorithms | 94 |
| C006 | CS203 | Computer Networks | 90 |
| C003 | CS103 | Object Oriented Programming | 89 |

**Validation note:** 10 courses were returned, matching the course catalog. COUNT(DISTINCT e.student_id) avoids inflated counts if duplicate enrollment rows exist.

## Q09. Display test-case results for each submission, including problem title and student name.

**Purpose:** Display test-case results for each submission, including problem title and student name.

**Result summary:** 9671 row(s) returned.

**Sample output:**

| result_id | submission_id | student_name | problem_title | case_no | result_status | awarded_points | runtime_ms | memory_kb |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| R0000005 | SUB000001 | Isha Gupta | Dynamic Programming Basics 43 | 2 | Passed | 8 | 3870 | 30844 |
| R0000002 | SUB000001 | Isha Gupta | Dynamic Programming Basics 43 | 3 | Failed | 0 | 3549 | 55785 |
| R0000001 | SUB000001 | Isha Gupta | Dynamic Programming Basics 43 | 4 | Runtime Error | 0 | 586 | 107784 |
| R0000004 | SUB000001 | Isha Gupta | Dynamic Programming Basics 43 | 5 | Time Limit Exceeded | 0 | 2913 | 65024 |
| R0000003 | SUB000001 | Isha Gupta | Dynamic Programming Basics 43 | 6 | Runtime Error | 0 | 3075 | 59141 |

**Validation note:** 9671 joined rows were returned from 9673 raw test_results rows. Two rows are not shown because of raw orphan references in test_results/submissions/test_cases.

## Q10. Find students who are enrolled in a course but have not submitted any solution for that course.

**Purpose:** Find students who are enrolled in a course but have not submitted any solution for that course.

**Result summary:** 288 row(s) returned.

**Sample output:**

| student_id | full_name | course_id | course_code | course_title |
| --- | --- | --- | --- | --- |
| S0004 | Ananya Bose | C001 | CS101 | Programming Fundamentals |
| S0004 | Ananya Bose | C002 | CS102 | Data Structures |
| S0010 | Rohan Singh | C007 | CS204 | Algorithms |
| S0013 | Harsh Roy | C004 | CS201 | Database Management Systems |
| S0013 | Harsh Roy | C007 | CS204 | Algorithms |

**Validation note:** 288 student-course enrollment rows were returned. These are cases where the student has an enrollment record but no submission against any problem belonging to that same course.

## Q11. Count submissions by status.

**Purpose:** Count submissions by status.

**Result summary:** 6 row(s) returned.

**Sample output:**

| status | submission_count |
| --- | --- |
| Accepted | 1127 |
| Wrong Answer | 729 |
| Runtime Error | 277 |
| Compilation Error | 196 |
| Time Limit Exceeded | 171 |

**Validation note:** 6 status groups were returned. The normal major groups are Accepted, Wrong Answer, Runtime Error, Compilation Error, and Time Limit Exceeded; the extra OK status appears once and shows raw-status inconsistency.

## Q12. Calculate average score per problem.

**Purpose:** Calculate average score per problem.

**Result summary:** 67 row(s) returned.

**Sample output:**

| problem_id | problem_code | title | average_score | submission_count |
| --- | --- | --- | --- | --- |
| P0021 | CS103_P02 | SQL Joins 21 | 90.72 | 43 |
| P0018 | CS102_P09 | Database Indexing 18 | 79.43 | 42 |
| P0017 | CS102_P08 | Tree Diameter 17 | 71.91 | 32 |
| P0008 | CS101_P08 | LRU Cache 8 | 66.72 | 36 |
| P0040 | CS202_P06 | Graph Traversal 40 | 65.8 | 55 |

**Validation note:** 67 problems were returned, matching the problem catalog. LEFT JOIN keeps problems with zero attempts, where average_score would be NULL.

## Q13. Find students with more than a chosen number of submissions. The chosen threshold is 10.

**Purpose:** Find students with more than a chosen number of submissions. The chosen threshold is 10.

**Result summary:** 51 row(s) returned.

**Sample output:**

| student_id | full_name | submission_count |
| --- | --- | --- |
| S0052 | Kabir Mehta | 19 |
| S0126 | Yash Khan | 17 |
| S0133 | Dhruv Patel | 16 |
| S0146 | Nisha Iyer | 16 |
| S0060 | Isha Das | 15 |

**Validation note:** 51 students were returned using the threshold of more than 10 submissions. HAVING is needed because the filter is based on a grouped count.

## Q14. Find problems where the success rate is below 40%.

**Purpose:** Find problems where the success rate is below 40%.

**Result summary:** 13 row(s) returned.

**Sample output:**

| problem_id | problem_code | title | total_attempts | accepted_attempts | success_rate_percent |
| --- | --- | --- | --- | --- | --- |
| P0064 | CS205_P06 | Trie Search 64 | 40 | 12 | 30.0 |
| P0028 | CS201_P02 | Valid Parentheses 28 | 38 | 12 | 31.58 |
| P0008 | CS101_P08 | LRU Cache 8 | 36 | 12 | 33.33 |
| P0055 | CS204_P06 | Merge Intervals 55 | 27 | 9 | 33.33 |
| P0032 | CS201_P06 | Valid Parentheses 32 | 47 | 16 | 34.04 |

**Validation note:** 13 problems were returned. Every listed problem has accepted_attempts / total_attempts below 0.40, for example P0064 has 12 accepted out of 40 attempts = 30.00%.

## Q15. Find students whose average score is greater than the overall average score.

**Purpose:** Find students whose average score is greater than the overall average score.

**Result summary:** 151 row(s) returned.

**Sample output:**

| student_id | full_name | student_average_score |
| --- | --- | --- |
| S0019 | Arjun Reddy | 197.83 |
| S0112 | Aditya Sharma | 97.5 |
| S0021 | Priya Mehta | 73.75 |
| S0123 | Kunal Kulkarni | 73.75 |
| S0241 | Ayaan Patel | 73.0 |

**Validation note:** 151 students were returned. The overall average score is 43.94, so every listed student has a personal average above that value. One high outlier score in the raw data makes S0019 appear unusually high, which is a useful validation/audit observation.

## Q16. Find problems that have never been attempted.

**Purpose:** Find problems that have never been attempted.

**Result summary:** 1 row(s) returned.

**Sample output:**

| problem_id | problem_code | title | difficulty |
| --- | --- | --- | --- |
| P0036 | CS202_P02 | Trie Search 36 | Hard |

**Validation note:** 1 problem was returned: P0036. This makes sense because it exists in problems but no row in submissions references it.

## Q17. Find students who have enrolled but never submitted any solution.

**Purpose:** Find students who have enrolled but never submitted any solution.

**Result summary:** 0 row(s) returned.

**Sample output:**

| student_id | full_name | email |
| --- | --- | --- |

**Validation note:** 0 students were returned. This means all valid students who appear in enrollments also have at least one submission somewhere in the raw submissions table.

## Q18. Find students who submitted solutions in both Python and Java.

**Purpose:** Find students who submitted solutions in both Python and Java.

**Result summary:** 181 row(s) returned.

**Sample output:**

| student_id | full_name | python_submissions | java_submissions |
| --- | --- | --- | --- |
| S0002 | Harsh Das | 1 | 1 |
| S0003 | Ira Pillai | 1 | 1 |
| S0005 | Ayaan Gupta | 3 | 1 |
| S0006 | Isha Mehta | 7 | 3 |
| S0007 | Reyansh Kulkarni | 4 | 2 |

**Validation note:** 181 students were returned. For each listed student, both conditional counts are greater than zero, proving that they submitted in both Python and Java.

## Q19. Find the top 10 most attempted problems.

**Purpose:** Find the top 10 most attempted problems.

**Result summary:** 10 row(s) returned.

**Sample output:**

| problem_id | problem_code | title | attempt_count |
| --- | --- | --- | --- |
| P0040 | CS202_P06 | Graph Traversal 40 | 55 |
| P0001 | CS101_P01 | Shortest Path 1 | 53 |
| P0019 | CS102_P10 | Dynamic Programming Basics 19 | 53 |
| P0043 | CS203_P02 | Dynamic Programming Basics 43 | 49 |
| P0045 | CS203_P04 | Deadlock Detection 45 | 49 |

**Validation note:** 10 rows were returned because of LIMIT 10. P0040 is the most attempted problem with 55 attempts.

## Q20. Find the second-highest score for a selected problem. The selected problem is P0001.

**Purpose:** Find the second-highest score for a selected problem. The selected problem is P0001.

**Result summary:** 1 row(s) returned.

**Sample output:**

| second_highest_score_for_P0001 |
| --- |
| 72 |

**Validation note:** The second-highest distinct score for P0001 is 72. The highest distinct score is 75, so the query correctly selects the next lower distinct value.
