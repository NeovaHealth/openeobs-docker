from invoke import Collection
from demo import demo
from demo import data
from build import build
from live import live
from db import db
from util import util
from internal import internal
from c4h import c4h

build_collection = Collection(
                                build.something,
                                build.another_thing
                            )

demo_collection = Collection(
                                demo.default,
                                demo.demo,
                                demo.upgrade,
                                demo.btuh,
                                demo.ldh,
                                demo.lister,
                                demo.lth,
                                demo.ldh,
                                demo.slam,
                                demo.cwp,
                                demo.dev,
                                demo.internal,
                                place_patients=data.place_patients,
                                admit_patients=data.admit_patients,
                                default_uat=data.uat_default_env,
                                lister_uat=data.uat_lister_env,
                                lth_uat=data.uat_lth_env,
                                btuh_uat=data.uat_btuh_env,
                                ldh_uat=data.uat_ldh_env,
                                slam_uat=data.uat_slam_env,
                                data=data.load_data,
                                ews=data.ews,
                                news_simulation=data.news_simulation,
                                load_test=data.load_test
                            )

live_collection = Collection(
                                live.default,
                                live.btuh,
                                live.ldh,
                                live.lister,
                                live.lth,
                                live.slam,
                                live.cwp
                            )
internal_collection = Collection(
    internal.upgrade,
    internal.neova,
    internal.create
)

c4h_collection = Collection(
    c4h.install,
    c4h.upgrade
)


db_collection = Collection(
                                db.drop,
                                db.drop_all,
                                db.list_all
                            )

test_collection = Collection(
                                util.test_enable_module,
                                util.test_enable_all_modules,
                                util.install_module,
                                util.uninstall_module
)
# GLOBAL NAME SPACE
ns = Collection(
                    build=build_collection, 
                    demo=demo_collection, 
                    live=live_collection,
                    test=test_collection,
                    db=db_collection,
                    internal=internal_collection,
                    c4h=c4h_collection
                )
