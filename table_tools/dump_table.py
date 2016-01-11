#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os
import time
import multiprocessing

from table_writer import *
from collections import defaultdict

CONF_PATH = './dump_list.conf'
PROTO_PATH = '../proto'
PROTOC = '/usr/local/bin/protoc'

MOD = 4 # 进程个数

def ParseConf():
    dump_list = []
    try:
        file_handle = open(CONF_PATH, 'r')
        for line in file_handle.readlines():
            line = line.lstrip().rstrip()
            if len(line) > 0 and line[0] != '#':
                dump_list.append(line)
        file_handle.close()
    except IOError:
        logger.error("错误的配置文件路径:%s " % CONF_PATH)
    return dump_list

def CompileProtoToPy():
    for proto in os.listdir(PROTO_PATH):
        if '.proto' in proto and proto[0] != '.':
            proto = os.path.join(PROTO_PATH, proto);
            logger.trace("compile %s" % proto)
            os.system("%s -I%s --python_out=%s %s" % \
                      (PROTOC, PROTO_PATH, PROTO_PATH, proto))
    logger.trace('update webserver/boss/proto')
    if os.path.exists('../../webserver/boss/proto'):
        os.system('cp -f `find %s -name "*_pb2.py" -a ! -name "c_table_*"` ../../webserver/boss/proto' \
                  % PROTO_PATH)

def ProcessFunc(args_list):
    name = multiprocessing.current_process().name
    for args in args_list:
        TableWriter(*args[:-1])(args[-1])

def Usage():
    print 'Usage:'
    print '\t-jn: 进程个数(1<=n<=4)  默认[-j4]'
    print '\t-d : 调试模式     默认[关闭]'
    print '\t-h : 使用说明，也可以使用 [help|?]'
    print 'eg:'
    print '\t./dump_table.py        # 默认的处理方式等价于 ./dump_table.py -j4'
    print '\t./dump_table.py -j2 -d # 两个进程运行，打开调试模式(输出详尽的LOG)'

if __name__ == "__main__":
    for i in range(1, len(sys.argv)):
        if sys.argv[i] == '-d':
            logger.set_level(Logger.LOG_LEVEL_TRACE)
        elif sys.argv[i] == '-j1':
            MOD = 1
        elif sys.argv[i] == '-j2':
            MOD = 2
        elif sys.argv[i] == '-j3':
            MOD = 3
        elif sys.argv[i] == '-j4':
            MOD = 4
        else:
            Usage()
            exit(-1)
    
    logger.info("检查配置文件有效性 ...")
    dump_list = ParseConf()
    args_list = []
    for dl in dump_list:
        arg = re.sub('\s\s+', ' ', dl).split(' ')
        result = ParseArg(arg)
        if not result[0]:
            logger.warn('错误的配置文件行: %s' % dl);
            exit(-1)
        args_list.append(result[1])
        
    logger.info('compile proto to python')
    CompileProtoToPy()
    
    logger.info("DUMPING tables")
    id_2_list = defaultdict(list)
    for i in range(0, len(args_list)):
        id_2_list[i % MOD].append(args_list[i])

    process = []
    for i in range(0, MOD):
        d = multiprocessing.Process(name="process - %d" % i, \
                                    target=ProcessFunc, args=(id_2_list[i],))        
        d.daemon = True
        process.append(d)
        d.start()
        
    for p in process:
        p.join()
        if p.exitcode:
            exit(p.exitcode)

    logger.info("update to webserver/boss/table")
    if os.path.exists('../../webserver/boss/table'):
        os.system("cp -f ../table_output/*.tbl ../../webserver/boss/table")

    logger.info('ALL TABLES DUMPED DONE!!!')
