#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#undef PERL_UNUSED_DECL
#include "ppport.h"
#include <stdio.h>
#include <db.h>

#include <libbttracker.h>

#include "apr.h"
#include "apr_pools.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

/* #include "const-c.inc" */

typedef struct _perlhash
{
 btt_infohash*	hash;
 btt_tracker*	tracker;
 apr_pool_t*	p;
} perlhash;

typedef struct _perlpeer
{
 btt_peer*		peer;
 btt_infohash*	hash;
 btt_tracker*	tracker;
 apr_pool_t*	p;
} perlpeer;

typedef struct _perlpeer * Net__BitTorrent__LibBT__Tracker__Peer;
typedef struct _perlhash * Net__BitTorrent__LibBT__Tracker__Infohash;
typedef struct btt_tracker_config_s * Net__BitTorrent__LibBT__Tracker__Config;
typedef struct btt_tracker_stats_s * Net__BitTorrent__LibBT__Tracker__Stats;

MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker

PROTOTYPES: ENABLE

void
Flags()
	INIT:
	int i;
	PPCODE:
	for(i=0;btt_tracker_flags[i].flag;i++)
	{
	 XPUSHs(sv_2mortal(newSViv(btt_tracker_flags[i].flag)));
     XPUSHs(sv_2mortal(newSVpv(btt_tracker_flags[i].config_name, strlen(btt_tracker_flags[i].config_name))));
	}

Net::BitTorrent::LibBT::Tracker
new(class, homedir, master=0)
	char*	class
	char*	homedir
	int		master

	CODE:
	apr_pool_t	*p = NULL;
	btt_tracker	*rv = NULL;
	btt_perltracker	*t = NULL;
	
	class = class;
	
	New(0, t, 1, btt_perltracker);
    apr_pool_create(&p, NULL);
	t->master = master;
	t->p = p;

	if((rv = btt_tracker_alloc(p, homedir, master)))
	{
	 if(btt_tracker_connect(rv, master))
	 {
	  t->tracker = rv;
	 }
	 else
	 {
	  btt_tracker_free(&rv, master);
	  XSRETURN_UNDEF;
	 }
	}
	else
	{
	 XSRETURN_UNDEF;
	}
	
	RETVAL = (Net__BitTorrent__LibBT__Tracker) t;
	
	OUTPUT:
	RETVAL

MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker

void
DESTROY(t)
	Net::BitTorrent::LibBT::Tracker	t
	
	CODE:
	btt_tracker* tracker = t->tracker;
	if(t->master != -1)
	{
 	 if(tracker)
 	 {
 	  btt_tracker_disconnect(tracker);
 	  btt_tracker_free(&tracker, t->master);
 	 }
 	}
	apr_pool_destroy(t->p);
	Safefree(t);

MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker

Net::BitTorrent::LibBT::Tracker::Config
c(t)
	Net::BitTorrent::LibBT::Tracker	t
	
	CODE:
	RETVAL = (Net__BitTorrent__LibBT__Tracker__Config) t->tracker->c;
	
	OUTPUT:
	RETVAL

Net::BitTorrent::LibBT::Tracker::Stats
s(t)
	Net::BitTorrent::LibBT::Tracker	t
	
	CODE:
	RETVAL = (Net__BitTorrent__LibBT__Tracker__Stats) t->tracker->s;
	
	OUTPUT:
	RETVAL


void
cxn_announce(t, args, user_agent, addr, port)
	Net::BitTorrent::LibBT::Tracker	t;
	char*							args;
	char*							user_agent;
	u_int32_t						addr;
	u_int16_t						port;

	PPCODE:
	struct sockaddr_in address = { AF_INET, htons(port), { addr } };
	char* content = NULL;
	int len = 0;
	int rv;
	apr_pool_t* p;
	
	apr_pool_create(&p, t->tracker->p);
	
	rv = btt_cxn_announce(t->tracker, p, NULL, args, user_agent, address, &content, &len);

	XPUSHs(sv_2mortal(newSViv(rv)));
	XPUSHs(sv_2mortal(newSViv(len)));
	if(len)
	 XPUSHs(sv_2mortal(newSVpv(content, len)));
	
void
cxn_details(t, args, addr, port)
	Net::BitTorrent::LibBT::Tracker	t;
	char*							args;
	u_int32_t						addr;
	u_int16_t						port;

	PPCODE:
	struct sockaddr_in address = { AF_INET, htons(port), { addr } };
	char* content = NULL;
	int len = 0;
	int rv;
	apr_pool_t* p;
	
	apr_pool_create(&p, t->tracker->p);
	
	rv = btt_cxn_details(t->tracker, p, NULL, args, address, &content, &len);

	XPUSHs(sv_2mortal(newSViv(rv)));
	XPUSHs(sv_2mortal(newSViv(len)));
	if(len)
	 XPUSHs(sv_2mortal(newSVpv(content, len)));
	
