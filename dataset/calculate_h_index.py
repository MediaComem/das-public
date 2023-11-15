# MongoDB
from pymongo import MongoClient
from pymongo import HASHED, ASCENDING
from configparser import ConfigParser
config_set = "localhost" # this is in localhost
config = ConfigParser(allow_no_value=False)
config.read("config/config.conf")
mongo_db = config.get(config_set, 'db-name')
mongo_user = config.get(config_set, 'username')
mongo_pwd = config.get(config_set, 'password')
mongo_auth = config.get(config_set, 'auth-db')
mongo_host = config.get(config_set, 'db-host')
mongo_port = config.get(config_set, 'db-port')
client = MongoClient(mongo_host, 
                     username=mongo_user,
                     password=mongo_pwd,)
db = client[mongo_db]

collection = db.stats_dev
collection_authors = db.authors_dev
collection_stats = db.stats_with_hindex


records = list()
for record in collection.find():
	h_indexes = list()
	for a in record["authors"]:		
		author_h_index = collection_authors.find_one({"index": a})['h_index']
		h_indexes.append(author_h_index)
	record['h-indexes'] = h_indexes
	records.append(record)
print("End of h-indexes")

collection_stats.insert_many(records)

collection_stats.create_index([('id_doi', HASHED)], background=True)
collection_stats.create_index([('id_pmc', ASCENDING)],
	                        background=True)
collection_stats.create_index([('id_pmid', ASCENDING)],
	                        background=True)
collection_stats.create_index([('id_publisher', HASHED)],
	                        background=True)

print("\nFinished!")
