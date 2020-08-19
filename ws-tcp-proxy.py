#!/usr/bin/env python3

import asyncio
import websockets
import binascii

import socket
import random

import sys
import getopt

help_str = 'ws-tcp-proxy.py -l <lite-server ip> -p <lite-server port> -b <bind ip> -d <bind port> -v'

LITE_IP = '127.0.0.1'
LITE_PORT = 46732
BIND_IP = '0.0.0.0'
BIND_PORT = 7004
BUFFER_SIZE = 102400
verbose = False

try:
    opts, args = getopt.getopt(sys.argv[1:],"hvl:p:b:d:",[])
except getopt.GetoptError:
    print(help_str, flush=True)
    sys.exit(2)

for opt, arg in opts:
    if opt == '-h':
        print(help_str)
        sys.exit()
    elif opt == '-v':
        verbose = True
    elif opt == '-l':
        LITE_IP = arg
    elif opt == '-p':
        LITE_PORT = int(arg)
    elif opt == '-b':
        BIND_IP = arg
    elif opt == '-d':
        BIND_PORT = int(arg)


async def ws2tcp(ws, tcp):
    if verbose:
        print('listening client', flush=True)
    try:
        while True:
            data = await ws.recv()
            if len(data) > 0:
                print('request: ' + str(len(data)), flush=True)
                #print(binascii.hexlify(bytearray(data)))
                #if random.choice([0,1]) == 0:
                #    print('Check error')
                #    data = bytearray(data)
                #    data[random.randint(0, len(data)-1)] = random.randint(0, 255)
                #    data = bytes(data)
                tcp.write(data)
    except websockets.exceptions.ConnectionClosedError as e:
        pass
    except websockets.exceptions.ConnectionClosedOK as e:
        pass
    except Exception as e:
        print('Error ws2tcp: ' + str(e), flush=True)
    finally:
        if verbose:
            print('ws2tcp end', flush=True)
        tcp.close()


async def tcp2ws(tcp, ws):
    if verbose:
        print('listening server', flush=True)
    try:
        while not tcp.at_eof():
            #while True:
            data = await tcp.read(BUFFER_SIZE)
            if len(data) > 0:
                if verbose:
                    print('reply: ' + str(len(data)), flush=True)
                await ws.send(data)
    finally:
        if verbose:
            print('tcp2ws end', flush=True)
        await ws.close()


async def handle_client(ws):
    try:
        remote_reader, remote_writer = await asyncio.wait_for(asyncio.open_connection(LITE_IP, LITE_PORT), timeout = 30)
        # print('Connected to server')
        pipe1 = ws2tcp(ws, remote_writer)
        pipe2 = tcp2ws(remote_reader, ws)
        await asyncio.gather(pipe1, pipe2)
    except asyncio.TimeoutError:
        print('Timeout connecting to server', flush=True)
    except Exception as e:
        print('Error connecting to server', flush=True)
    finally:
        pass


async def ws_server(websocket, path):
    if verbose:
        print('new client', flush=True)
    await handle_client(websocket)
    if verbose:
        print('client disconnected', flush=True)
    return


if __name__ == "__main__":
    print('Start ws-tcp proxy server from %s:%d to %s:%d' % (LITE_IP, LITE_PORT, BIND_IP, BIND_PORT), flush=True)
    start_server = websockets.serve(ws_server, BIND_IP, BIND_PORT)
    asyncio.get_event_loop().run_until_complete(start_server)
    asyncio.get_event_loop().run_forever()
