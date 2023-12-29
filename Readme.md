## rtr subventionen

### what is this?

the austrian [Rundfunk und Telekom Regulierungs-GmbH](https://www.rtr.at/) provides a lot of open data. nice!

but who wants to deal with json or csv? i wrote a little importer in ruby that takes json data as provided by the rtr and builds the corresponding sql statements to put this into a database. that way, we can run some `GROUP BY` queries and add up some numbers! 

the thing that sparked my interest initially, which is also downloaded as demo in this repository, is the [Förderung Digitale Transformation](https://www.rtr.at/medien/was_wir_tun/foerderungen/digitaletransformation/entscheidungen/startseite.de.html).

### how to use

please wear a helmet,  **no SQL sanitization is applied, only run this against trusted data!**

#### run it yourself

in general, this should work for any json returned by RTR, but it's more a proof of concept than anything else.

0. clone the repository
1. install the right ruby version. please look up how to do this yourself :)
2. `bundle install`
3. put your json into the `data/` folder
4. adapt `main.rb` to your new file and table name.
5. run `bundle exec rake run` – this should now create two files in the out folder: one to create the table, and one to insert all the data.
6. if you have no entry in your json without `NULL` values, add a dummy entry so the script can derive the correct data types.
7. please note, again that – **no SQL sanitization is applied, only run this against trusted data!**

#### i just want to query the data!

this is all made for `sqlite3``. do the following

0. clone the repository
1. hopefully, your OS includes `sqlite3`
2. create a new database and pass in the create-table script: `sqlite3 test.db < 2023-12-29-create-table.sql`
3. feed in the data: `sqlite3 test.db < 2023-12-29-insert-into.sql`

### legal and stuff

everything in here is BSD licensed. the actual data received from RTR is »Freie Werke gemäß § 7 Urheberrechtsgesetz«, according to the metadata at: [Förderung Digitale Transformation](https://www.rtr.at/medien/was_wir_tun/foerderungen/digitaletransformation/entscheidungen/startseite.de.html).