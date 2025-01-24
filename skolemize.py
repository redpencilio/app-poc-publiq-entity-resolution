#!/usr/bin/env python3
import os
from rdflib import Graph, BNode, Dataset, ConjunctiveGraph, Namespace
from rdflib.compare import isomorphic
from rdflib.term import URIRef, rdflib_skolem_genid

def skolemize_ds(path):
    folder, fn = os.path.split(path)
    name, _ = os.path.splitext(fn)

    skolemized_fn = name + "_skolemized.ttl"
    skolemized_path = os.path.join(folder, skolemized_fn)
    g = Graph().parse(path, format="ttl")
    for location, _, _ in g.triples((None, URIRef("http://www.w3.org/1999/02/22-rdf-syntax-ns#type"), URIRef("http://purl.org/dc/terms/Location"))):
        # Assumes max 1 blank node address per (URI-identified) Location
        address = g.value(subject=location, predicate=URIRef("http://www.w3.org/ns/locn#address"))
        if type(address) is BNode:
            skolemized_address = URIRef(location) + "/address"
            for s, p, o in g.triples((address, None, None)):
                g.add((skolemized_address, p, o))
                g.remove((s, p, o))
            for s, p, o in g.triples((None, None, address)):
                g.add((s, p, skolemized_address))
                g.remove((s, p, address))
    g = g.skolemize()


    g.serialize(destination=skolemized_path, format="turtle")


import sys

if __name__ == '__main__':
    in_path = sys.argv[1]
    skolemize_ds(in_path)
