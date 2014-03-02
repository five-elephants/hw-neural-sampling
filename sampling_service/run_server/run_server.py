from SimpleXMLRPCServer import SimpleXMLRPCServer
from SimpleXMLRPCServer import SimpleXMLRPCRequestHandler
import sampling_service.synth_server.synth_client as syncl


class Run_server(object):
    def __init__(self, synth_uri):
        self.syn = syncl.Synth_client(synth_uri)

    def run_experiment(self, net_config, run_config):
        rv = {}
        print "running experiment with parameters: "
        print net_config
        print run_config

        print "=== Synthesis ==="
        bitstream = self.syn.get_bitfile(net_config)

        print "=== Run experiment ==="

        rv = {
            'observers': [
                0 for i in net_config['observers']
            ],
        }

        return rv

class RequestHandler(SimpleXMLRPCRequestHandler):
    rpc_paths = ('/RPC2',)


if __name__ == '__main__':
    server = SimpleXMLRPCServer(('localhost', 8000), requestHandler=RequestHandler)
    server.register_introspection_functions()
    server.register_instance(Run_server('http://localhost:8001'))


    server.serve_forever();
