import numpy as np
import matplotlib.pyplot as plt
import csv
from collections import defaultdict

def string_to_bool(s):
    if s == '1':
        return True
    else:
        return False

def string_to_fixed(s, width=16, fraction=8):
    uns = int(s, 16)
    sign = bool(uns & (1 << (width-1)))
    if sign:
        return float(uns - 2**width) / 2.0**fraction
    else:
        return float(uns) / 2.0**fraction

def read_trace(filename, mem_width=16, mem_fraction=10):
    states = []
    fires = []
    membranes = []

    with open(filename, 'r') as f:
        reader = csv.reader(f, delimiter=' ')
        for row in reader:
            states.append([])
            membranes.append([])
            fires.append([])
            for i,cell in enumerate(row):
                if not cell == '':
                    if i % 3 == 0:
                        states[-1].append(string_to_bool(cell))
                    elif i % 3 == 1:
                        fires[-1].append(string_to_bool(cell))
                    else:
                        membranes[-1].append(string_to_fixed(cell,
                                                             mem_width,
                                                             mem_fraction))

    return states, fires, membranes


def count_states(states):
    rv = []
    if states:
        ar = np.array(states)
        for i in range(len(states[0])):
            rv.append(float(np.count_nonzero(ar[:,i])) / float(ar[:,i].size))
    return rv


#def count_joint_states(states):
    #if states:
        #K = 2**len(states[0])
        #rv = [ 0 for i in xrange(K) ]
        #for row in states:
            #num = 0
            #for i,c in enumerate(row):
                #if c: num |= (1 << (K-i-1));

            #rv[num] += 1

        #return rv
    #else:
        #return []


def activation_function(neuron_i, states, fires, membranes):
    in_state_0 = 0
    hist = defaultdict(int)
    no_fire = defaultdict(int)

    for i in xrange(0,len(membranes)):
        m = membranes[i][neuron_i]
        if fires[i][neuron_i]:
            hist[m] += 1

        if not states[i][neuron_i]:
            no_fire[m] += 1

    rv = defaultdict(float)
    for k in set(hist.keys() + no_fire.keys()):
        rv[k] = float(hist[k]) / float(hist[k] + no_fire[k])

    return rv, no_fire, hist


def plot_activation_function(p, tau=20, fignum=0, figsize=(8,6)):
    fig = plt.figure(fignum, figsize=figsize)
    plt.clf()
    x = np.linspace(-10.0, 10.0, 100)
    y = 1.0/(1 + np.exp(-x + np.log(tau)))
    plt.plot(x, y)
    plt.plot(p.keys(), p.values(), '+')
    plt.hlines([0.5], xmin=-10.0, xmax=10.0)
    plt.ylim((-0.1, 1.1))
    return fig


def spikes_with_timestamps(fires):
    rv = []
    for t,f in enumerate(fires):
        for i,spike in enumerate(f):
            if spike:
                rv.append([t, i])
    return rv


def plot_spikes(states, fires):
    fig = plt.figure(figsize=(15,10))

    spikes = np.array(spikes_with_timestamps(fires))
    states_ar = np.array(states)
    for i in xrange(len(states[0])):
        plt.plot(0.1*states_ar[:,i]+i)
    plt.plot(spikes[:,0], spikes[:,1], '|', markersize=20)
    return fig


def plot_membrane(membranes):
    fig = plt.figure(figsize=(15,10))

    mem_ar = np.array(membranes)
    for i in xrange(len(membranes[0])):
        plt.plot(mem_ar[:,i], label='neuron %d' % i)
    plt.legend(loc='best')
    return fig


if __name__ == '__main__':
    read_trace('trace', 4)

