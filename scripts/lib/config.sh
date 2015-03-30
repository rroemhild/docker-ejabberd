readonly HOSTNAME=$(hostname -f)

readonly ERLANGCOOKIEFILE="${EJABBERD_ROOT}/.erlang.cookie"
readonly EJABBERDCTL="${EJABBERD_ROOT}/bin/ejabberdctl"
readonly CONFIGFILE="${EJABBERD_ROOT}/conf/ejabberd.yml"
readonly CONFIGTEMPLATE="${EJABBERD_ROOT}/conf/ejabberd.yml.tpl"
readonly CTLCONFIGFILE="${EJABBERD_ROOT}/conf/ejabberdctl.cfg"
readonly CTLCONFIGTEMPLATE="${EJABBERD_ROOT}/conf/ejabberdctl.cfg.tpl"
readonly SSLCERTDIR="${EJABBERD_ROOT}/ssl"
readonly SSLCERTHOST="${SSLCERTDIR}/host.pem"
readonly LOGDIR="${EJABBERD_ROOT}/logs"

readonly PYTHON_JINJA2="import os;
import sys;
import jinja2;
sys.stdout.write(
    jinja2.Template
        (sys.stdin.read()
    ).render(env=os.environ))"
