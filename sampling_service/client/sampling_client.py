import xmlrpclib


class Sampling_client(object):
    def __init__(self, uri):
        self.server = xmlrpclib.ServerProxy(uri)

    def run_experiment(self, net_config, run_config):
        return self.server.run_experiment(net_config, run_config)
