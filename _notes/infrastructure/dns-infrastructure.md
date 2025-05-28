---
title: Open Source DNS and servers  🌱
category: infrastructure
---

DNS is critical for most companies working with email, web sites and using the Internet. We run our own domains using our servers and need to use DNS software, and the document below describes our setup.

I know that for many people domains, Domain Name System ([DNS](https://en.wikipedia.org/wiki/Domain_Name_System)), settings and hosting does not interest you much. Really it shouldn't but unless you have it configured correctly, setup on trustworthy systems and running smoothly it is a concern. Domains and DNS are the cornerstone of all Internet use, services, emails etc.

Here is a [haiku](https://en.wikipedia.org/wiki/Haiku)about DNS:

```
"It’s not DNS
There’s no way it’s DNS
It was DNS"
—u/SSBroski
```
source seems to be  - which might suggest it was posted on Reddit

This quote is often found when people are troubleshooting *network problems*, so popular that it is used in memes and pictures like this one:
[<img width=400px alt="Sakura picture with the haiku It’s not DNS, There’s no way it’s DNS, It was DNS —u/SSBroski" src="{{ site.baseurl }}/assets/dns.jpg"/>](https://www.debian.org/)

Source for the picture is unknown, but if you know the original creator, let me know!

## Prioritize DNS

So really DNS should be prioritized and your DNS infrastructure should be *robust* - whatever that means! Usually people will register a domain name, let it stay at the company, and forget all about it - until it needs to be renewed or changed. If you like me have multiple domains they may end up at different companies, with different registrars etc. This can make debugging annoying and harder that it should be.

First I recommend gathering your domains at a few registrars, the ones where you register your domain. They will have agreements with the [top-level domain](https://en.wikipedia.org/wiki/Top-level_domain) registries and if you are lucky you can have them all in one place. I have chosen [Joker.com](https://joker.com/) for most of my domains.

## Choose Your Own DNS Adventure with Open Source

You can also decide to run your own DNS infrastructure, which is something *I didn't want to do*. I was very happy about a service GratisDNS in Denmark for many many years. They ran a distributed DNS infrastructure for free, and I bought all my domains with them.

If you end up wanting to run your own DNS infrastructure, I highly recommend using [**Open Source**](https://en.wikipedia.org/wiki/Open-source_software)


## My Company Zencurity Aps uses NSD for DNS

Since we have a small security minded company, [Zencurity Aps](https://zencurity.com/) which also has an AS number, IPv4 and IPv6 resources - we decided to run our own DNS. This was not taken lightly and we investigated multiple options. First, we can find lists of DNS software in places like Wikipedia [https://en.wikipedia.org/wiki/Comparison_of_DNS_server_software](https://en.wikipedia.org/wiki/Comparison_of_DNS_server_software)

The server we are looking for is an [authoritative name server](https://en.wikipedia.org/wiki/Name_server), of which NSD is the main contender, since we already run [OpenBSD](https://www.openbsd.org/) which includes this software.

So the viable options were for us:
* NSD The NLnet Labs Name Server Daemon (NSD) is an authoritative DNS name server. [https://www.nlnetlabs.nl/projects/nsd/about/](https://www.nlnetlabs.nl/projects/nsd/about/)
* Knot DNS Knot DNS is a free software authoritative DNS server by CZ.NIC [https://www.knot-dns.cz/](https://www.knot-dns.cz/)
* BIND the old de facto standard DNS server. It is a free software product and is available with most Unix and Linux platforms
* PowerDNS [https://www.powerdns.com/](https://www.powerdns.com/)

We do currently not want to spend money on licenses, so commercial solutions are not deemed interesting. We also prefer the transparency and control with open source software. Further we want to use Domain Name System Security Extensions [(DNSSEC)](https://en.wikipedia.org/wiki/Domain_Name_System_Security_Extensions) we had used the [ldns-utils](https://www.nlnetlabs.nl/projects/ldns/about/) packages for managing DNSSEC. This has proven difficult, but more about that soon.

Note: Some of the software packages listed allow management of keys to be controlled by the software. BIND can do *automatic maintenance*, as described in [https://bind9.readthedocs.io/en/latest/dnssec-guide.html#enabling-automated-dnssec-zone-maintenance-and-key-generation](https://bind9.readthedocs.io/en/latest/dnssec-guide.html#enabling-automated-dnssec-zone-maintenance-and-key-generation)

## Key management tool for DNSSEC

Luckily we found a *simple tool* for this complex process, a software package named `dnssec-reverb`. This is a shell script based DNSSEC key management tool with a little less than 400 lines of code. This script also uses the tools from `ldns-utils` so the actual signing was done with tools already in use on the server.

We tested this with one domain, and have lated expanded use to all domains.

More information about the tool at `dnssec-reverb`:
[https://github.com/northox/dnssec-reverb](https://github.com/northox/dnssec-reverb)

## Managing multiple servers!

The best practice for DNS servers and infrastructure is to have at least two servers on different subnets, preferably in different [AS networks](https://en.wikipedia.org/wiki/Autonomous_system_(Internet))

Since we had an AS already, AS57860 we could decide to use our own addresses here, and currently we have a friend borrowing a /24 from us - which is routed with their AS number.

The design ended up being 4 DNS servers:
* ns00 is the hidden primary, having the master data for all zones
* ns01, ns02, ns03 are secondaries, of which ns03 is at another company routed through their AS

The software used is OpenBSD and built-in NSD with DNSSEC-reverb script for DNSSEC. This is documented in the decision record: decision-record: DNS Software

The next question was, how to adminster this whole mess. Since we already use [Ansible](https://en.wikipedia.org/wiki/Ansible_(software)) which is based on [Python](https://www.python.org/), an open source programming language we already had our basic infrastructure ready.

So there is a small [inventory files (hosts file)](https://docs.ansible.com/ansible/latest/inventory_guide/intro_inventory.html) for Ansible and our management server can reach the servers with Secure Shell (SSH). We use OpenBSD and [OpenSSH](https://www.openssh.com/) - more open source!

Then we can use the [Ansible Templating(Jinja2)](https://docs.ansible.com/ansible/2.8/user_guide/playbooks_templating.html) (open source) to write some basic [zone files for NSD](https://nsd.docs.nlnetlabs.nl/en/latest/zonefile.html), of which one example is below.

```
$ORIGIN test-ipv6.dk.
@ 43200 IN SOA ns1.gratisdns.dk. hostmaster.zencurity.com. (
00001111
14400
3600
2419000
43200
)

{ % for item in servers % }
@ 43200 IN NS { { item } }.zencurity.com.
{ % endfor % }

localhost 43200 IN A 127.0.0.1
www 43200 IN A 185.129.63.130
@ 43200 IN A 185.129.63.130
www 43200 IN AAAA 2a06:d380:0:101::80
@ 43200 IN AAAA 2a06:d380:0:101::80

@ 43200 IN TXT "v=spf1 -all"
_dmarc 43200 IN TXT "v=DMARC1; p=reject"
```
Note: the serial number `00001111` is special and will be replaced when signing the zone by the software. Also a few spaces were added to prevent Jekyll from eating the for item in servers percent and "{}"

I will not repeat the full Ansible configuration, as we use only basic features:
* Basic server configuration, installing packages, configure network and firewall `pf.conf` on OpenBSD
* Distributing the `dnssec-reverb` script - a single file
* Templating zone files, basic Ansible stuff

but it looks a bit like:
```
- name: Copy DNSSEC dnssec-reverb script
  template: src=roles/infrastructure-dns/{ { inventory_hostname_short } }/dnssec-reverb dest=/usr/local/sbin/dnssec-reverb owner=root group=bin mode=0755
  when: inventory_hostname_short == "ns00"
  tags:
    - zones
    - primary

- name: Update template web no MX zone files with DNSSEC
  template: src=roles/infrastructure-dns/{ { inventory_hostname_short } }/zones/templates/kramse-web-no-mx-dnssec.template dest=/var/nsd/zones/primary/{{ item | basename }} owner=root group=_nsd mode=0644
  with_items:
      - ipv4.dk
      - a-maerket.dk
      - tcpip.dk
...
```

As this might hint we use a couple of templates because a lot of the domain information is the same across domains. Most use the same mail server, if mail is needed, most use the same web server etc.

## Updating zones and servers

So whenever we need to update a domain, which is called a zone, we will modify the zone file - which are under version control using [Git](https://git-scm.com/) - another open source project!

Then we can run `ansible-playbook` to update:
```
yamabushi$ ansible-playbook -l ns00 -t primary infrastructure-dns.yml                                                                                                   

PLAY [dns] **************************************************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************************
ok: [ns00]

TASK [Copy DNSSEC dnssec-reverb script] *********************************************************************************************************************************
ok: [ns00]

TASK [Update primary zone files] ****************************************************************************************************************************************
ok: [ns00] => (item=/home/hlk/projects/andy/roles/infrastructure-dns/ns00/zones/primary/0.8.3.d.6.0.a.2.ip6.arpa)
ok: [ns00] => (item=/home/hlk/projects/andy/roles/infrastructure-dns/ns00/zones/primary/1.8.3.d.6.0.a.2.ip6.arpa)
...
ok: [ns00] => (item=/home/hlk/projects/andy/roles/infrastructure-dns/ns00/zones/primary/60.129.185.in-addr.arpa)
ok: [ns00] => (item=/home/hlk/projects/andy/roles/infrastructure-dns/ns00/zones/primary/61.129.185.in-addr.arpa)
ok: [ns00] => (item=/home/hlk/projects/andy/roles/infrastructure-dns/ns00/zones/primary/62.129.185.in-addr.arpa)
ok: [ns00] => (item=/home/hlk/projects/andy/roles/infrastructure-dns/ns00/zones/primary/63.129.185.in-addr.arpa)
ok: [ns00] => (item=/home/hlk/projects/andy/roles/infrastructure-dns/ns00/zones/primary/kramse.dk)
ok: [ns00] => (item=/home/hlk/projects/andy/roles/infrastructure-dns/ns00/zones/primary/kramse.org)
```

We can also manually (or automatically) patch systems with shell scripts:

```
#! /bin/sh
# OpenBSD upgrade

for GROUP in openbsd dns
do
  ansible -m syspatch -b --become-method doas $GROUP
  ansible -m shell -a "pkg_add -u"  -b --become-method doas $GROUP
done
```

and about twice a year will will run the OpenBSD upgrade process, which takes about 1-2 hours for all 4 servers. This process for the latest upgrade is documented at [https://www.openbsd.org/faq/upgrade77.html](https://www.openbsd.org/faq/upgrade77.html), and includes upgrading the packages like ldns.

## The end result

We have used many open source projects and software packages, and we are very grateful for this work! Thank you to all open source developers and related functions! The end result for us is that we have full control over our DNS infrastructure, with a manageable and very transparent stack of tools.

We believe that many organizations could replicate this, or be inspired to create a setup which can compete with commercial vendors of DNS.

Especially in Denmark, we suggest that more organizations consider *where* DNS is hosted currently, the risk associated with hosting services by american companies is perhaps not currently seen as a huge disadvantage, but can change quickly.


## Adding new zones require a short process:


* Add zone file - use an existing template
* Add section to nsd.conf in primary and secondaries
* Add zone/domain to the list of zones controlled by `dnssec-reverb` a single line entry in `dnssec-reverb.zones`
* Make server administrator generate key using `dnssec-reverb keygen`
* Make server administrator show key using `dnssec-reverb status`
* Enter key at registry, either via Joker.com or [https://punktum.dk/](https://punktum.dk/) for .dk domains

## Scripts

The main script is kept in `/usr/local/sbin/dnssec-reverb`

A utility script was added:
```              
ns00$ cat dnssec-reverb-add
#! /bin/sh

# Expected use:
#0       6       1       jan,apr,jul,oct *   dnssec-reverb-add.sh

# inspired by the original
#0       6       1       jan,apr,jul,oct *   dnssec-reverb -s zsk-add example.org

# Which operation?!
OPERATION=`echo $0 | cut -d '-' -f 3`

ZONES=`cat /home/hlk/bin/dnssec-reverb.zones`
for ZONE in $ZONES
do
	/usr/local/sbin/dnssec-reverb -s zsk-$OPERATION $ZONE
done
```

This is linked into 3 variants: add, check and roll which can use the list of zones in `dnssec-reverb.zones`

```
  ns00$ ls -li dnssec-reverb*                                                                                                                          
  26063 -rwxr-xr-x  4 hlk  hlk    395 Apr  1 19:28 dnssec-reverb-add
  26068 -rwxr-xr-x  1 hlk  hlk    195 Apr  5 15:04 dnssec-reverb-check
  26063 -rwxr-xr-x  4 hlk  hlk    395 Apr  1 19:28 dnssec-reverb-rmold
  26063 -rwxr-xr-x  4 hlk  hlk    395 Apr  1 19:28 dnssec-reverb-roll
  26062 -rw-r--r--  1 hlk  hlk  39875 Apr  1 20:34 dnssec-reverb.txt
  26064 -rw-r--r--  1 hlk  hlk    499 May 21 12:41 dnssec-reverb.zones
```

Finally crontab for root was amended:
```
ns00# crontab -l
#
SHELL=/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin
HOME=/var/log
#
#minute	hour	mday	month	wday	[flags] command
#
...
# New based on dnssec-reverb
# Note also re-signs the zones

0       6       1       jan,apr,jul,oct *  /home/hlk/bin/dnssec-reverb-add > /dev/null 2>&1
0       6       1       feb,may,aug,nov *  /home/hlk/bin/dnssec-reverb-roll > /dev/null 2>&1
0       6       1       mar,jun,sep,dec *  /home/hlk/bin/dnssec-reverb-rmold > /dev/null 2>&1
```


## dnssec-reverb config

The tools uses a small config, of which we only changed two lines:
```
  ns00# cat /etc/dnssec-reverb.conf                                                                                                                    
  MASTERDIR="/var/nsd/zones/primary"
  EXPIRE_DAYS="45"
```