void
cxn_register(t, args, addr, port)
	Net::BitTorrent::LibBT::Tracker	t;
	char*							args;
	u_int32_t						addr;
	u_int16_t						port;

	PPCODE:
	struct sockaddr_in address = { AF_INET, htons(port), { addr } };
	char* content = NULL;
	int len = 0;
	int rv;
	apr_pool_t* p;
	
	apr_pool_create(&p, t->tracker->p);
	
	rv = btt_cxn_register(t->tracker, p, NULL, args, address, &content, &len);

	XPUSHs(sv_2mortal(newSViv(rv)));
	XPUSHs(sv_2mortal(newSViv(len)));
	if(len)
	 XPUSHs(sv_2mortal(newSVpv(content, len)));
	

void
cxn_scrape(t, args, addr, port)
	Net::BitTorrent::LibBT::Tracker	t;
	char*							args;
	u_int32_t						addr;
	u_int16_t						port;

	PPCODE:
	struct sockaddr_in address = { AF_INET, htons(port), { addr } };
	char* content = NULL;
	int len = 0;
	int rv;
	apr_pool_t* p;
	
	apr_pool_create(&p, t->tracker->p);
	
	rv = btt_cxn_scrape(t->tracker, p, NULL, args, address, &content, &len);

	XPUSHs(sv_2mortal(newSViv(rv)));
	XPUSHs(sv_2mortal(newSViv(len)));
	if(len)
	 XPUSHs(sv_2mortal(newSVpv(content, len)));


MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker::Config

SV*
stylesheet(c, stylesheet=NULL)
	Net::BitTorrent::LibBT::Tracker::Config	c
	char*	stylesheet
	
	CODE:
	RETVAL = newSVpv(c->stylesheet, strlen(c->stylesheet));
	
	if(stylesheet)
	{
	 strncpy(c->stylesheet, stylesheet, sizeof(c->stylesheet) - 1);
	 c->stylesheet[sizeof(c->stylesheet)] = 0;
	}
	
	OUTPUT:
	RETVAL

SV*
detail_url(c, detail_url=NULL)
	Net::BitTorrent::LibBT::Tracker::Config	c
	char*	detail_url
	
	CODE:
	RETVAL = newSVpv(c->detail_url, strlen(c->detail_url));
	
	if(detail_url)
	{
	 strncpy(c->detail_url, detail_url, sizeof(c->detail_url) - 1);
	 c->detail_url[sizeof(c->detail_url)] = 0;
	}
	
	OUTPUT:
	RETVAL

SV*
root_include(c, root_include=NULL)
	Net::BitTorrent::LibBT::Tracker::Config	c
	char*	root_include
	
	CODE:
	RETVAL = newSVpv(c->root_include, strlen(c->root_include));
	
	if(root_include)
	{
	 strncpy(c->root_include, root_include, sizeof(c->root_include) - 1);
	 c->root_include[sizeof(c->root_include)] = 0;
	}
	
	OUTPUT:
	RETVAL



SV*
db_dir(c)
	Net::BitTorrent::LibBT::Tracker::Config	c
	
	CODE:
	RETVAL = newSVpv(c->db_dir, strlen(c->db_dir));
	
	OUTPUT:
	RETVAL

u_int16_t
flags(c, newflags=0)
	Net::BitTorrent::LibBT::Tracker::Config	c
    u_int16_t	newflags;
	
	CODE:
	RETVAL = c->flags;
	if(items > 1)
	 c->flags = newflags;
	
	OUTPUT:
	RETVAL

u_int32_t
random_retry(c, newval=0)
	Net::BitTorrent::LibBT::Tracker::Config	c
    u_int32_t	newval;
	
	CODE:
	RETVAL = c->random_retry;
	if(items > 1)
	 c->random_retry = newval;
	
	OUTPUT:
	RETVAL

u_int32_t
return_peers(c, newval=0)
	Net::BitTorrent::LibBT::Tracker::Config	c
    u_int32_t	newval;
	
	CODE:
	RETVAL = c->return_peers;
	if(items > 1)
	 c->return_peers = newval;
	
	OUTPUT:
	RETVAL

u_int32_t
return_max(c, newval=0)
	Net::BitTorrent::LibBT::Tracker::Config	c
    u_int32_t	newval;
	
	CODE:
	RETVAL = c->return_max;
	if(items > 1)
	 c->return_max = newval;
	
	OUTPUT:
	RETVAL

time_t
return_interval(c, newval=0)
	Net::BitTorrent::LibBT::Tracker::Config	c
    time_t	newval;
	
	CODE:
	RETVAL = c->return_interval;
	if(items > 1)
	 c->return_interval = newval;
	
	OUTPUT:
	RETVAL

