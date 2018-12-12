### Check and start the 'PowerDNS' container.
powerdns.sh

### Stop and delete the running 'PowerDNS' container.
powerdns.sh rm [params]

### Stop the running 'PowerDNS' container.
powerdns.sh stop [params]

### Start the 'PowerDNS' container. If earlier you stopped it.
powerdns.sh start [params]

### Create zone and ns1 record into dns server.
powerdns.sh create-zone

### Add new record into dns server,
powerdns.sh add-record name type content

For example:
 - powerdns.sh add-record metropc A 10.0.10.54
 - powerdns.sh add-record metropc TXT some_text_without_space

This record needed for NSK baremetal kube servers:
 - powerdns.sh add-record kubernetes-master A 10.0.7.15

### Get information about managed zone.
powerdns.sh list-zone
