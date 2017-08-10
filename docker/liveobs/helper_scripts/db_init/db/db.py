from invoke import task, run
from util import util
import re

@task
def drop(db, user='odoo8', password='odoo8', host='localhost', port=5432, ifexists=True):
    """
    Drop database postgres tools
    All arguments related to postgres
    """
    run("set PGPASSWORD=%s" % password)
    try:
        ifexists_option=""
        if ifexists:
            ifexists_option="--if-exists"
        run("dropdb -h {host} -p {port} -U {user} {ifexists_option} {db}".format(host=host, port=port, user=user, db=db, ifexists_option=ifexists_option))
    except Exception as e:
        print "Dropping database %s has failed!" % db
        print e
    else:
        ifexists_clause=""
        if ifexists:
            ifexists_clause=" or doesn't exist"
        print "Database '%s' dropped successfully%s." % (db, ifexists_clause)    
    finally:    
        run("unset PGPASSWORD")
        
@task        
def list_all(server='http://localhost:8069', verbose=False):
    client = util.get_erppeek_client(server, verbose=verbose)
    print client.db.list()
    
    
@task
def drop_all(user, password='odoo8', host='localhost', port=5432, ifexists=False):
    """
    Drop database postgres tools
    All arguments related to postgres
    """
    run("set PGPASSWORD=%s" % password)
    db_list = run("psql -l -t -h {host} -p {port} -U {user}"
                  .format(host=host, port=port, user=user))
    run("unset PGPASSWORD")
    rows = db_list.stdout.split('\n')
    for row in rows:
        row = [r.strip() for r in row.split('|') if r]
        if not len(row):
            continue
        list_db = row[0]
        list_user = row[1]
        if list_user == user: 
            drop(list_db, user, password, host, port, ifexists)
