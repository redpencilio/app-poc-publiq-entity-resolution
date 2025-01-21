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

