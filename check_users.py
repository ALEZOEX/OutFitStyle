import subprocess
result = subprocess.run(
    ["docker", "exec", "outfitstyle_postgres_1", "psql", "-U", "postgres", "-d", "outfitstyle", "-c", "SELECT id, email FROM users LIMIT 5;"],
    capture_output=True,
    text=True
)
print(result.stdout)
if result.stderr:
    print("STDERR:", result.stderr)
