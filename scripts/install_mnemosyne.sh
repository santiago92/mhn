#!/bin/bash

set -e
set -x

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:$PATH

PYTHON=/usr/bin/python
PIP=/usr/bin/pip
VIRTUALENV=/usr/local/bin/virtualenv
mkdir /home/santi/tesis/webapi 
cd /opt/
git clone https://github.com/threatstream/mnemosyne.git
cd mnemosyne
$VIRTUALENV -p $PYTHON env
. env/bin/activate
pip install -r requirements.txt
chmod 755 -R .

IDENT=mnemosyne
SECRET=`python -c 'import uuid;print str(uuid.uuid4()).replace("-","")'`
CHANNELS='amun.events,conpot.events,thug.events,beeswarm.hive,dionaea.capture,dionaea.connections,thug.files,beeswarn.feeder,cuckoo.analysis,kippo.sessions,cowrie.sessions,glastopf.events,glastopf.files,mwbinary.dionaea.sensorunique,snort.alerts,wordpot.events,p0f.events,suricata.events,shockpot.events,elastichoney.events'

cat > /opt/mnemosyne/mnemosyne.cfg <<EOF
[webapi]
host = 0.0.0.0
port = 8181

[mongodb]
database = mnemosyne

[hpfriends]
host = localhost
port = 10000
ident = $IDENT
secret = $SECRET
channels = $CHANNELS

[file_log]
enabled = True
file = /var/log/mhn/mnemosyne.log

[loggly_log]
enabled = False
token =

[normalizer]
ignore_rfc1918 = False
EOF

deactivate
. /opt/hpfeeds/env/bin/activate
python /opt/hpfeeds/broker/add_user.py "$IDENT" "$SECRET" "" "$CHANNELS"

mkdir -p /var/log/mhn/

cat >> /etc/supervisor/conf.d/mnemosyne.conf <<EOF 
[program:mnemosyne]
command=/opt/mnemosyne/env/bin/python runner.py --config mnemosyne.cfg
directory=/opt/mnemosyne
stdout_logfile=/var/log/mhn/mnemosyne.out
stderr_logfile=/var/log/mhn/mnemosyne.err
autostart=true
autorestart=true
startsecs=10
EOF

supervisorctl update
