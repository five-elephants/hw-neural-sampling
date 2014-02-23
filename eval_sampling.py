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

def read_trace(filename, mem_width=16):
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
                        membranes[-1].append(string_to_fixed(cell, mem_width))

    return states, fires, membranes


def count_states(states):
    rv = []
    if states:
        ar = np.array(states)
        for i in range(len(states[0])):
            rv.append(float(np.count_nonzero(ar[:,i])) / float(ar[:,i].size))
    return rv


def count_joint_states(states):
    if states:
        rv = [ 0 for i in xrange(2**len(states[0])) ]
        for row in states:
            num = 0
            for i,c in enumerate(row):
                if c: num |= (1 << i);

            rv[num] += 1

        return rv
    else:
        return []


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


def plot_activation_function(h, tau=0.02, fignum=0):
    fig = plt.figure(fignum)
    plt.clf()
    x = np.linspace(-10.0, 10.0, 100)
    y = 1.0/(1 + np.exp(-x + np.log(tau)))
    plt.plot(x, y)
    plt.plot(h[0].keys(), h[0].values(), '+')
    plt.hlines([0.5], xmin=-10.0, xmax=10.0)
    plt.ylim((-0.1, 1.1))
    return fig




if __name__ == '__main__':
    read_trace('trace', 4)