u_int32_t
return_peer_factor(c, newval=0)
	Net::BitTorrent::LibBT::Tracker::Config	c
    u_int32_t	newval;
	
	CODE:
	RETVAL = c->return_peer_factor;
	if(items > 1)
	 c->return_peer_factor = newval;
	
	OUTPUT:
	RETVAL

u_int32_t
hash_watermark(c, newval=0)
	Net::BitTorrent::LibBT::Tracker::Config	c
    u_int32_t	newval;
	
	CODE:
	RETVAL = c->hash_watermark;
	if(items > 1)
	 c->hash_watermark = newval;
	
	OUTPUT:
	RETVAL

time_t
hash_min_age(c, newval=0)
	Net::BitTorrent::LibBT::Tracker::Config	c
    u_int32_t	newval;
	
	CODE:
	RETVAL = c->hash_min_age;
	if(items > 1)
	 c->hash_min_age = newval;
	
	OUTPUT:
	RETVAL

time_t
hash_max_age(c, newval=0)
	Net::BitTorrent::LibBT::Tracker::Config	c
    u_int32_t	newval;
	
	CODE:
	RETVAL = c->hash_max_age;
	if(items > 1)
	 c->hash_max_age = newval;
	
	OUTPUT:
	RETVAL

SV*
parent_server(c)
	Net::BitTorrent::LibBT::Tracker::Config	c
	
	CODE:
	RETVAL = newSVpv(c->parent_server, strlen(c->parent_server));
	
	OUTPUT:
	RETVAL


MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker::Stats

u_int32_t
num_children(s)
	Net::BitTorrent::LibBT::Tracker::Stats		s
	
	CODE:
	RETVAL = s->num_children;
	OUTPUT:
	RETVAL

u_int32_t
num_requests(s, newval=0)
	Net::BitTorrent::LibBT::Tracker::Stats		s
	u_int32_t									newval;
	
	CODE:
	RETVAL = s->num_requests;
	if(items > 1)
	 s->num_requests = newval;
	OUTPUT:
	RETVAL

u_int32_t
num_hashes(s)
	Net::BitTorrent::LibBT::Tracker::Stats		s
	
	CODE:
	RETVAL = s->num_hashes;
	OUTPUT:
	RETVAL

u_int32_t
num_peers(s)
	Net::BitTorrent::LibBT::Tracker::Stats		s
	
	CODE:
	RETVAL = s->num_peers;
	OUTPUT:
	RETVAL

u_int64_t
announces(s,newval=0)
	Net::BitTorrent::LibBT::Tracker::Stats		s
	u_int64_t									newval;
	
	CODE:
	RETVAL = s->announces;
	if(items>1)
	 s->announces = newval;
	OUTPUT:
	RETVAL

u_int64_t
scrapes(s,newval=0)
	Net::BitTorrent::LibBT::Tracker::Stats		s
	u_int64_t									newval;
	
	CODE:
	RETVAL = s->scrapes;
	if(items>1)
	 s->scrapes = newval;
	OUTPUT:
	RETVAL

u_int64_t
full_scrapes(s,newval=0)
	Net::BitTorrent::LibBT::Tracker::Stats		s
	u_int64_t									newval;
	
	CODE:
	RETVAL = s->full_scrapes;
	if(items>1)
	 s->full_scrapes = newval;
	OUTPUT:
	RETVAL

u_int64_t
bad_announces(s,newval=0)
	Net::BitTorrent::LibBT::Tracker::Stats		s
	u_int64_t									newval;
	
	CODE:
	RETVAL = s->bad_announces;
	if(items>1)
	 s->bad_announces = newval;
	OUTPUT:
	RETVAL

u_int64_t
bad_scrapes(s,newval=0)
	Net::BitTorrent::LibBT::Tracker::Stats		s
	u_int64_t									newval;
	
	CODE:
	RETVAL = s->bad_scrapes;
	if(items>1)
	 s->bad_scrapes = newval;
	OUTPUT:
	RETVAL

time_t
start_t(s,newval=0)
	Net::BitTorrent::LibBT::Tracker::Stats		s
	time_t										newval;
	
	CODE:
	RETVAL = s->start_t;
	if(items>1)
	 s->start_t = newval;
	OUTPUT:
	RETVAL

pid_t
master_pid(s)
	Net::BitTorrent::LibBT::Tracker::Stats		s
	
	CODE:
	RETVAL = s->master_pid;
	OUTPUT:
	RETVAL

time_t
server_time(s, newval=0)
	Net::BitTorrent::LibBT::Tracker::Stats		s
	time_t										newval
	
	CODE:
	RETVAL = s->server_time;
	if(items>1)
	 s->server_time = newval;
	OUTPUT:
	RETVAL


MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker

