#!/usr/bin/perl

package Inherited;

use base 'Tree::Node';

sub key_cmp {
  my $self = shift;
  my $key  = shift;
  return ($key cmp $self->key);
}

package main;

use strict;
use warnings;

use Test::Most;

my $size = 10;

my $x = Inherited->new($size);
$x->set_key("foo");
$x->set_value("bar");

ok(defined $x, "defined");
isa_ok($x, "Tree::Node");

is($x->child_count, $size, "level == size");

my $y = Inherited->new(2);
$y->set_key("moo");

ok(defined $y, "defined");
isa_ok($y, "Tree::Node");

ok($x->key eq "foo", "key");
dies_ok { $x->set_key("moo"); } "key cannot be changed";
isnt($x->key(), "moo", "key unchanged");

# Note: order of inherited should be reversed

is($x->key_cmp("monkey"), 1, "key_cmp");
is($x->key cmp "monkey", -1, "key_cmp reversed");
is($x->key_cmp("foo"), 0, "key_cmp");
is($x->key_cmp("bar"), -1, "key_cmp");
is($x->key cmp "bar", 1, "key_cmp reversed");

is($x->set_value(1)->value, 1, "set_value->value");
is($x->set_value(2)->value, 2, "set_value->value");

is($y->child_count, 2, "level == 2");

ok(!defined $y->get_child(0), "!defined y->get_child(0)");

$y->set_child(0, $x);
ok(defined $x, "x defined after set_child");

my $z = $y->get_child(0);
is($z, $x, "get_child");

ok(defined $z, "z=get_child(0) defined");
ok($z->isa("Tree::Node"), "isa");
ok($z->child_count == $size, "z->child_count == size");

ok(defined $x, "defined");
ok($x->child_count, "child_count");

{
  local $TODO = "tie hash to set_child/get_child";
  ok(($y->get_child(1)||0) == $x);
}

$z = Inherited->new(6);
isa_ok($z, "Tree::Node");
$z->set_key("zzz");
for (0..5) { $z->set_child($_, $x); }
is($z->child_count, 6, "child_count");
$y->set_child(0, $z);
is($y->get_child(0), $z, "get_child");
isnt($y->get_child(0), $x, "get_child");

throws_ok sub { $z->get_child(-1); },
    qr/index out of bounds/,
    "get_child out of bounds";

ok(!defined $z->get_child_or_undef(-1), "get_child_or_undef");

throws_ok sub { $z->get_child(6); },
    qr/index out of bounds/,
    "get_child out of bounds";

ok(!defined $z->get_child_or_undef(6), "get_child_or_undef");

done_testing;

