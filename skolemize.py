#!/usr/bin/env python3
import os
from rdflib import Graph, BNode, Dataset, ConjunctiveGraph
from rdflib.compare import isomorphic
from rdflib.term import URIRef, rdflib_skolem_genid

def skolemize_ds(path):
    folder, fn = os.path.split(path)
    name, _ = os.path.splitext(fn)

    skolemized_fn = name + "_skolemized.ttl"
    skolemized_path = os.path.join(folder, skolemized_fn)
    g = Graph().parse(path, format="ttl").skolemize()
    g.serialize(destination=skolemized_path, format="turtle")


import sys

if __name__ == '__main__':
    in_path = sys.argv[1]
    skolemize_ds(in_path)