Net::BitTorrent::LibBT::Tracker::Infohash
Infohash(t, h, create=0)
	Net::BitTorrent::LibBT::Tracker	t
	SV*									h
	int									create
	
	CODE:
	apr_pool_t*	p = NULL;
	btt_infohash* in_hash;
	perlhash* rv;
	DB_TXN* txn = NULL;
	DBT key;
	int ret = 0;
	unsigned int len = 0;
	char* infohash = SvPV(h, len);
	
	if(len != BT_INFOHASH_LEN)
	{
	 fprintf(stderr, "Net::BitTorrent::LibBT::Tracker->Infohash(): len %u != %u\n", len, BT_INFOHASH_LEN);
	 fflush(stderr);
	 XSRETURN_UNDEF;
	}

	if((ret = btt_txn_start(t->tracker, NULL, &txn, 0)) != 0)
	{
	 t->tracker->db.env->err(t->tracker->db.env, ret, "Net::BitTorrent::LibBT::Tracker->Infohash(): bt_txn_start()");
	 XSRETURN_UNDEF;
	}

	apr_pool_create(&p, t->tracker->p);
	
	bzero(&key, sizeof(key));
	key.data = infohash;
	key.size = BT_INFOHASH_LEN;
	key.ulen = BT_INFOHASH_LEN;
	key.flags = DB_DBT_USERMEM;
	
	if((in_hash = btt_txn_load_hash(t->tracker, p, txn, &key, 0, 0, create)))
	{
	 if((ret = txn->commit(txn, 0)) == 0)
	 {
	  New(0, rv, 1, perlhash);
	  rv->hash = in_hash;
	  rv->p = p;
	  rv->tracker = t->tracker;
	  RETVAL = (Net__BitTorrent__LibBT__Tracker__Infohash) rv;
	 }
	 else
	 {
	  t->tracker->db.env->err(t->tracker->db.env, ret, "Net::BitTorrent::LibBT::Tracker->Infohash(): commit()");
	  txn->abort(txn);
	  apr_pool_destroy(p);
	  XSRETURN_UNDEF;
	 }
	}
	else
	{
	 txn->abort(txn);
	 apr_pool_destroy(p);
	 XSRETURN_UNDEF;
	}
	
	OUTPUT:
	RETVAL

MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker

void
Infohashes(t)
	Net::BitTorrent::LibBT::Tracker	t;

	INIT:
	DB_TXN* txn;
	DBC* cur;
	DBT key;
	DBT val;
	apr_pool_t*	p;
	perlhash*	rv;
	char key_data[BT_INFOHASH_LEN];
	btt_infohash	val_data;
	SV* svrv;
	AV* arv = newAV();
	int ret = 0;
	int n = 0;
	
	PPCODE:
	
	if((ret = btt_txn_start(t->tracker, NULL, &txn, 0)) != 0)
	{
	 t->tracker->db.env->err(t->tracker->db.env, ret, "Net::BitTorrent::LibBT::Tracker->Infohashes(): bt_txn_start()");
	 XSRETURN_UNDEF;
	}
	
	if((ret = t->tracker->db.hashes->cursor(t->tracker->db.hashes, txn, &cur, 0)) != 0)
	{
	 t->tracker->db.env->err(t->tracker->db.env, ret, "Net::BitTorrent::LibBT::Tracker->Infohashes(): cursor()");
	 txn->abort(txn);
	 XSRETURN_UNDEF;
	}
	
	key.data = key_data;
	key.size = 0;
	key.ulen = BT_INFOHASH_LEN;
	key.flags = DB_DBT_USERMEM;
	
	val.data = &val_data;
	val.size = 0;
	val.ulen = sizeof(val_data);
	val.flags = DB_DBT_USERMEM;
	
	while(!ret)
	{
	 if((ret = cur->c_get(cur, &key, &val, DB_NEXT)) == 0)
	 {
	  New(0, rv, 1, perlhash);
	  apr_pool_create(&p, t->tracker->p);
	  rv->p = p;
	  rv->hash = apr_palloc(p, sizeof(btt_infohash));
	  *(rv->hash) = val_data;
	  rv->tracker = t->tracker;
	  svrv = newSV(sizeof(perlhash));
	  sv_setref_pv(svrv, "Net::BitTorrent::LibBT::Tracker::Infohash", rv);
	  XPUSHs(sv_2mortal(svrv));
	  n++;
	 }
	}
	
	if(ret != DB_NOTFOUND)
	{
	 t->tracker->db.env->err(t->tracker->db.env, ret, "Net::BitTorrent::LibBT::Tracker->Infohashes(): c_get()");
	 cur->c_close(cur);
	 txn->abort(txn);
	 av_undef(arv);
	 XSRETURN_UNDEF;
	}
	
	cur->c_close(cur);
	
	if((ret = txn->commit(txn, 0)) != 0)
	{
	 t->tracker->db.env->err(t->tracker->db.env, ret, "Net::BitTorrent::LibBT::Tracker->Infohashes(): commit()");
	 txn->abort(txn);
	 av_undef(arv);
	 XSRETURN_UNDEF;
	}
	
	
MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker::Infohash

void
DESTROY(h)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	
	CODE:
	apr_pool_destroy(h->p);
	bzero(h, sizeof(h));
	Safefree(h);

MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker::Infohash
int
save(h)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	
	CODE:
	int ret = 0;
	DB_TXN* txn = NULL;
	
	if((ret = btt_txn_start(h->tracker, NULL, &txn, 0)) != 0)
	{
	 h->tracker->db.env->err(h->tracker->db.env, ret, "Net::BitTorrent::LibBT::Tracker::Infohash->save(): bt_txn_start()");
	}
	else if((ret = btt_txn_save_hash(h->tracker, h->p, txn, h->hash)) != 0)
	{
	 h->tracker->db.env->err(h->tracker->db.env, ret, "Net::BitTorrent::LibBT::Tracker::Infohash->save(): bt_txn_save_hash()");
	 txn->abort(txn);
	}
	else if((ret = txn->commit(txn, 0)) != 0)
	{
	 h->tracker->db.env->err(h->tracker->db.env, ret, "Net::BitTorrent::LibBT::Tracker::Infohash->save(): commit()");
	 txn->abort(txn);
	}
	
	RETVAL = ret;
	
	OUTPUT:
	RETVAL

MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker::Infohash

SV*
infohash(h)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;

	CODE:
	RETVAL = newSVpv(h->hash->infohash, BT_INFOHASH_LEN);

	OUTPUT:
	RETVAL

MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker::Infohash

SV*
filename(h, newname=NULL)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	char*								newname;
	
	CODE:
	
	RETVAL = newSVpv(h->hash->filename, strlen(h->hash->filename));
	
	if(newname)
	{
	 strncpy(h->hash->filename, newname, sizeof(h->hash->filename) - 1);
	 h->hash->filename[sizeof(h->hash->filename)] = 0;
	}
	
	OUTPUT:
	RETVAL


MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker::Infohash

u_int64_t
filesize(h, newsize=0)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	u_int64_t							newsize;
	
	CODE:
	
	RETVAL = h->hash->filesize;
	
	if(items > 1)
	 h->hash->filesize = newsize;
	
	OUTPUT:
	RETVAL

MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker::Infohash

u_int64_t
max_uploaded(h)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	
	CODE:
	
	RETVAL = h->hash->max_uploaded;
	
	OUTPUT:
	RETVAL

MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker::Infohash

u_int64_t
max_downloaded(h)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	
	CODE:
	
	RETVAL = h->hash->max_downloaded;
	
	OUTPUT:
	RETVAL

MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker::Infohash

u_int64_t
max_left(h)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	
	CODE:
	
	RETVAL = h->hash->max_left;
	
	OUTPUT:
	RETVAL

MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker::Infohash

u_int64_t
min_left(h)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	
	CODE:
	
	RETVAL = h->hash->min_left;
	
	OUTPUT:
	RETVAL

MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker::Infohash

u_int64_t
hits(h, newhits=0)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	u_int64_t							newhits;
	
	
	CODE:
	
	RETVAL = h->hash->hits;
	
	if(items > 1)
	 h->hash->hits = newhits;
	
	OUTPUT:
	RETVAL

MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker::Infohash

u_int32_t
peers(h)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	
	CODE:
	
	RETVAL = h->hash->peers;
	
	OUTPUT:
	RETVAL

MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker::Infohash

u_int32_t
seeds(h)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	
	CODE:
	
	RETVAL = h->hash->seeds;
	
	OUTPUT:
	RETVAL

MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker::Infohash

u_int32_t
shields(h)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	
	CODE:
	
	RETVAL = h->hash->shields;
	
	OUTPUT:
	RETVAL

MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker::Infohash

u_int32_t
starts(h, newstarts=0)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	u_int32_t							newstarts;
	
	CODE:
	
	RETVAL = h->hash->starts;
	
	if(items > 1)
	 h->hash->starts = newstarts;
	
	OUTPUT:
	RETVAL

u_int32_t
stops(h, newstops=0)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	u_int32_t							newstops;
	
	CODE:
	
	RETVAL = h->hash->stops;
	
	if(items > 1)
	 h->hash->stops = newstops;
	
	OUTPUT:
	RETVAL

u_int32_t
completes(h, newcompletes=0)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	u_int32_t							newcompletes;
	
	CODE:
	
	RETVAL = h->hash->completes;
	
	if(items > 1)
	 h->hash->completes = newcompletes;
	
	OUTPUT:
	RETVAL

time_t
first_t(h)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	
	CODE:
	
	RETVAL = h->hash->first_t;
	
	OUTPUT:
	RETVAL

time_t
last_t(h, new_t=0)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	time_t								new_t;
	
	CODE:
	
	RETVAL = h->hash->last_t;
	
	if(items > 1)
	 h->hash->last_t = new_t;
	
	OUTPUT:
	RETVAL

