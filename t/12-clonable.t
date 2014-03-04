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

is($x->set_value(1)->value, 1, "set_value->value");

ok($y->child_count == 2, "level == 2");

ok(!defined $y->get_child(0), "!defined y->get_child(0)");

$y->set_child(0, $x);
ok(defined $x, "x defined after set_child");

my $obj = $y->serialize;
is_deeply $obj,
 {
  'children' => [
    {
      'children' => [],
      'size' => 10,
      'key' => 'poo',
      'value' => 1
    }
  ],
  'key' => 'moo',
  'value' => undef,
  'size' => 2,
 }, "serialize";

note(explain $obj);

my $z = Tree::Node::Clonable->deserialize($obj);

is($z->key, $y->key, "key");
is($z->value, $y->value, "value");
is_deeply( $z->serialize, $obj, "deep comparison");

done_testing;
