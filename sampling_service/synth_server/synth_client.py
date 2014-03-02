import xmlrpclib


class Synth_client(object):
    def __init__(self, uri):
        self.server = xmlrpclib.ServerProxy(uri)

    def get_bitfile(self, net_config):
        return self.server.run_flow(net_config)

