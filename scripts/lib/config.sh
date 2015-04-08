readonly HOSTNAME=$(hostname -f)

readonly ERLANGCOOKIEFILE="/var/lib/ejabberd/.erlang.cookie"
readonly EJABBERDCTL="/sbin/ejabberdctl"
readonly CONFIGFILE="/etc/ejabberd/ejabberd.yml"
readonly CONFIGTEMPLATE="${EJABBERD_HOME}/conf/ejabberd.yml.tpl"
readonly CTLCONFIGFILE="/etc/ejabberd/ejabberdctl.cfg"
readonly CTLCONFIGTEMPLATE="${EJABBERD_HOME}/conf/ejabberdctl.cfg.tpl"
readonly SSLCERTDIR="${EJABBERD_HOME}/ssl"
readonly SSLCERTHOST="${SSLCERTDIR}/host.pem"
readonly LOGDIR="/var/log/ejabberd/"

readonly PYTHON_JINJA2="import os;
import sys;
import jinja2;
sys.stdout.write(
    jinja2.Template
        (sys.stdin.read()
    ).render(env=os.environ))"
