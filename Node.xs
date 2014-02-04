#if USE_MALLOC
#include <malloc.h>
#endif

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#define NEED_newRV_noinc
#include "ppport.h"

#include "TreeNode.h"

/*

   Since an IV is large enough to hold a pointer (see <perlguts>), we
   use that to store the new node information.

*/

MODULE = Tree::Node PACKAGE = Tree::Node

PROTOTYPES: ENABLE

SV*
new(package, child_count)
    char *package
    int  child_count
  PROTOTYPE: $$
  CODE:
    Node* self = new(child_count);
    SV*   n    = newSViv((IV) self);
    RETVAL     = newRV_noinc(n);
    sv_bless(RETVAL, gv_stashpv(package, 0));
    SvREADONLY_on(n);
    while (child_count--)
      self->next[child_count] = &PL_sv_undef;
  OUTPUT:
    RETVAL

void
DESTROY(n)
    SV* n
  PROTOTYPE: $
  CODE:
    Node* self = SV2NODE(n);
    int child_count = self->child_count;
    while (child_count--)
      SvREFCNT_dec(self->next[child_count]);
    DESTROY(self);

int
MAX_LEVEL()
  PROTOTYPE:
  CODE:
    RETVAL = MAX_LEVEL;
  OUTPUT:
    RETVAL

int
_allocated_by_child_count(count)
    int count
  PROTOTYPE: $
  CODE:
    RETVAL = NODESIZE(count);
  OUTPUT:
    RETVAL

int
_allocated(n)
    SV* n
  PROTOTYPE: $
  CODE:
    Node* self = SV2NODE(n);
    RETVAL = _allocated(self);
  OUTPUT:
    RETVAL

void
add_children(n, ...)
    SV* n
  ALIAS:
    add_children_left = 1
  PROTOTYPE: $;@
  PREINIT:
    int num = 1;
  CODE:
    Node* back;
    Node* self = SV2NODE(n);
    int   count = self->child_count;
    int   i;

    num = items-1;

    if (num<1)
      croak("number of children to add must be >= 1");
    if ((count+num) > MAX_LEVEL)
      croak("cannot %d children: we already have %d children", num, count);

    back = self;
#if USE_MALLOC
    self = realloc(self, (size_t) NODESIZE(count+num));
    if (self==NULL)
      croak("unable to allocate additional memory");
#else
    Renewc(self, NODESIZE(count+num), char, Node);
#endif

    if (self != back) {
      SvREADONLY_off((SV*)SvRV(n));
      sv_setiv((SV*) SvRV(n), (IV) self);
      SvREADONLY_on((SV*)SvRV(n));
    }

    self->child_count += num;

    if (ix==0) {
      for(i=0; i<num; i++)
        self->next[count+i] = newSVsv(ST(i+1));
    }
    else if (ix==1) {
      for(i=(count-1); i>=0; i--)
        self->next[i+num] = self->next[i];
      for(i=0; i<num; i++)
        self->next[i] = newSVsv(ST(i+1));
    }

int
child_count(n)
    SV* n
  PROTOTYPE: $
  CODE:
    Node* self = SV2NODE(n);
    RETVAL = child_count(self);
  OUTPUT:
    RETVAL

void
get_children(n)
    SV* n
  PROTOTYPE: $
  PREINIT:
    int i;
  PPCODE:
    Node* self = SV2NODE(n);
    EXTEND(SP, self->child_count);
    for (i = 0; i < self->child_count; i++)
      PUSHs(get_child(self, i));

SV*
get_child(n, index)
    SV* n
    int index
  PROTOTYPE: $$
  CODE:
    Node* self = SV2NODE(n);
    RETVAL = get_child(self, index);
  OUTPUT:
    RETVAL


SV*
get_child_maybe(n, index)
    SV* n
    int index
  PROTOTYPE: $$
  CODE:
    Node* self = SV2NODE(n);
    RETVAL = get_child_maybe(self, index);
  OUTPUT:
    RETVAL

SV*
get_child_or_undef(n, index)
    SV* n
    int index
  PROTOTYPE: $$
  CODE:
    Node* self = SV2NODE(n);
    RETVAL = get_child_maybe(self, index);
  OUTPUT:
    RETVAL

SV*
set_child(n, index, t)
    SV* n
    int index
    SV* t
  PROTOTYPE: $$$
  CODE:
    Node* self = SV2NODE(n);
    set_child(self, index, t);
    RETVAL = SvREFCNT_inc(n);
  OUTPUT:
    RETVAL

SV*
set_key(n, k)
    SV* n
    SV* k
  PROTOTYPE: $$
  CODE:
    Node* self = SV2NODE(n);
    set_key(self, k);
    RETVAL = SvREFCNT_inc(n);
  OUTPUT:
    RETVAL

SV*
force_set_key(n, k)
    SV* n
    SV* k
  PROTOTYPE: $$
  CODE:
    Node* self = SV2NODE(n);
    force_set_key(self, k);
    RETVAL = SvREFCNT_inc(n);
  OUTPUT:
    RETVAL

SV*
key(n)
    SV* n
  PROTOTYPE: $
  CODE:
    Node* self = SV2NODE(n);
    RETVAL = get_key(self);
  OUTPUT:
    RETVAL

I32
key_cmp(n, k)
    SV* n
    SV* k
  PROTOTYPE: $$
  CODE:
    Node* self = SV2NODE(n);
    RETVAL = key_cmp(self, k);
  OUTPUT:
    RETVAL

SV*
set_value(n, v)
    SV* n
    SV* v
  PROTOTYPE: $$
  CODE:
    Node* self = SV2NODE(n);
    set_value(self, v);
    RETVAL = SvREFCNT_inc(n);
  OUTPUT:
    RETVAL

SV*
value(n)
    SV* n
  PROTOTYPE: $
  CODE:
    Node* self = SV2NODE(n);
    RETVAL = get_value(self);
  OUTPUT:
    RETVAL