time_t
register_t(h, new_t=0)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	time_t								new_t;
	
	CODE:
	
	RETVAL = h->hash->register_t;
	
	if(items > 1)
	 h->hash->register_t = new_t;
	
	OUTPUT:
	RETVAL

time_t
first_peer_t(h)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	
	CODE:
	RETVAL = h->hash->first_peer_t;
	OUTPUT:
	RETVAL

time_t
last_peer_t(h)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	
	CODE:
	RETVAL = h->hash->last_peer_t;
	OUTPUT:
	RETVAL

time_t
first_seed_t(h)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	
	CODE:
	RETVAL = h->hash->first_seed_t;
	OUTPUT:
	RETVAL

time_t
last_seed_t(h)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;
	
	CODE:
	RETVAL = h->hash->last_seed_t;
	OUTPUT:
	RETVAL

MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker::Infohash

Net::BitTorrent::LibBT::Tracker::Peer
Peer(h, inpeerid)
	Net::BitTorrent::LibBT::Tracker::Infohash	h
	SV*									inpeerid
	
	CODE:
	apr_pool_t*	p = NULL;
	btt_peer* in_peer;
	perlpeer* rv;
	DB_TXN* txn = NULL;
	DBT key;
	int ret = 0;
	unsigned int len = 0;
	char* peer_id = SvPV(inpeerid, len);
	
	if(len != BT_PEERID_LEN)
	{
	 fprintf(stderr, "Net::BitTorrent::LibBT::Tracker->Peer(): len %u != %u\n", len, BT_PEERID_LEN);
	 fflush(stderr);
	 XSRETURN_UNDEF;
	}

	if((ret = btt_txn_start(h->tracker, NULL, &txn, 0)) != 0)
	{
	 h->tracker->db.env->err(h->tracker->db.env, ret, "Net::BitTorrent::LibBT::Tracker->Infohash(): bt_txn_start()");
	 XSRETURN_UNDEF;
	}

	apr_pool_create(&p, h->p);
	
	bzero(&key, sizeof(key));
	key.data = apr_palloc(p, BT_PEERID_LEN + BT_INFOHASH_LEN);
	key.size = BT_PEERID_LEN + BT_INFOHASH_LEN;
	key.ulen = BT_PEERID_LEN + BT_INFOHASH_LEN;
	key.flags = DB_DBT_USERMEM;
	
	memcpy(key.data, h->hash->infohash, BT_INFOHASH_LEN);
	memcpy(key.data + BT_INFOHASH_LEN, peer_id, BT_PEERID_LEN);
	
	if((in_peer = btt_txn_load_peer(h->tracker, p, txn, &key, 0, 0, h->hash)))
	{
	 if((ret = txn->commit(txn, 0)) == 0)
	 {
	  New(0, rv, 1, perlpeer);
	  rv->hash = h->hash;
	  rv->p = p;
	  rv->tracker = h->tracker;
	  rv->peer = in_peer;
	  RETVAL = (Net__BitTorrent__LibBT__Tracker__Peer) rv;
	 }
	 else
	 {
	  h->tracker->db.env->err(h->tracker->db.env, ret, "Net::BitTorrent::LibBT::Tracker::Infohash->Peer(): commit()");
	  txn->abort(txn);
	  apr_pool_destroy(p);
	  XSRETURN_UNDEF;
	 }
	}
	else
	{
	 txn->abort(txn);
	 apr_pool_destroy(p);
	 XSRETURN_UNDEF;
	}
	
	OUTPUT:
	RETVAL

