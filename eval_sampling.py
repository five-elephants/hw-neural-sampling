import numpy as np
import matplotlib.pyplot as plt
import csv

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
    hist = {}
    no_fire = {}

    for i in xrange(0,len(membranes)):
        m = membranes[i][neuron_i]
        #if fires[i][neuron_i] and not states[i-1][neuron_i]:
        if fires[i][neuron_i]:
            if m in hist:
                hist[m] += 1
            else:
                hist[m] = 1

        if not states[i][neuron_i]:
            if m in no_fire:
                no_fire[m] += 1
            else:
                no_fire[m] = 1


        #if not states[i-1][neuron_i]:
            #in_state_0 += 1

    #for k,v in hist.iteritems():
        #hist[k] = float(v) / float(in_state_0)

    rv = {}
    for k,v in hist.iteritems():
        if k in no_fire:
            rv[k] = float(v) / float(v + no_fire[k])
        else:
            rv[k] = 1.0

    return rv, no_fire, hist


if __name__ == '__main__':
    read_trace('trace', 4)

