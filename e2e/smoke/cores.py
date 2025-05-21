import multiprocessing
import json


if __name__ == "__main__":
    print(json.dumps({"cores": multiprocessing.cpu_count()}))
