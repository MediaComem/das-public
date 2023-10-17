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