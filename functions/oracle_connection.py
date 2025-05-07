import oracledb

def get_oracle_connection(
    user="SYSTEM",
    password="oraclee",
    host="localhost",
    port=1521,
    service_name="XE"
):
    """
    Creates and returns an Oracle DB connection using the oracledb package.
    """
    dsn = f"{host}:{port}/{service_name}"
    conn = oracledb.connect(user=user, password=password, dsn=dsn)
    return conn
