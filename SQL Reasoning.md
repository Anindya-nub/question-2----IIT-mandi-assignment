# SQL Reasoning

## 1. Query where LEFT JOIN is more appropriate than INNER JOIN

`Q07` uses `LEFT JOIN` to display all students and their enrollments.

```sql
FROM students s
LEFT JOIN enrollments e ON s.student_id = e.student_id
LEFT JOIN courses c ON e.course_id = c.course_id
```

This is better than `INNER JOIN` because the requirement says to include students who are not enrolled in any course. An `INNER JOIN` would remove students without matching enrollment rows. In this dataset, every valid student has at least one enrollment, but the `LEFT JOIN` is still the correct design because it protects the query from hiding non-enrolled students if such records are added later.

## 2. Query where HAVING is required instead of WHERE

`Q13` uses `HAVING` to find students with more than 10 submissions.

```sql
GROUP BY s.student_id, s.full_name
HAVING COUNT(sub.submission_id) > 10
```

`WHERE` filters individual rows before grouping. Here, the condition depends on the aggregate value `COUNT(sub.submission_id)`, which only exists after the `GROUP BY` step. Therefore, `HAVING` is required.

`Q14` also uses `HAVING` because the success rate is calculated from grouped submission counts.

## 3. Query where a subquery helped solve the problem

`Q15` uses a subquery to compare each student's average score with the overall average score.

```sql
HAVING AVG(CAST(sub.score AS REAL)) > (
    SELECT AVG(CAST(score AS REAL))
    FROM submissions
)
```

The inner query calculates the overall average score across all submissions. The outer query calculates each student's average score. The subquery makes it possible to compare a grouped student-level value with one global value from the whole submissions table.

`Q10` also uses `NOT EXISTS` to find enrolled student-course pairs where the student has not submitted for any problem in that course.

## 4. Situation where duplicate records could make the output misleading

`Q08` counts enrolled students per course. If duplicate enrollment records exist for the same student and course, a normal `COUNT(e.student_id)` would overcount students.

That is why the query uses:

```sql
COUNT(DISTINCT e.student_id)
```

This avoids counting the same student more than once for the same course-level report.

A similar issue appears in `Q07`, where duplicate enrollment rows can make the same student-course pair appear more than once. That output is useful for auditing, but it should not be treated as a clean enrollment count unless duplicates are handled.

## 5. Edge case considered while writing the queries

One edge case is orphan foreign-key-like values in the raw CSV data.

For example, some submissions may reference a student or problem that does not exist in the corresponding master table. In `Q06`, an `INNER JOIN` is used because the purpose is to display complete submission details with a valid student name and problem title. This means orphan submissions are excluded from the result.

Another edge case is numeric columns stored as text in the raw SQLite import. For example, `score` is cast before calculating averages:

```sql
AVG(CAST(sub.score AS REAL))
```

Without casting, numeric comparisons or sorting may behave incorrectly in some SQL engines.

## Additional Data-Quality Observations

While validating the queries, the raw dataset showed a few quality issues:

- A submission status value `OK` appears once, while the normal success status is `Accepted`.
- A language value `PseudoCode` appears once, outside the normal programming-language set.
- Some joined queries return fewer rows than the raw table count because of orphan references.
- One score outlier, such as `999`, can make average-score queries look unusually high.

These issues are useful for DBMS reasoning because they show why staging tables, constraints, and validation queries are important before loading data into a strict normalized schema.
