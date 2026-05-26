# question-2----IIT-mandi-assignment
This repository contains the Part 2 SQL solution for the CodeJudge DBMS assignment.

The goal of this part is to write practical SQL queries on top of the imported CodeJudge database and validate that the outputs are logically correct using the actual dataset.

## Repository Files

```text
codejudge-part2/
├── README.md
├── queries.sql
├── query_outputs.md
└── sql_reasoning.md
```

## Files Explained

| File | Purpose |
|---|---|
| `README.md` | Explains how to use the repository and run the solution. |
| `queries.sql` | Contains all 20 required SQL queries with comments. |
| `query_outputs.md` | Contains sample outputs/result summaries and validation notes for every query. |
| `sql_reasoning.md` | Answers the explanation questions about joins, HAVING, subqueries, duplicates, and edge cases. |

## Database Assumption

The queries are written for the raw SQLite-style database created from the original CSV files.

The supplied dataset includes a helper loader named `load_sqlite_raw.py`. That loader imports every CSV into a table with the same name as the CSV file, for example:

- `students.csv` becomes `students`
- `submissions.csv` becomes `submissions`
- `problems.csv` becomes `problems`
- `test_results.csv` becomes `test_results`

The raw import keeps all columns flexible because the dataset intentionally contains some inconsistent records. This is useful for query testing and data-quality validation.

## How to Run

Place the CSV files in the expected `data/` folder and run the raw loader:

```bash
python load_sqlite_raw.py
```

Then run the SQL queries against the generated SQLite database:

```bash
sqlite3 codejudge_raw.db < queries.sql
```

You can also copy individual queries from `queries.sql` and run them one by one in DB Browser for SQLite, DBeaver, or the SQLite CLI.

## Query Coverage

The solution covers:

1. Basic retrieval and filtering
2. Joins
3. Aggregation and HAVING
4. Subqueries and set logic
5. Output validation using real dataset results
6. SQL reasoning and edge-case discussion

## Notes

- `Accepted` is treated as the successful submission status.
- `status <> 'Accepted'` is used to identify unsuccessful submissions.
- Numeric values such as `score`, `runtime_ms`, and `case_no` are cast when needed because the raw SQLite loader imports CSV columns as text.
- Some query outputs reveal intentional raw-data issues, such as orphan IDs and inconsistent status labels.
