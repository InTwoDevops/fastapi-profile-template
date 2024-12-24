# app/main.py
from fastapi import FastAPI, StaticFiles
import sys
import os
import math
from concurrent.futures import ThreadPoolExecutor
from fastapi.responses import HTMLResponse

app = FastAPI(
    docs_url="/docs",  # Swagger UI path
    redoc_url="/redoc",  # ReDoc path
    openapi_url="/openapi.json",  # OpenAPI schema path
)
# Global list that grows with each request
memory_hog = []


# Function to get total size of an object including its contents
def get_total_size(obj, seen=None):
    if seen is None:
        seen = set()

    obj_id = id(obj)
    if obj_id in seen:
        return 0  # Avoid circular references
    seen.add(obj_id)

    size = sys.getsizeof(obj)  # Start with the size of the object itself

    # If it's a container, sum the sizes of its elements
    if isinstance(obj, dict):
        size += sum(get_total_size(v, seen) for v in obj.values())
        size += sum(get_total_size(k, seen) for k in obj.keys())
    elif isinstance(obj, (list, tuple, set, frozenset)):
        size += sum(get_total_size(i, seen) for i in obj)

    return size


@app.get("/memory-leak")
async def memory_leak():
    global memory_hog

    # Append 1GB of memory (using a byte array)
    memory_hog.append(bytearray(2**30))  # Appending 1GB of byte data

    # Calculate total memory allocated in bytes
    total_size_in_bytes = get_total_size(memory_hog)

    # Convert to GB
    memory_allocated_gb = total_size_in_bytes / (1024**3)

    return {
        "status": "memory increased",
        "current_size": len(memory_hog),
        "memory_allocated_gb": memory_allocated_gb,
    }


def is_prime(n):
    if n < 2:
        return False
    for i in range(2, int(math.sqrt(n)) + 1):
        if n % i == 0:
            return False
    return True


@app.get("/high-cpu-usage")
async def high_cpu_usage(limit: int = 100000):
    primes = []
    for num in range(2, limit):
        if is_prime(num):
            primes.append(num)

    return {"status": "success", "calculated_primes": len(primes), "limit": limit}


def calculate_primes(start, end):
    primes = []
    for num in range(start, end):
        if is_prime(num):
            primes.append(num)
    return primes


PYINSTRUMENT_PROFILING = os.getenv("PYINSTRUMENT_PROFILING", "False")
if PYINSTRUMENT_PROFILING == "True":
    print("Entering pyinstrument middleware configuration")
    from pyinstrument import Profiler
    from fastapi import Request
    from fastapi.responses import HTMLResponse

    @app.middleware("http")
    async def profile_request(request: Request, call_next):
        profiling = request.query_params.get("profile", False)
        if profiling:
            profiler = Profiler(interval=0.01, async_mode="enabled")
            profiler.start()
            await call_next(request)
            profiler.stop()
            return HTMLResponse(profiler.output_html())
        else:
            return await call_next(request)

app.mount("/static", StaticFiles(directory="app/static"), name="static")

@app.get("/")
async def read_index():
    return HTMLResponse(open("app/static/index.html").read())
