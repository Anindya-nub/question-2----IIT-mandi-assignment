
-- ============================================================
-- Q01: List all active students with student ID, name, email, batch, and admission date.
-- Purpose: List all active students with student ID, name, email, batch, and admission date.
-- Result summary: 232 active students were returned. The query joins students to batches using batch_id, so the readable batch_code is shown beside each active student. The typo status value actve is intentionally not counted as active.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT s.student_id,
       s.full_name,
       s.email,
       b.batch_code AS batch,
       s.admission_date
FROM students s
LEFT JOIN batches b
       ON s.batch_id = b.batch_id
WHERE LOWER(TRIM(s.enrollment_status)) = 'active'
ORDER BY s.student_id;

-- ============================================================
-- Q02: Find students whose email is missing or appears invalid.
-- Purpose: Find students whose email is missing or appears invalid.
-- Result summary: 2 students were returned: one blank email and one email-like string without the @ symbol. This matches the expected data-quality issue in the student master table.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT student_id,
       full_name,
       email
FROM students
WHERE email IS NULL
   OR TRIM(email) = ''
   OR email NOT LIKE '%_@_%._%'
   OR email LIKE '% %'
ORDER BY student_id;

-- ============================================================
-- Q03: List all problems with difficulty level Easy or Medium.
-- Purpose: List all problems with difficulty level Easy or Medium.
-- Result summary: 60 problems were returned. The dataset has 36 Easy problems and 24 Medium problems, so the total is logically correct.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT problem_id,
       problem_code,
       title,
       difficulty,
       max_score
FROM problems
WHERE difficulty IN ('Easy', 'Medium')
ORDER BY difficulty, problem_id;

-- ============================================================
-- Q04: Display the latest 20 submissions based on submission timestamp.
-- Purpose: Display the latest 20 submissions based on submission timestamp.
-- Result summary: 20 rows were returned because of LIMIT 20. The first row has the latest submitted_at value in the raw submissions table: 2025-08-12 03:44:00.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT submission_id,
       student_id,
       problem_id,
       language,
       status,
       score,
       submitted_at
FROM submissions
ORDER BY datetime(submitted_at) DESC
LIMIT 20;

-- ============================================================
-- Q05: Find submissions where the status is not successful.
-- Purpose: Find submissions where the status is not successful.
-- Result summary: 1374 unsuccessful submissions were returned. This equals total submissions minus Accepted submissions: 2501 - 1127 = 1374.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT submission_id,
       student_id,
       problem_id,
       language,
       status,
       score,
       submitted_at
FROM submissions
WHERE status <> 'Accepted'
ORDER BY datetime(submitted_at) DESC;

-- ============================================================
-- Q06: Display each submission with student name, problem title, language, status, score, and submitted time.
-- Purpose: Display each submission with student name, problem title, language, status, score, and submitted time.
-- Result summary: 2499 joined rows were returned from 2501 raw submissions. Two submissions are dropped by INNER JOIN because the raw data contains one orphan student_id and one orphan problem_id.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT sub.submission_id,
       stu.full_name AS student_name,
       p.title AS problem_title,
       sub.language,
       sub.status,
       sub.score,
       sub.submitted_at
FROM submissions sub
JOIN students stu
     ON sub.student_id = stu.student_id
JOIN problems p
     ON sub.problem_id = p.problem_id
ORDER BY datetime(sub.submitted_at) DESC;

-- ============================================================
-- Q07: Display all students and their enrollments, including students who are not enrolled in any course.
-- Purpose: Display all students and their enrollments, including students who are not enrolled in any course.
-- Result summary: 718 rows were returned. Every valid student has at least one enrollment in this dataset, and the raw orphan enrollment for S9999 is not shown because the query starts from students.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT s.student_id,
       s.full_name,
       c.course_code,
       c.course_title,
       e.enrollment_status,
       e.final_grade
FROM students s
LEFT JOIN enrollments e
       ON s.student_id = e.student_id
LEFT JOIN courses c
       ON e.course_id = c.course_id
ORDER BY s.student_id, c.course_code;

-- ============================================================
-- Q08: Display all courses with the number of enrolled students.
-- Purpose: Display all courses with the number of enrolled students.
-- Result summary: 10 courses were returned, matching the course catalog. COUNT(DISTINCT e.student_id) avoids inflated counts if duplicate enrollment rows exist.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT c.course_id,
       c.course_code,
       c.course_title,
       COUNT(DISTINCT e.student_id) AS enrolled_student_count
FROM courses c
LEFT JOIN enrollments e
       ON c.course_id = e.course_id
