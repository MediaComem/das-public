## Design of the test dataset for citation validation

The dataset was built in several stages. If you want to produce the best possible dataset for testing all the functions, you'll need to go through the entire creation process.

1. For each file of the three publication types (commercial, non-commercial and others). Randomly select around ten files per PMC00xxxxx folder.
2. Randomly choose a `doi` from the file `config/PLOS-Dataset-Oct8_2023.csv`.
3. Check the article containing this doi and the citations in the data coming from `PLOS` and insert the new files in the test dataset. Count the number of files (you need to move at least 3, the article and two citation articles). There will be n-1 citations.
4. Run the `parser_main.py` and `calculate.py` scripts. Once the scripts are finished, in a terminal, run the following commands:
   1.  mongosh --host localhost -u user -p pass
   2.  use contexts
   3.  db.stats_dev.find( { is_plos: true } )
5. There should only be one entry (the one you added). However, as you have taken data at random, there may be more entries. You will then need to check that they are in the `config/PLOS-Dataset-Oct8_2023.csv` file.
6. Randomly select a `doi` from the file `config/PMC-Dataset-Oct8_2023.csv`.
7. Check the article containing this doi and the citations in the data coming from `PLOS` and insert the new files in the test dataset. Count the number of files (you need to move at least 3, the article and two citation articles). There will be n-1 citations.
8. Run the `parser_main.py` and `calculate.py` scripts. Once the scripts are finished, in a terminal, run the following commands:
   1.  mongosh --host localhost -u user -p pass
   2.  use contexts
   3.  db.stats_dev.find( { is_bmc: true } )
9. There should only be one entry (the one you added). However, as you have taken data at random, there may be more entries. You will then need to check that they are in the `config/PMC-Dataset-Oct8_2023.csv` file.
10. At this stage, you can check that the quotes are working correctly. To do this, in a terminal, run the following commands:
    1.  mongosh --host localhost -u user -p pass
    2.  use contexts
    3.  db.stats_dev.find( { citations_total: { $gt: 0 }, is_plos: true } )
    4.  db.stats_dev.find( { citations_total: { $gt: 0 }, is_bmc: true } )

There should be as many entries as during tests 4.3 and 8.3. In addition, the citations_total field should be equal to the number of files moved minus 1 during steps 3 and 7.
However, checking by date is a little more complex. First, you need to ensure that the numbers in the `citations_one`, `citations_two` and `citations_three` fields are correct with the `citation_counts` field. This is because `citations_one` contains the same number as the '0' entry in `citation_counts`. `citations_two` must be the sum of '0' and '1' and finally `citations_three`, the sum of '0', '1' and '2'.
Validating `citation_counts` is a little more tedious. You will need to find the publication date of your article to the nearest month and then validate with the publication dates of the articles citing yours.

## Design of the test dataset for h_index validation

Before we can carry out this step, we need to have created a dataset by following the procedure described above.
Once this has been done, we can start validating the h_index. As things stand, the h_index should be 1 for the tables returned by the commands `db.stats_dev.find( { citations_total: { $gt: 0 }, is_plos: true } )` and `db.stats_dev.find( { citations_total: { $gt: 0 }, is_bmc: true } )`. If you have h_indexes of two, this may be normal, you will then need to check in the user table whether those who published this article published other articles that could be in the dataset you randomly created. However, this is not necessary. You can focus on a user with an h_index of 1 in the table to test this part. The procedure for testing the h_index is as follows:
1. In the result of `db.stats_dev.find( { citations_total: { $gt: 0 }, is_plos: true } )`, take the name of the desired user and search for it in the global dataset.
2. Add the article with at least two citations to your test dataset.
3. Run the following commands in a terminal:
   1. mongosh --host localhost -u user -p pass
   2. use contexts
   3. db.authors_dev.find( { name: 'YourAuthor'  } )
   4. You should have an h_index of 2
4. Now take the result of `db.stats_dev.find( { citations_total: { $gt: 0 }, is_bmc: true } )`.
5. Choose one of the authors of the article and search for it in the global dataset.
6. Add the article and only one of the articles citing it to your test dataset
7. Run the following commands in a terminal:
   1. mongosh --host localhost -u user -p pass
   2. use contexts
   3. db.authors_dev.find( { name: 'VotreAuteur'  } )
   4. You should have an h_index of 1
8. Now if you go back to the results of `db.stats_dev.find( { citations_total: { $gt: 0 }, is_plos: true } )` and `db.stats_dev.find( { citations_total: { $gt: 0 }, is_bmc: true } )`. In the first case, you should have your chosen authors with an h_index of 2 and in the second, always 1.

## Results

### with h_index of 2

