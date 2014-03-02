from SimpleXMLRPCServer import SimpleXMLRPCServer
from SimpleXMLRPCServer import SimpleXMLRPCRequestHandler


class Synth_server(object):
    def run_flow(self, net_config):
        return ""


class RequestHandler(SimpleXMLRPCRequestHandler):
    rpc_paths = ('/RPC2',)


if __name__ == '__main__':
    server = SimpleXMLRPCServer(('localhost', 8001), requestHandler=RequestHandler)
    server.register_introspection_functions()
    server.register_instance(Synth_server())
    server.serve_forever();