GROUP BY c.course_id, c.course_code, c.course_title
ORDER BY enrolled_student_count DESC, c.course_id;

-- ============================================================
-- Q09: Display test-case results for each submission, including problem title and student name.
-- Purpose: Display test-case results for each submission, including problem title and student name.
-- Result summary: 9671 joined rows were returned from 9673 raw test_results rows. Two rows are not shown because of raw orphan references in test_results/submissions/test_cases.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT tr.result_id,
       sub.submission_id,
       stu.full_name AS student_name,
       p.title AS problem_title,
       tc.case_no,
       tr.result_status,
       tr.awarded_points,
       tr.runtime_ms,
       tr.memory_kb
FROM test_results tr
JOIN submissions sub
     ON tr.submission_id = sub.submission_id
JOIN students stu
     ON sub.student_id = stu.student_id
JOIN problems p
     ON sub.problem_id = p.problem_id
JOIN test_cases tc
     ON tr.test_case_id = tc.test_case_id
ORDER BY sub.submission_id, CAST(tc.case_no AS INTEGER);

-- ============================================================
-- Q10: Find students who are enrolled in a course but have not submitted any solution for that course.
-- Purpose: Find students who are enrolled in a course but have not submitted any solution for that course.
-- Result summary: 288 student-course enrollment rows were returned. These are cases where the student has an enrollment record but no submission against any problem belonging to that same course.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT s.student_id,
       s.full_name,
       c.course_id,
       c.course_code,
       c.course_title
FROM enrollments e
JOIN students s
     ON e.student_id = s.student_id
JOIN courses c
     ON e.course_id = c.course_id
WHERE NOT EXISTS (
    SELECT 1
    FROM submissions sub
    JOIN problems p
         ON sub.problem_id = p.problem_id
    WHERE sub.student_id = e.student_id
      AND p.course_id = e.course_id
)
ORDER BY s.student_id, c.course_code;

-- ============================================================
-- Q11: Count submissions by status.
-- Purpose: Count submissions by status.
-- Result summary: 6 status groups were returned. The normal major groups are Accepted, Wrong Answer, Runtime Error, Compilation Error, and Time Limit Exceeded; the extra OK status appears once and shows raw-status inconsistency.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT status,
       COUNT(*) AS submission_count
FROM submissions
GROUP BY status
ORDER BY submission_count DESC;

-- ============================================================
-- Q12: Calculate average score per problem.
-- Purpose: Calculate average score per problem.
-- Result summary: 67 problems were returned, matching the problem catalog. LEFT JOIN keeps problems with zero attempts, where average_score would be NULL.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT p.problem_id,
       p.problem_code,
       p.title,
       ROUND(AVG(CAST(sub.score AS REAL)), 2) AS average_score,
       COUNT(sub.submission_id) AS submission_count
FROM problems p
LEFT JOIN submissions sub
       ON p.problem_id = sub.problem_id
GROUP BY p.problem_id, p.problem_code, p.title
ORDER BY average_score DESC;

-- ============================================================
-- Q13: Find students with more than a chosen number of submissions. The chosen threshold is 10.
-- Purpose: Find students with more than a chosen number of submissions. The chosen threshold is 10.
-- Result summary: 51 students were returned using the threshold of more than 10 submissions. HAVING is needed because the filter is based on a grouped count.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT s.student_id,
       s.full_name,
       COUNT(sub.submission_id) AS submission_count
FROM students s
JOIN submissions sub
     ON s.student_id = sub.student_id
GROUP BY s.student_id, s.full_name
HAVING COUNT(sub.submission_id) > 10
ORDER BY submission_count DESC, s.student_id;

-- ============================================================
-- Q14: Find problems where the success rate is below 40%.
-- Purpose: Find problems where the success rate is below 40%.
-- Result summary: 13 problems were returned. Every listed problem has accepted_attempts / total_attempts below 0.40, for example P0064 has 12 accepted out of 40 attempts = 30.00%.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT p.problem_id,
       p.problem_code,
       p.title,
       COUNT(sub.submission_id) AS total_attempts,
       SUM(CASE WHEN sub.status = 'Accepted' THEN 1 ELSE 0 END) AS accepted_attempts,
       ROUND(
           100.0 * SUM(CASE WHEN sub.status = 'Accepted' THEN 1 ELSE 0 END)
           / COUNT(sub.submission_id),
           2
       ) AS success_rate_percent
FROM problems p
JOIN submissions sub
     ON p.problem_id = sub.problem_id
