#!/usr/bin/perl

use Test::Most;

use_ok("Tree::Node", 0.10);

my $size = 10;

ok(my $x = Tree::Node->new($size), "new");

ok(defined $x, "defined");
isa_ok($x, 'Tree::Node');

ok(!defined $x->key, "no key");
ok(!defined $x->value, "no value");

is($x->key_cmp("bo"), -1, "key is less than anything");

is( $x->set_key("poo")->key, "poo", "set_key->key" );
is( $x->set_value("bar")->value, "bar", "set_value->value" );

throws_ok(
    sub {
        $x->set_key("foo");
    },
    qr/key is already set/,
    "set_key (write once)"
);

isnt($x->key, "foo", "key unchanged");

ok($x->force_set_key("foo"), "force_set_key");
is($x->key, "foo", "key changed");

is($x->child_count, $size, "level == size");
is($x->_allocated, Tree::Node::_allocated_by_child_count($size),
 "_allocated \& size");

ok($x->key_cmp("monkey") == -1);
ok($x->key_cmp("foo") == 0);
ok($x->key_cmp("bar") == 1);

dies_ok {
    ok($x->key_cmp(undef) == 1);
} "key_cmp with undef key dies";

dies_ok {
    ok($x->key_cmp() == 1);
} "key_cmp with no args dies";

ok(my $y = Tree::Node->new(2), "new");
isa_ok($y, "Tree::Node");
ok($y->set_key("moo"), "set_key");


$x->set_value(1);
ok($x->value == 1);
$x->set_value(2);
ok($x->value == 2);

ok($y->child_count == 2, "level == 2");

ok(!defined $y->get_child(0), "!defined y->get_child(0)");

$y->set_child(0, $x);
ok(defined $x, "x defined after set_child");

my $z = $y->get_child(0);
ok($z == $x);
ok(defined $z, "z=get_child(0) defined");
ok($z->isa("Tree::Node"), "isa");
ok($z->child_count == $size, "z->child_count == size");

ok(defined $x);
ok($x->child_count);

{
  local $TODO = "tie hash to set_child/get_child";
  ok(($y->get_child(1)||0) == $x);
}

$z = Tree::Node->new(6);
$z->set_key("zzz");
for (0..5) {
    $z->set_child($_, $x);
    is($z->get_child($_), $x, "get_child == set_child");
}
is($z->child_count, 6, "child count");

$y->set_child(0, $z);
ok($y->get_child(0) == $z);
ok($y->get_child(0) != $x);

undef $@ ;
eval { $z->get_child(-1); };
ok($@, "get_child out of bounds");
ok(!defined $z->get_child_maybe(-1), "get_child_maybe");
ok(!defined $z->get_child_or_undef(-1), "get_child_or_undef");

undef $@ ;
eval { $z->get_child(6); };
ok($@, "get_child out of bounds");
ok(!defined $z->get_child_maybe(6), "get_child_maybe");
ok(!defined $z->get_child_or_undef(6), "get_child_or_undef");

# use Devel::Peek;
{
  my @c = $x->get_children;
  is(@c, $size);
  my $sx = $x->_allocated;
# Dump($x);
  $x->add_children(undef);
# Dump($x);  # (*) This one prevents a crash: why?!?!
  ok($x->_allocated > $sx, "size increased");
  is($x->child_count, $size+1, "added child");
  $size = $x->child_count; # so later tests pass
  @c = $x->get_children;
  is(@c, $size);
}

{
  my @c = $x->get_children;
  is(@c, $size);
# Dump($x);
  $x->add_children((undef) x 2);
# Dump($x);
  is($x->child_count, $size+2, "added child");
  $size = $x->child_count; # so later tests pass
  @c = $x->get_children;
  is(@c, $size);
}

{
  my @c = $x->get_children;
  is(@c, $size);
  my $sx = $x->_allocated;
  $x->set_child(0,$z);
# Dump($x);
  $x->add_children_left($y);
# Dump($x);  # (*) This one prevents a crash: why?!?!
  ok($x->_allocated > $sx, "size increased");
  is($x->child_count, $size+1, "added child");
  $size = $x->child_count; # so later tests pass
  @c = $x->get_children;
  is(@c, $size);
  ok($x->get_child(0) == $y);
  ok($x->get_child(1) == $z);
}

{
  my @c = $x->get_children;
  is(@c, $size);
# Dump($x);
  $x->add_children_left($z,$y);
# Dump($x);
  is($x->child_count, $size+2, "added child");
  $size = $x->child_count; # so later tests pass
  @c = $x->get_children;
  is(@c, $size);
  ok($x->get_child(1) == $y);
  ok($x->get_child(0) == $z);
  ok($x->get_child(2) == $y);
  ok($x->get_child(3) == $z);
}

done_testing;
