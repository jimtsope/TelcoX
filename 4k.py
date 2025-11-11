import pymysql
from collections import OrderedDict, defaultdict

DB = dict(host="localhost", user="root", password="Vethelor84!", database="Assignment_1", charset="utf8mb4")

def safe_ratio(n, d): return 0.0 if not d else n / d

conn = pymysql.connect(**DB, cursorclass=pymysql.cursors.DictCursor)

city_population = OrderedDict()
city_seconds    = defaultdict(int)
total_pop = 0
total_sec = 0

with conn.cursor() as cur:
    cur.execute("SELECT City_id, Population FROM CITY ORDER BY City_id")
    for row in cur:
        cid = int(row["City_id"]); pop = int(row["Population"])
        city_population[cid] = pop
        total_pop += pop
        city_seconds[cid] += 0

with conn.cursor() as cur:
    cur.execute("""
        SELECT ci.City_id, cl.Duration
        FROM CITY ci
        LEFT JOIN CUSTOMER cu ON cu.City_id = ci.City_id
        LEFT JOIN CONTRACT ct ON ct.Customer_id = cu.Customer_id
        LEFT JOIN CALLS   cl ON cl.Contract_id = ct.Contract_id
                             AND cl.Phone_Datetime >= '2022-01-01'
                             AND cl.Phone_Datetime <  '2023-01-01'
    """)
    for row in cur:
        dur = row["Duration"]
        if dur is not None:
            cid = int(row["City_id"]); d = int(dur)
            city_seconds[cid] += d
            total_sec += d

conn.close()

print(f"{'City_id':>7} | {'Duration_ratio':>15} | {'Population_ratio':>17}")
for cid, pop in city_population.items():
    dur = city_seconds.get(cid, 0)
    print(f"{cid:7d} | {safe_ratio(dur, total_sec):15.6f} | {safe_ratio(pop, total_pop):17.6f}")