void
Peers(h)
	Net::BitTorrent::LibBT::Tracker::Infohash	h;

	INIT:
	DB_TXN* txn;
	DBC* cur;
	DBT key;
	DBT val;
	apr_pool_t*	p;
	perlpeer*	rv;
	char key_data[BT_INFOHASH_LEN];
	btt_peer	val_data;
	SV* svrv;
	int ret = 0;
	int n = 0;
	
	PPCODE:
	
	if((ret = btt_txn_start(h->tracker, NULL, &txn, 0)) != 0)
	{
	 h->tracker->db.env->err(h->tracker->db.env, ret, "Net::BitTorrent::LibBT::Tracker::Infohash->Peers(): bt_txn_start()");
	 XSRETURN_UNDEF;
	}
	
	if((ret = h->tracker->db.index->cursor(h->tracker->db.index, txn, &cur, 0)) != 0)
	{
	 h->tracker->db.env->err(h->tracker->db.env, ret, "Net::BitTorrent::LibBT::Tracker::Infohash->Peers(): cursor()");
	 txn->abort(txn);
	 XSRETURN_UNDEF;
	}
	
	key.data = key_data;
	key.size = BT_INFOHASH_LEN;
	key.ulen = BT_INFOHASH_LEN;
	key.flags = DB_DBT_USERMEM;
	
	memcpy(key_data, h->hash->infohash, BT_INFOHASH_LEN);
	
	val.data = &val_data;
	val.size = 0;
	val.ulen = sizeof(val_data);
	val.flags = DB_DBT_USERMEM;

	ret = cur->c_get(cur, &key, &val, DB_SET);
	
	while(!ret)
	{
	 New(0, rv, 1, perlpeer);
	 apr_pool_create(&p, h->p);
	 rv->p = p;
	 rv->hash = h->hash;
	 rv->tracker = h->tracker;
	 rv->peer = apr_palloc(p, sizeof(btt_peer));
	 *(rv->peer) = val_data;
	 svrv = newSV(sizeof(perlpeer));
	 sv_setref_pv(svrv, "Net::BitTorrent::LibBT::Tracker::Peer", rv);
	 XPUSHs(sv_2mortal(svrv));
	 n++;

	 ret = cur->c_get(cur, &key, &val, DB_NEXT_DUP);
	}
	
	if(ret != DB_NOTFOUND)
	{
	 h->tracker->db.env->err(h->tracker->db.env, ret, "Net::BitTorrent::LibBT::Tracker::Infohash->Peers(): c_get()");
	 cur->c_close(cur);
	 txn->abort(txn);
	 XSRETURN_UNDEF;
	}
	
	cur->c_close(cur);
	
	if((ret = txn->commit(txn, 0)) != 0)
	{
	 h->tracker->db.env->err(h->tracker->db.env, ret, "Net::BitTorrent::LibBT::Tracker::Infohash->Peers(): commit()");
	 txn->abort(txn);
	 XSRETURN_UNDEF;
	}

MODULE = Net::BitTorrent::LibBT::Tracker		PACKAGE = Net::BitTorrent::LibBT::Tracker::Peer

void
Flags()
	INIT:
	int i;
	PPCODE:
	for(i=0;btt_peer_flags[i].flag;i++)
	{
	 XPUSHs(sv_2mortal(newSViv(btt_peer_flags[i].flag)));
         XPUSHs(sv_2mortal(newSVpv(btt_peer_flags[i].config_name, strlen(btt_peer_flags[i].config_name))));
	}

void
DESTROY(p)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	
	CODE:
	apr_pool_destroy(p->p);
	bzero(p, sizeof(p));
	Safefree(p);

int
save(p)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	
	CODE:
	int ret = 0;
	DB_TXN* txn = NULL;
	
	if((ret = btt_txn_start(p->tracker, NULL, &txn, 0)) != 0)
	{
	 p->tracker->db.env->err(p->tracker->db.env, ret, "Net::BitTorrent::LibBT::Tracker::Peer->save(): bt_txn_start()");
	}
	else if((ret = btt_txn_save_peer(p->tracker, p->p, txn, p->peer, p->hash)) != 0)
	{
	 p->tracker->db.env->err(p->tracker->db.env, ret, "Net::BitTorrent::LibBT::Tracker::Peer->save(): bt_txn_save_hash()");
	 txn->abort(txn);
	}
	else if((ret = txn->commit(txn, 0)) != 0)
	{
	 p->tracker->db.env->err(p->tracker->db.env, ret, "Net::BitTorrent::LibBT::Tracker::Peer->save(): commit()");
	 txn->abort(txn);
	}
	
	RETVAL = ret;
	
	OUTPUT:
	RETVAL

SV*
peerid(p)
	Net::BitTorrent::LibBT::Tracker::Peer	p;

	CODE:
	RETVAL = newSVpv(p->peer->peerid, BT_PEERID_LEN);

	OUTPUT:
	RETVAL

SV*
infohash(p)
	Net::BitTorrent::LibBT::Tracker::Peer	p;

	CODE:
	RETVAL = newSVpv(p->peer->infohash, BT_INFOHASH_LEN);

	OUTPUT:
	RETVAL

SV*
ua(p, newua=NULL)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	char*							newua;

	CODE:
	RETVAL = newSVpv(p->peer->ua, strlen(p->peer->ua));
	
	if(newua)
	{
	 strncpy(p->peer->ua, newua, sizeof(p->peer->ua) - 1);
	 p->peer->ua[sizeof(p->peer->ua) - 1] = 0;
	}

	OUTPUT:
	RETVAL

SV*
event(p, newevent=NULL)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	char*							newevent;

	CODE:
	RETVAL = newSVpv(p->peer->event, strlen(p->peer->event));
	
	if(newevent)
	{
	 strncpy(p->peer->event, newevent, sizeof(p->peer->event) - 1);
	 p->peer->event[sizeof(p->peer->event) - 1] = 0;
	}

	OUTPUT:
	RETVAL

