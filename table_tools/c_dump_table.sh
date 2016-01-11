#!/bin/sh

PROTO_PATH=../proto
PROTOC=/usr/local/bin/protoc
for proto in $(ls ${PROTO_PATH}/*.proto); do
    ${PROTOC} -I${PROTO_PATH} --python_out=${PROTO_PATH} ${proto}
done

echo "start dumping[`date`]" >> c_dump_table.log

export DEFAULT_PROTO_PREFIX="c_table_"
export DEFAULT_OUTPUT_SUFFIX="bytes"

env | grep DEFAULT

python table_writer.py -s 0 -m SERVER_NOTICE_MSG -o server_notice_msg "ServerNoticeMsg"     && \

echo "ALL TABLE DUMPED [OK] !!!"

ret=$?

echo "end dumping[`date`]" >> c_dump_table.log

exit $ret


