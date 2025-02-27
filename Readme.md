# Entity Resolution App

A proof of concept for Publiq to identify and resolve identical or related entities in their RDF-datasets. Focus on Addresses and Locations.
The main software-stack is built upon semantic.works, a micro-service-based, linked-data-first architecture (previously known as mu.semte.ch). This repository contains the necessary configuration for each service that the stack is composed of. Please refer to the documentation of mu-project for more information on how to run and configure a semantic.works-based project.
Includes a custom [entity-mapping-service](https://github.com/redpencilio/publiq-entity-mapping-service) and a frontend for manual verification of the produced mappings.
Heavily relies upon the [sssom standard](https://mapping-commons.github.io/sssom/) for representing the mapping metadata.

## First startup

We recommend creating an `.env` file and the corresponding files it refers to.
The following commands should be run the first time you start the app.
```
echo "COMPOSE_FILE=docker-compose.yml:docker-compose.dev.yml:docker-compose.override.yml" > .env
touch docker-compose.override.yml
```

### Running on linux/arm64 platform

Running on the newest Mac's with an ARM architecture is possible, but requires some additional configuration. Some of the used Docker images are compiled for `linux/arm64` specifically, others aren't and require emulation at runtime. Emulation through Apple's [Rosetta](https://support.apple.com/en-us/102527) must be enabled in your Docker settings. [This Docker blog article](https://www.docker.com/blog/docker-desktop-4-25/) explains how to do that. Once enabled, the `platform: linux/amd64` flag in the `docker-compose.yml`-file will tell you system to run that image with emulation through Rosetta.

### Preprocessing data

Convert nquads (with 1 graph per entity) to ttl.
*This step makes use of the `rapper` cli-tool, which is part of the [Raptor toolkit](https://librdf.org/raptor/rapper.html). This tool is available in most of the common Linux distro packages registries. Installation [through Homebrew](https://formulae.brew.sh/formula/raptor) seems available, but hasn't been tested.*
```sh
for file in data/source-dumps/20241004/*.nq; do
    if [ -f "$file" ]; then
        rapper  -i nquads -o turtle -q "$file" > "$(dirname "$file")/$(basename "$file" .nq).ttl"
    fi
done
mkdir -p data/ttl-converted/20241004
mv data/source-dumps/20241004/*.ttl data/ttl-converted/20241004
```

Skolemize blank nodes.
*The script used in this step requires a local Python 3.x installation with the rdflib package installed*
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

### Loading data

Copy skolemized data to database load folder
```sh
cp data/skolemized/20241004/*.ttl config/virtuoso/toLoad
```
*Make sure to add a .graph file in the toLoad folder, so the triples get loaded into the expected graph. See https://docs.openlinksw.com/virtuoso/rdfperfloading/#rdfperfloadingutility for more information about the .graph extension*

Make sure that all data that will be displayed through the frontend disposes of a `mu:uuid`. This is required for the mu-cl-resource jsonapi inner workings.

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

### Running the mapping process

Run automated Address mapping
```
curl http://localhost:8888/map-addresses
```

Run automated Location mapping
```
curl http://localhost:8888/map-locations-by-address
```

### Verifying and exporting mapping data

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

### Incremental mapping runs

Once some verified data is available, new Address- & Location-data can be loaded in order to perform a new mapping run, but incrementally this time, only mapping the newly provided data, but taking into account previously verified mappings.  

Load some new (skolemized) data by replacing the contents of the `config/virtuoso/toLoad`-folder with some new to-be-loaded datasets. Keep the previous instructions wrt the `.graph`-files for configuring the destination-graph in mind.
Also, make sure to remove the `data/db/.data_loaded` folder, so the new data file gets picked up on restart.  

Once the new data is loaded, instructions for a new mapping round will be similar to those above, but including a `from` date that will serve as a filter to distinguish the new data from the existing.


#### Run automated Address mapping

The optional `from`-parameter determines which addresses will be considered for mapping based on their (or rather their Location's) `dct:modified` date. All addresses with a modification date more recent than `from` will be used to create new mappings for. This is mainly useful for incremental runs. Even when another full DB-dump is loaded, this parameter makes it possible to focus only on the recently modified data within. 
```
curl http://localhost:8888/map-addresses?from=2025-02-05T00:00:00
```

#### Run automated Location mapping

```
curl http://localhost:8888/map-locations-by-address?from=2025-02-05T00:00:00
```