void
address(p, newaddress=0, newport=0)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	u_int32_t						newaddress;
	u_int16_t						newport;

	PPCODE:
	XPUSHs(sv_2mortal(newSVpv((char*)&(p->peer->address.sin_addr.s_addr), sizeof(p->peer->address.sin_addr.s_addr))));
	XPUSHs(sv_2mortal(newSViv(ntohs(p->peer->address.sin_port))));
	
	if(items > 1)
	 p->peer->address.sin_addr.s_addr = newaddress;
	
	if(items > 2)
	 p->peer->address.sin_port = htons(newport);

void
real_address(p, newaddress=0, newport=0)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	u_int32_t						newaddress;
	u_int16_t						newport;

	PPCODE:
	XPUSHs(sv_2mortal(newSViv(ntohl(p->peer->real_address.sin_addr.s_addr))));
	XPUSHs(sv_2mortal(newSViv(ntohs(p->peer->real_address.sin_port))));
	
	if(items > 1)
	 p->peer->real_address.sin_addr.s_addr = htonl(newaddress);
	
	if(items > 2)
	 p->peer->real_address.sin_port = htons(newport);

time_t
first_t(p, newtime=0)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	time_t							newtime;
	
	CODE:
	
	RETVAL = p->peer->first_t;
	if(items>1)
	 p->peer->first_t = newtime;
	
	OUTPUT:
	RETVAL

time_t
last_t(p, newtime=0)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	time_t							newtime;
	
	CODE:
	
	RETVAL = p->peer->last_t;
	if(items>1)
	 p->peer->last_t = newtime;
	
	OUTPUT:
	RETVAL

time_t
first_serve_t(p, newtime=0)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	time_t							newtime;
	
	CODE:
	
	RETVAL = p->peer->first_serve_t;
	if(items>1)
	 p->peer->first_serve_t = newtime;
	
	OUTPUT:
	RETVAL

time_t
last_serve_t(p, newtime=0)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	time_t							newtime;
	
	CODE:
	
	RETVAL = p->peer->last_serve_t;
	if(items>1)
	 p->peer->last_serve_t = newtime;
	
	OUTPUT:
	RETVAL

time_t
complete_t(p, newtime=0)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	time_t							newtime;
	
	CODE:
	
	RETVAL = p->peer->complete_t;
	if(items>1)
	 p->peer->complete_t = newtime;
	
	OUTPUT:
	RETVAL

time_t
return_interval(p, newtime=0)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	time_t							newtime;
	
	CODE:
	
	RETVAL = p->peer->return_interval;
	if(items>1)
	 p->peer->return_interval = newtime;
	
	OUTPUT:
	RETVAL


u_int32_t
hits(p, newval=0)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	u_int32_t						newval;
	
	CODE:
	
	RETVAL = p->peer->hits;
	if(items>1)
	 p->peer->hits = newval;
	
	OUTPUT:
	RETVAL

u_int32_t
serves(p, newval=0)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	u_int32_t						newval;
	
	CODE:
	
	RETVAL = p->peer->serves;
	if(items>1)
	 p->peer->serves = newval;
	
	OUTPUT:
	RETVAL

int32_t
num_want(p, newval=0)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	int32_t						newval;
	
	CODE:
	
	RETVAL = p->peer->num_want;
	if(items>1)
	 p->peer->num_want = newval;
	
	OUTPUT:
	RETVAL

u_int32_t
num_got(p, newval=0)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	u_int32_t						newval;
	
	CODE:
	
	RETVAL = p->peer->num_got;
	if(items>1)
	 p->peer->num_got = newval;
	
	OUTPUT:
	RETVAL

u_int64_t
announce_bytes(p, newval=0)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	u_int64_t						newval;
	
	CODE:
	
	RETVAL = p->peer->announce_bytes;
	if(items>1)
	 p->peer->announce_bytes = newval;
	
	OUTPUT:
	RETVAL

u_int64_t
uploaded(p, newval=0)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	u_int64_t						newval;
	
	CODE:
	
	RETVAL = p->peer->uploaded;
	if(items>1)
	 p->peer->uploaded = newval;
	
	OUTPUT:
	RETVAL

u_int64_t
downloaded(p, newval=0)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	u_int64_t						newval;
	
	CODE:
	
	RETVAL = p->peer->downloaded;
	if(items>1)
	 p->peer->downloaded = newval;
	
	OUTPUT:
	RETVAL

u_int64_t
left(p, newval=0)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	u_int64_t						newval;
	
	CODE:
	
	RETVAL = p->peer->left;
	if(items>1)
	 p->peer->left = newval;
	
	OUTPUT:
	RETVAL

unsigned char
flags(p, newval=0)
	Net::BitTorrent::LibBT::Tracker::Peer	p;
	unsigned char					newval;
	
	CODE:
	
	RETVAL = p->peer->flags;
	if(items>1)
	 p->peer->flags = newval;
	
	OUTPUT:
	RETVAL
