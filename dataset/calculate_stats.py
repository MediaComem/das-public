#!/usr/bin/python
# -*- coding: UTF-8 -*-
# calculate stats including citation counts for all articles, and creates author collection
__author__ = """Giovanni Colavizza"""

from collections import defaultdict, OrderedDict
import re, math
import numpy as np
import logging
from scholarmetrics import hindex
logging.basicConfig(filename='logs/stats.log',filemode="w+",level=logging.INFO)
logger = logging.getLogger("Main")

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

# select which collection to use in Mongo, start by dropping if needed (we do not update an existing collection here)
db.drop_collection("stats_dev_2")
db.drop_collection("authors_dev_2")
collection = db.stats_dev_2
collection_authors = db.authors_dev_2
collection_records = db.publications_dev

if __name__ == "__main__":
	# create global publication index and load relevant info in memory
	pmid_dict = defaultdict(int)
	rev_pmid_dict = defaultdict(int)
	pmc_dict = defaultdict(int)
	rev_pmc_dict = defaultdict(str)
	doi_dict = defaultdict(str)
	rev_doi_dict = defaultdict(int)
	publisher_dict = defaultdict(str)
	rev_publisher_dict = defaultdict(int)
	mongo_ids = defaultdict(int)
	citations = dict()
	records = dict()
	authors = defaultdict(str)
	authors_full = defaultdict(str)
	rev_authors_dict = defaultdict(int)
	authors_n_publications = defaultdict(int)
	authors_publications = defaultdict(list)
	authors_citations = dict()
	min_date = 0
	max_date = 0

	# first, populate dictionaries for identifiers
	counter = 0
	author_counter = 0
	for record in collection_records.find():
		mongo_ids[record["_id"]] = counter
		citations[counter] = defaultdict(int)
		# identification
		if record["id_pmc"]:
			pmc_dict[counter] = record["id_pmc"]
			rev_pmc_dict[record["id_pmc"]] = counter
		if record["id_pmid"]:
			pmid_dict[counter] = record["id_pmid"]
			rev_pmid_dict[record["id_pmid"]] = counter
		if record["id_publisher"]:
			publisher_dict[counter] = record["id_publisher"]
			rev_publisher_dict[record["id_publisher"]] = counter
		if record["id_doi"]:
			doi_dict[counter] = record["id_doi"]
			rev_doi_dict[record["id_doi"]] = counter

		year = None
		month = 6 # use June as default value
		has_month = False # keep track if month has default value or not
		if record["publication_date"]:
			r = re.findall(r'\d{4}', record["publication_date"])
			if len(r):
				year = int(r[0])
			r = re.findall(r'\d{2}', record["publication_date"])
			if len(r) > 2:
				month = int(r[2]) # typical date is YYYY-MM-DD
				has_month = True
		date = year * 12 + month
		if date:
			if min_date == 0 or min_date > date:
				min_date = date
			elif max_date < date:
				max_date = date
		paper_authors = list()
		paper_authors_full = list()
		for author in record["authors"]:
			# here we do the simplest thing possible, just exact match
			surface = author["name"].lower().strip() + author["surname"].lower().strip()
			paper_authors_full.append(author["name"] + ", " + author["surname"])
			if surface in authors.keys():
				paper_authors.append(authors[surface])
				authors_n_publications[authors[surface]] += 1
				authors_publications[authors[surface]].append(counter)
			else:
				paper_authors.append(author_counter)
				authors[surface] = author_counter
				rev_authors_dict[author_counter] = surface
				authors_n_publications[author_counter] += 1
				authors_publications[author_counter].append(counter)
				authors_full[author_counter] = author["name"] + ", " + author["surname"]
				author_counter += 1

		records[counter] = {"publication_id":record["_id"],"title":record["title"],"id_pmc":record["id_pmc"],"id_pmid":record["id_pmid"],"id_publisher":record["id_publisher"],"id_doi":record["id_doi"],
		                    "year":year,"month":month,"has_month":has_month,"is_plos":record["is_plos"],"is_bmc":record["is_bmc"],"is_pmc":record["is_pmc"],"has_das":record["has_das"],"authors":paper_authors,"authors_full":paper_authors_full}
		counter += 1
	print("End of record")
	logger.info("Finished creating dictionaries")
	# extract citation histories for indicators
	for record in collection_records.find():
		counter = mongo_ids[record["_id"]]
		for ref in record["references"]:
			if ref["year"] and len(ref["identifiers"]):
				ref_counter = None
				for local_id in ref["identifiers"]:
					if local_id["type"] == "pmid" and int(local_id["id"]) in rev_pmid_dict.keys():
						ref_counter = rev_pmid_dict[int(local_id["id"])]
						break
					elif local_id["type"] == "pmc" and local_id["id"] in rev_pmc_dict.keys():
						ref_counter = rev_pmc_dict[local_id["id"]]
						break
					elif local_id["type"] == "doi" and local_id["id"] in rev_doi_dict.keys():
						ref_counter = rev_doi_dict[local_id["id"]]
						break
					elif local_id["type"] == "publisher-id" and local_id["id"] in rev_publisher_dict.keys():
						ref_counter = rev_publisher_dict[local_id["id"]]
						break
				if not ref_counter:
					continue
				# citation month level base publication date
				citation_year = records[counter]["year"] - records[ref_counter]["year"]
				if records[counter]["month"] < records[ref_counter]["month"]:
					citation_year = citation_year - 1
				if citation_year < 0:
					citation_year = 0  # put as a citation during the first year for citations into the future and the like
				citations[ref_counter][citation_year] += 1
				# add citation to all paper authors
				date_index = records[ref_counter]["year"]*12 + records[ref_counter]["month"] - min_date
				for a in records[ref_counter]["authors"]:
					if not a in authors_citations:
						authors_citations[a] = dict()
					if not ref_counter in authors_citations[a]: 
						authors_citations[a][ref_counter] = dict()
					if not date_index in authors_citations[a][ref_counter]:
						authors_citations[a][ref_counter][date_index] = 0
					# a is the author_counter
					authors_citations[a][ref_counter][date_index] += 1
	print("End of computation citations")
	for k,v in records.items():
		# sort year indexes and convert them into strings for Mongo
		cd = sorted({x: y for x, y in citations[k].items()}.items(), key=lambda x: x[0], reverse=False)
		cdd = OrderedDict()
		
		for kk,vv in cd:
			cdd.update({str(kk):vv})
		v["citation_counts"] = cdd
		v["citations_total"] = sum([x for x in citations[k].values()])
		v["citations_one"] = sum([x for y,x in citations[k].items() if y < 1])
		v["citations_two"] = sum([x for y,x in citations[k].items() if y < 2])
		v["citations_three"] = sum([x for y,x in citations[k].items() if y < 3])
		date_index = v["year"] * 12 + v["month"] - min_date
		h_indexes = list()
		for a in v["authors"]:
			h_index = 0
			local_cit_counts = dict()
			if a in authors_citations:
				for index, value in authors_citations[a].items():
					for date, count in value.items():
						if date < date_index:
							if not index in local_cit_counts:
								local_cit_counts[index] = count
							else:
								local_cit_counts[index] += count
				arrayOfCitation = list(local_cit_counts.values())
				arrayOfCitation = sorted(arrayOfCitation, reverse=True)
				h_index = hindex(arrayOfCitation)
			else:
				authors_citations[a] = dict()

			h_indexes.append(int(h_index))
		v["h_indexes"] = h_indexes

	logger.info("Finished parsing all records")
	print("End of parsing")

	# export authors and their h-indexes
	authors_dump = list()
	for k,v in authors_full.items():
		A = authors_citations[k]
		total_cit_cout = 0
		h_index = 0
		publication_cit_count = list(A)
		local_cit_counts = dict()
		for index, publication in A.items():
			local_cit_counts[index] = 0
			for date, count in publication.items():
				total_cit_cout += count
				if index in local_cit_counts:
					local_cit_counts[index] += count
			arrayOfCitation = list(local_cit_counts.values())
			arrayOfCitation = sorted(arrayOfCitation, reverse=True)
			h_index = hindex(arrayOfCitation)
		a = {"index":k,"name":v,"tot_cit":total_cit_cout}
		a_citations = list()
		for y in authors_publications[k]:
			cit = 0
			if y in local_cit_counts:
				cit = local_cit_counts[y]
			a_citations.append({"title":records[y]["title"],"year":records[y]["year"],"publication_id":records[y]["publication_id"],"paper_id":y,"n_cit": cit})
		a["h_index"] = int(h_index)
		a["publications"] = a_citations
		authors_dump.append(a)
	print("End of authors")
	# dump all
	collection.insert_many([r for r in records.values()])
	collection_authors.insert_many(authors_dump)
	# add indexes
	collection.create_index([('id_doi', HASHED)], background=True)
	collection.create_index([('id_pmc', ASCENDING)],
	                        background=True)
	collection.create_index([('id_pmid', ASCENDING)],
	                        background=True)
	collection.create_index([('id_publisher', HASHED)],
	                        background=True)
	collection_authors.create_index([('name', HASHED)],
	                        background=True)
	collection_authors.create_index([('tot_cit', ASCENDING)],
	                        background=True)
	collection_authors.create_index([('index', ASCENDING)],
	                        background=True)

	logger.info("Finished!")
	print("\nFinished!")
