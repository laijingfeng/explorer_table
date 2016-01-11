#!/bin/sh

PROTO_PATH=../proto
PROTOC=/usr/local/bin/protoc

# compile proto to python
for proto in $(ls ${PROTO_PATH}/*.proto); do
    ${PROTOC} -I${PROTO_PATH} --python_out=${PROTO_PATH} ${proto}
done

# try to update webserver/oss/proto
if [ -d ../../webserver/oss/proto ]; then
    cp -f ${PROTO_PATH}/{common,table,command}*_pb2.py ../../webserver/oss/proto
fi

# dump tables
echo "start dumping[`date`]" >> dump_table.log

python table_writer.py -s 0 -m ROLE_BASIC -o role_basic "Role"                  && \
python table_writer.py -s 1 -m ROLE_LEV -o role_lev "Role"                      && \
python table_writer.py -s 0 -m SCENE -o scene "Scene"                           && \
python table_writer.py -s 0 -m ITEM -o item "Item"                              && \
python table_writer.py -s 1 -m EQUIP_ATTR -o equip_attr "Item"                  && \
python table_writer.py -s 2 -m EQUIP_GEM -o equip_gem "Item"                    && \
python table_writer.py -s 3 -m GEM_CONSUME -o gem_consume "Item"                && \
python table_writer.py -s 4 -m GEM_ATTR -o gem_attr "Item"                      && \
python table_writer.py -s 5 -m DEGREE_ATTR -o degree_attr "Item"                && \
python table_writer.py -s 6 -m DEGREE_LEV -o degree_lev "Item"                  && \
python table_writer.py -s 0 -m MISSION -o mission "Mission"                     && \
python table_writer.py -s 1 -m SKILL_ATTR -o skill_attr "Skill"                 && \
python table_writer.py -s 0 -m COLLECTION -o collection "Collection"            && \
python table_writer.py -s 1 -m TREASURE -o treasure "Collection"                && \
python table_writer.py -s 0 -m GOODS -o goods "Shop"                            && \
python table_writer.py -s 1 -m COLLECTION_SHOP -o collection_shop "Shop"        && \
python table_writer.py -s 2 -m ITEM_GOODS -o item_goods "Shop"                  && \
python table_writer.py -s 0 -m TERR_MAP -o terr_map "Territory"                 && \
python table_writer.py -s 1 -m TERR_NORMAL_CELL -o terr_normal_cell "Territory" && \
python table_writer.py -s 2 -m TERR_HERO_CELL -o terr_hero_cell "Territory"     && \
python table_writer.py -s 3 -m TERR_RAND_EVENT -o terr_rand_event "Territory"   && \
python table_writer.py -s 5 -m TERR_NEWBIE_GUIDE -o terr_newbie_guide "Territory" && \
python table_writer.py -s 0 -m VIP -o vip "VIP"                                 && \
python table_writer.py -s 0 -m ACTIVITY_AWARD -o activity_award "Activity"      && \
python table_writer.py -s 1 -m ACTIVITY_MISSION -o activity_mission "Activity"  && \
python table_writer.py -s 0 -m HERO -o hero "Hero"                              && \
python table_writer.py -s 1 -m HERO_ADVANCED -o hero_advanced "Hero"            && \
python table_writer.py -s 0 -m RECHARGE_PRODUCT -o recharge_product "Recharge"  && \
python table_writer.py -s 0 -m DAILY_AWARD -o daily_award "DailyAward"          && \
python table_writer.py -s 0 -m ONLINE_AWARD -o online_award "OnlineAward"       && \
python table_writer.py -s 0 -m PROBLEM -o problem "Problem"                     && \
python table_writer.py -s 1 -m RECHARGE_AWARD -o recharge_award "Recharge"      && \
python table_writer.py -s 0 -m ITEM_EXCHANGE -o item_exchange "Exchange"        && \
python table_writer.py -s 0 -m RANK_AWARD -o arena_rank_award "RankAward"       && \
python table_writer.py -s 1 -m RANK_AWARD -o exam_rank_award  "RankAward"       && \
python table_writer.py -s 2 -m RANK_AWARD -o tower_rank_award "RankAward"       && \
python table_writer.py -s 3 -m RANK_AWARD -o world_boss_rank_award "RankAward"  && \
python table_writer.py -s 2 -m CLIMB_TOWER_CHESTS  -o climb_tower_chests  "ClimbTower"      && \
python table_writer.py -s 0 -m CLIMB_TOWER_LAYER   -o climb_tower_layer   "ClimbTower"      && \
python table_writer.py -s 1 -m CLIMB_TOWER_MONSTER -o climb_tower_monster "ClimbTower"      && \
python table_writer.py -s 0 -m LOTTERY_AWARD      -o lottery_award      "Lottery"           && \
python table_writer.py -s 1 -m LOTTERY_SHOP_GOODS -o lottery_shop_goods "Lottery"           && \
python table_writer.py -s 3 -m LOTTERY_LEV        -o lottery_lev        "Lottery"           && \
python table_writer.py -s 0 -m WORLD_BOSS -o world_boss "WorldBoss"             && \

echo "ALL TABLE DUMPED [OK] !!!"

ret=$?

echo "end dumping[`date`]" >> dump_table.log

# try to update webserver/oss/table
if [ -d ../../webserver/oss/table ]; then
    cp -f ../table_output/*.tbl ../../webserver/oss/table
fi

exit $ret

