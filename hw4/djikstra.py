#V, E, s, g
from Queue import PriorityQueue

def dijkstra(V, E, s, g):   

    #init
    d = {} #dist from path to vertex
    pi = {} #predecessors graph

    for v in V:
        d[v] = float("inf")
        pi[v] = []
    
    d[s] = 0.0

    S = [] #set of vertices whose shortest path from source already det

    while V:
        u = min(d, key=d.get)  #vertex w. shortest distance
        S.append(u) #add u to finished set

        poss_edges = [e for e in E if e[0] == u]
        neighbors = [n[1] for n in poss_edges]

        for v in neighbors:
            if d[v] > d[u] + cost(u, v):
                d[v] = d[u] + cost(u, v)
                pi[v] = u


        #del d[u]
        V.remove(u) 

    return d, pi

