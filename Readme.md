# Entity Resolution App

For Publiq.

## First startup

We recommend creating an `.env` file and the corresponding files it refers to.
The following commands should be run the first time you start the app.
```
echo "COMPOSE_FILE=docker-compose.yml:docker-compose.dev.yml:docker-compose.override.yml" > .env
touch docker-compose.override.yml
```

## Loading data

Convert nquads (with 1 graph per entity) to ttl
```sh
for file in data/source-dumps/20241004/*.nq; do
    if [ -f "$file" ]; then
        rapper  -i nquads -o turtle -q "$file" > "$(dirname "$file")/$(basename "$file" .nq).ttl"
    fi
done
mkdir -p data/ttl-converted/20241004
mv data/source-dumps/20241004/*.ttl data/ttl-converted/20241004
```

Skolemize blank nodes
```sh
chmod +x skolemize.py
for file in data/ttl-converted/20241004/*.ttl; do
    if [ -f "$file" ]; then
        echo "skolemizing $file"
        ./skolemize.py "$file"
    fi
done
mkdir -p data/skolemized/20241004
mv data/ttl-converted/20241004/*_skolemized.ttl data/skolemized/20241004
```

Copy skolemized data to database load folder
```sh
cp data/skolemized/20241004/*.ttl config/virtuoso/toLoad
```
*Make sure to add a .graph file in the toLoad folder, so the triples get loaded into the expected graph. See https://docs.openlinksw.com/virtuoso/rdfperfloading/#rdfperfloadingutility for more information about the .graph extension*

Make sure that all data that will be displayed through the frontend disposes of a `mu:uuid`. This is required for the inner working of the mu-cl-resource jsonapi inner workings.

```sparql
PREFIX mu:      <http://mu.semte.ch/vocabularies/core/>

INSERT {
    GRAPH ?g {
        ?s mu:uuid ?uuid .
    }
} WHERE {
    GRAPH ?g {
        ?s a ?type .
        FILTER NOT EXISTS { ?s mu:uuid ?id }
        BIND(STRUUID() as ?uuid)
    }
    VALUES ?g {
        <http://locatieslinkeddata.ticketgang-locations.ticketing.acagroup.be>
        <http://locatiessparql.kunstenpunt-locaties.professionelekunsten.kunsten.be>
        <http://placessparql.publiq-uit-locaties.vrijetijdsparticipatie.publiq.be>
        <http://organisatorensparql.publiq-uit-organisatoren.vrijetijdsparticipatie.publiq.be>
    }
}
```

Run automated Address mapping
```
curl http://localhost:8888/map-addresses
```

Run automated Location mapping
```
curl http://localhost:8888/map-locations-by-address
```

Manually verify Location mappings through the frontend.  
Produced mappings can be dumped by running following `CONSTRUCT`-query on the SPARQL-endpoint at `http://localhost:8890/sparql`. Make sure to select the desired output-format (beautified Turtle)
*The SPARQL-endpoint is exposed to port 8890 in de docker-compose.dev.yml file*
```sparql
CONSTRUCT {
    ?s ?p ?o .
}
WHERE {
    GRAPH <http://mu.semte.ch/graphs/entity-manual-mappings> {
        ?s ?p ?o . 
    }
}
```

Once some verified data is available, new Address- & Location-data can be loaded in order to perform a new mapping run, but incrementally this time, only mapping the newly provided data, but taking into account previously verified mappings.  

Load some new (skolemized) data by replacing the contents of the `config/virtuoso/toLoad`-folder with some new to-be-loaded datasets. Keep the previous instructions wrt the `.graph`-files for configuring the destination-graph in mind.
Also, make sure to remove the `data/db/.data_loaded` folder, so the new data file gets picked up on restart.  

Once the new data is loaded, instructions for a new mapping round will be similar to those above, but including a `from` date that will serve as a filter to distinguish the new data from the existing.


Run automated Address mapping
```
curl http://localhost:8888/map-addresses?from=2025-02-05T00:00:00
```

Run automated Location mapping
```
curl http://localhost:8888/map-locations-by-address?from=2025-02-05T00:00:00
```
