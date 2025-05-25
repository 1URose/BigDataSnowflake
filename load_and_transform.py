import os
import glob
import psycopg2

DB_PARAMS = {
    "host":     os.getenv("DB_HOST", "localhost"),
    "port":     os.getenv("DB_PORT", "25432"),
    "dbname":   os.getenv("DB_NAME", "user_db"),
    "user":     os.getenv("DB_USER", "user"),
    "password": os.getenv("DB_PASSWORD", "password"),
}

conn = psycopg2.connect(**DB_PARAMS)
cur = conn.cursor()

CSV_DIR = os.getenv("CSV_DIR", ".")
WORK_DIR = os.getenv("WORK_DIR", ".")

def load_file_contents(path):
    for enc in ("utf-8-sig", "utf-8", "cp1251", "latin-1"):
        try:
            with open(path, "r", encoding=enc) as f:
                return f.read()
        except UnicodeDecodeError:
            continue
    raise UnicodeDecodeError(f"Не удалось прочитать файл {path} в поддерживаемой кодировке")

def init_db():
    ddl_path = os.path.join(WORK_DIR, "ddl.sql")
    ddl_sql = load_file_contents(ddl_path)
    cur.execute(ddl_sql)
    conn.commit()
    print("DDL выполнен")

def load_data():
    pattern = os.path.join(CSV_DIR, "./исходные данные/MOCK_DATA*.csv")
    files = sorted(glob.glob(pattern))
    for path in files:
        print(f"Загрузка {path}")
        with open(path, "r", encoding="utf-8") as f:
            cur.copy_expert("COPY mock_data FROM STDIN WITH CSV HEADER", f)
    conn.commit()
    print("CSV загружены в mock_data")

def dml():
    with open("dml.sql", "r") as f:
        dml_sql = f.read()
    cur.execute(dml_sql)
    conn.commit()
    print("DML выполнен")

    cur.close()
    conn.close()

if __name__ == "__main__":
    init_db()
    load_data()
    dml()

