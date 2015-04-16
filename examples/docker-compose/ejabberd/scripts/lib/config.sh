readonly HOST_IP=$(hostname -i)
readonly HOST_NAME=$(hostname -s)
readonly ETCD_EJABBERD_ROOT="/ejabberd"
readonly ETCD_EJABBERD_CLUSTER="${ETCD_EJABBERD_ROOT}/cluster"

readonly PYTHON_JSON_NODE_VALUE="import sys;
import json;
try:
    obj=json.load(sys.stdin);
    values = obj['node']['value']
    values = json.loads(values)
    print values['status']
except:
    sys.exit(0)"

readonly PYTHON_JSON_NODE_KEYS="import sys;
import json;
try:
    obj=json.load(sys.stdin);
    for node in obj['node']['nodes']:
        print node['key']
except:
    sys.exit(0)"