```
db.stats_dev.find( { citations_total: { $gt: 0 }, is_plos: true } )
  [{
    _id: ObjectId("652e2d39dc70384f40b13e95"),
    publication_id: ObjectId("652e2b53dc70384db46bbbec"),
    title: 'Cystatin C: A Candidate Biomarker for Amyotrophic Lateral Sclerosis',
    id_pmc: 'PMC3000338',
    id_pmid: 21151566,
    id_publisher: 'PONE-D-10-00811',
    id_doi: '10.1371/journal.pone.0015133',
    year: 2010,
    month: 7,
    has_month: true,
    is_plos: true,
    is_bmc: false,
    has_das: false,
    authors: [ 1998, 1999, 2000, 1595 ],
    authors_full: [
      'Meghan E., Wilson',
      'Imene, Boumaza',
      'David, Lacomis',
      'Robert, Bowser'
    ],
    citation_counts: { '7': 2 },
    citations_total: 2,
    citations_one: 0,
    citations_two: 0,
    citations_three: 0,
    h_indexes: [ 1, 1, 1, 2 ]
  }]

db.authors_dev.find( { name: 'Robert, Bowser'  } )
[
  {
    _id: ObjectId("652e2d39dc70384f40b144fa"),
    index: 1595,
    name: 'Robert, Bowser',
    tot_cit: 5,
    h_index: 2,
    publications: [
      {
        title: 'Mutations in the Matrin 3 gene cause familial amyotrophic lateral sclerosis',
        year: 2014,
        publication_id: ObjectId("652e2b53dc70384db46bbbab"),
        paper_id: 283,
        n_cit: 3
      },
      {
        title: 'Cystatin C: A Candidate Biomarker for Amyotrophic Lateral Sclerosis',
        year: 2010,
        publication_id: ObjectId("652e2b53dc70384db46bbbec"),
        paper_id: 348,
        n_cit: 2
      }
    ]
  }
]
```

### with h_index of 1

```
contexts> db.stats_dev.find( { citations_total: { $gt: 0 }, is_bmc: true } )
[
  {
    _id: ObjectId("652e2d39dc70384f40b13d96"),
    publication_id: ObjectId("652e2b53dc70384db46bbaed"),
    title: 'Conditions for laryngeal mask airway placement in terms of oropharyngeal leak pressure: a comparison between blind insertion and laryngoscope-guided insertion',
    id_pmc: 'PMC6320569',
    id_pmid: 30611202,
    id_publisher: '674',
    id_doi: '10.1186/s12871-018-0674-6',
    year: 2019,
    month: 1,
    has_month: true,
    is_plos: false,
    is_bmc: true,
    has_das: true,
    authors: [ 478, 479, 480, 481, 482, 483 ],
    authors_full: [
      'Go Wun, Kim',
      'Jong Yeop, Kim',
      'Soo Jin, Kim',
      'Yeo Rae, Moon',
      'Eun Jeong, Park',
      'Sung Yong, Park'
    ],
    citation_counts: { '0': 1, '2': 1, '4': 1 },
    citations_total: 3,
    citations_one: 1,
    citations_two: 1,
    citations_three: 2,
    h_indexes: [ 1, 1, 1, 1, 1, 1 ]
  }
]

db.authors_dev.find( { name: 'Jong Yeop, Kim'  } )
[
  {
    _id: ObjectId("652e2d39dc70384f40b1409e"),
    index: 479,
    name: 'Jong Yeop, Kim',
    tot_cit: 3,
    h_index: 1,
    publications: [
      {
        title: 'Conditions for laryngeal mask airway placement in terms of oropharyngeal leak pressure: a comparison between blind insertion and laryngoscope-guided insertion',
        year: 2019,
        publication_id: ObjectId("652e2b53dc70384db46bbaed"),
        paper_id: 93,
        n_cit: 3
      },
      {
        title: 'Predicted EC50 and EC95 of Remifentanil for Smooth Removal of a Laryngeal Mask Airway Under Propofol Anesthesia',
        year: 2015,
        publication_id: ObjectId("652e2b53dc70384db46bbb78"),
        paper_id: 232,
        n_cit: 0
      }
    ]
  }
]
```


## Validation de l'export des données

To validate this step, you will need to have completed the previous two. This step is quite simple, you will need to run the `get_export.py` script. The `exports/export.csv` file should contain a number of lines equal to the result of the two queries `db.stats_dev.find( { citations_total: { $gt: 0 }, is_plos: true } )` and `db.stats_dev.find( { citations_total: { $gt: 0 }, is_bmc: true } )`. The content should be the columns in the file `config/PLOS-Dataset-Oct8_2023.csv` or `config/PMC-Dataset-Oct8_2023.csv` to which the following columns have been added:

* id_pmid
* id_pmc
* id_doi
* id_publisher
* journal
* n_authors
* is_plos
* is_bmc
* n_references
* references
* year
* month
* has_month
* citations_one
* citations_two
* citations_three
* citations_total
* h_indexes
* h_index_min
* h_index_max
* h_index_mean
* h_index_median