GROUP BY p.problem_id, p.problem_code, p.title
HAVING COUNT(sub.submission_id) > 0
   AND (
       1.0 * SUM(CASE WHEN sub.status = 'Accepted' THEN 1 ELSE 0 END)
       / COUNT(sub.submission_id)
   ) < 0.40
ORDER BY success_rate_percent ASC, total_attempts DESC;

-- ============================================================
-- Q15: Find students whose average score is greater than the overall average score.
-- Purpose: Find students whose average score is greater than the overall average score.
-- Result summary: 151 students were returned. The overall average score is 43.94, so every listed student has a personal average above that value. One high outlier score in the raw data makes S0019 appear unusually high, which is a useful validation/audit observation.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT s.student_id,
       s.full_name,
       ROUND(AVG(CAST(sub.score AS REAL)), 2) AS student_average_score
FROM students s
JOIN submissions sub
     ON s.student_id = sub.student_id
GROUP BY s.student_id, s.full_name
HAVING AVG(CAST(sub.score AS REAL)) > (
    SELECT AVG(CAST(score AS REAL))
    FROM submissions
)
ORDER BY student_average_score DESC, s.student_id;

-- ============================================================
-- Q16: Find problems that have never been attempted.
-- Purpose: Find problems that have never been attempted.
-- Result summary: 1 problem was returned: P0036. This makes sense because it exists in problems but no row in submissions references it.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT p.problem_id,
       p.problem_code,
       p.title,
       p.difficulty
FROM problems p
LEFT JOIN submissions sub
       ON p.problem_id = sub.problem_id
WHERE sub.submission_id IS NULL
ORDER BY p.problem_id;

-- ============================================================
-- Q17: Find students who have enrolled but never submitted any solution.
-- Purpose: Find students who have enrolled but never submitted any solution.
-- Result summary: 0 students were returned. This means all valid students who appear in enrollments also have at least one submission somewhere in the raw submissions table.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT s.student_id,
       s.full_name,
       s.email
FROM students s
WHERE EXISTS (
    SELECT 1
    FROM enrollments e
    WHERE e.student_id = s.student_id
)
AND NOT EXISTS (
    SELECT 1
    FROM submissions sub
    WHERE sub.student_id = s.student_id
)
ORDER BY s.student_id;

-- ============================================================
-- Q18: Find students who submitted solutions in both Python and Java.
-- Purpose: Find students who submitted solutions in both Python and Java.
-- Result summary: 181 students were returned. For each listed student, both conditional counts are greater than zero, proving that they submitted in both Python and Java.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT s.student_id,
       s.full_name,
       SUM(CASE WHEN sub.language = 'Python' THEN 1 ELSE 0 END) AS python_submissions,
       SUM(CASE WHEN sub.language = 'Java' THEN 1 ELSE 0 END) AS java_submissions
FROM students s
JOIN submissions sub
     ON s.student_id = sub.student_id
GROUP BY s.student_id, s.full_name
HAVING SUM(CASE WHEN sub.language = 'Python' THEN 1 ELSE 0 END) > 0
   AND SUM(CASE WHEN sub.language = 'Java' THEN 1 ELSE 0 END) > 0
ORDER BY s.student_id;

-- ============================================================
-- Q19: Find the top 10 most attempted problems.
-- Purpose: Find the top 10 most attempted problems.
-- Result summary: 10 rows were returned because of LIMIT 10. P0040 is the most attempted problem with 55 attempts.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT p.problem_id,
       p.problem_code,
       p.title,
       COUNT(sub.submission_id) AS attempt_count
FROM problems p
JOIN submissions sub
     ON p.problem_id = sub.problem_id
GROUP BY p.problem_id, p.problem_code, p.title
ORDER BY attempt_count DESC, p.problem_id
LIMIT 10;

-- ============================================================
-- Q20: Find the second-highest score for a selected problem. The selected problem is P0001.
-- Purpose: Find the second-highest score for a selected problem. The selected problem is P0001.
-- Result summary: The second-highest distinct score for P0001 is 72. The highest distinct score is 75, so the query correctly selects the next lower distinct value.
-- Validation note: The row counts/sample outputs are documented in query_outputs.md.
-- ============================================================
SELECT MAX(score_value) AS second_highest_score_for_P0001
FROM (
    SELECT DISTINCT CAST(score AS INTEGER) AS score_value
    FROM submissions
    WHERE problem_id = 'P0001'
      AND score IS NOT NULL
) ranked_scores
WHERE score_value < (
    SELECT MAX(CAST(score AS INTEGER))
    FROM submissions
    WHERE problem_id = 'P0001'
);
