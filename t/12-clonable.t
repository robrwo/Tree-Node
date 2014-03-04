#!/usr/bin/perl

use Test::Most;
use Test::Warnings;

use_ok("Tree::Node::Clonable", 0.10);

my $size = 10;

ok(my $x = Tree::Node::Clonable->new($size), "new");

ok(defined $x, "defined");
isa_ok($x, 'Tree::Node');
isa_ok($x, 'Tree::Node::Clonable');

ok(!defined $x->key, "no key");
ok(!defined $x->value, "no value");

is( $x->set_key("poo")->key, "poo", "set_key->key" );
is( $x->set_value("bar")->value, "bar", "set_value->value" );

ok(my $y = Tree::Node::Clonable->new(2), "new");
isa_ok($y, "Tree::Node");
ok($y->set_key("moo"), "set_key");

is($y->set_value(123)->value, 123, "set_value->value");

ok($y->child_count == 2, "level == 2");

ok(!defined $y->get_child(0), "!defined y->get_child(0)");

$y->set_child(0, $x);
ok(defined $x, "x defined after set_child");

$y->set_child(1, $x);

is($y->get_child(0), $y->get_child(1), "same children");

my $ser = $y->serialize;

is($ser->{children}->[0], $ser->{children}->[1], "same children");

note(explain $ser);

my $z = Tree::Node::Clonable->deserialize($ser);

isa_ok($z, 'Tree::Node::Clonable');

is($z->key, $y->key, "key");
is($z->value, $y->value, "value");

is($z->get_child(0)->key, $y->get_child(0)->key, "child(0)->key");
is($z->get_child(0)->value, $y->get_child(0)->value, "child(0)->value");

is($z->get_child(0), $z->get_child(1), "same children");

done_testing;
