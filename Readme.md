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

Transform provided nquad dumps into turtle and place them into the `config/virtuoso/toLoad` folder.
```sh
rapper -i nquads -o turtle -q be.acagroup.ticketing.ticketgang-locations.locatieslinkeddata_2024-10-04_13-16-18.nq > be.acagroup.ticketing.ticketgang-locations.locatieslinkeddata_2024-10-04_13-16-18.ttl
rapper -i nquads -o turtle -q be.kunsten.professionelekunsten.kunstenpunt-locaties.locatiessparql_2024-10-04_13-16-57.nq > be.kunsten.professionelekunsten.kunstenpunt-locaties.locatiessparql_2024-10-04_13-16-57.ttl
rapper -i nquads -o turtle -q be.publiq.vrijetijdsparticipatie.cultuurparticipatie-metadata.metadata_2024-10-04_13-17-16.nq > be.publiq.vrijetijdsparticipatie.cultuurparticipatie-metadata.metadata_2024-10-04_13-17-16.ttl
rapper -i nquads -o turtle -q be.publiq.vrijetijdsparticipatie.publiq-uit-locaties.placessparql_2024-10-04_13-17-08.nq > be.publiq.vrijetijdsparticipatie.publiq-uit-locaties.placessparql_2024-10-04_13-17-08.ttl
rapper -i nquads -o turtle -q be.publiq.vrijetijdsparticipatie.publiq-uit-organisatoren.organisatorensparql_2024-10-04_13-17-23.nq > be.publiq.vrijetijdsparticipatie.publiq-uit-organisatoren.organisatorensparql_2024-10-04_13-17-23.
```

Add a `.graph`-file for each turtle-file
```sh
echo "http://locatieslinkeddata.ticketgang-locations.ticketing.acagroup.be" > be.acagroup.ticketing.ticketgang-locations.locatieslinkeddata_2024-10-04_13-16-18.ttl.graph
echo "http://placessparql.publiq-uit-locaties.vrijetijdsparticipatie.publiq.be" > be.publiq.vrijetijdsparticipatie.publiq-uit-locaties.placessparql_2024-10-04_13-17-08.ttl.graph
echo "http://locatiessparql.kunstenpunt-locaties.professionelekunsten.kunsten.be" > be.kunsten.professionelekunsten.kunstenpunt-locaties.locatiessparql_2024-10-04_13-16-57.ttl.graph
echo "http://organisatorensparql.publiq-uit-organisatoren.vrijetijdsparticipatie.publiq.be" > be.publiq.vrijetijdsparticipatie.publiq-uit-organisatoren.organisatorensparql_2024-10-04_13-17-23.ttl.graph
echo "http://metadata.cultuurparticipatie-metadata.vrijetijdsparticipatie.publiq.be" > be.publiq.vrijetijdsparticipatie.cultuurparticipatie-metadata.metadata_2024-10-04_13-17-16.ttl.graph
```
