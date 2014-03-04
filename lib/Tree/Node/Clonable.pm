package Tree::Node::Clonable;

use strict;
use warnings;

use parent 'Tree::Node';

our $VERSION = '0.10';

use Carp;
use Scalar::Util qw/ blessed /;

=head1 NAME

Tree::Node::Clonable - a clonable Tree::Node

=head1 SYNOPSIS

  use Tree::Node::Clonable;

  my $node = Tree::Node::Clonable->new(10);

  ...

  my $data = $node->serialize();

  ...

  $node = Tree::Node::Clonable->deserialize($data);

=head1 DESCRIPTION

This class provides a serializable form of L<Tree::Node>.

=head1 METHODS

=head2 serialize

  $data = $node->serialize();

Returns a hash reference of the object.

It assumes the children are L<Tree::Node::Clonable> objects,
or that they have a C<serialize> method as per
L<Object::Serializer>.

=cut

sub serialize {
    my $self = shift;

    return unless
        $self && blessed($self) && $self->can('serialize');

    return {
        key      => $self->key,
        value    => $self->value,
        size     => $self->child_count,
        children => [ map { serialize($_) } $self->get_children ],
    };
}

=head2 deserialize

  $node = Tree::Node::Clonable->deserialize( \%data );

Deserializes a serialized node.

=cut

sub deserialize {
    my ($class, $data) = @_;

    croak "cannot deserialize"
        unless (
            $data &&
            ref($data) eq 'HASH' &&
            exists $data->{key} &&
            exists $data->{value} &&
            exists $data->{children} &&
            ref($data->{children}) eq 'ARRAY'
        );

    my $size = $data->{size} // ( 1 + $#{ $data->{children} } );
    my $self = __PACKAGE__->new($size);

    $self->set_key($data->{key});
    $self->set_value($data->{value});

    for(my $i = 0; $i < $size; $i++) {
        if (my $child = $data->{children}->[$i]) {
            $self->set_child($i, __PACKAGE__->deserialize($child));
        }
    }

    return $self;
}


=head1 AUTHOR

Robert Rothenberg <rrwo at cpan.org>

=head2 Suggestions and Bug Reporting

Feedback is always welcome.  Please use the CPAN Request Tracker at
L<http://rt.cpan.org> to submit bug reports.

=head1 LICENSE

Copyright (c) 2005-2014 Robert Rothenberg. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut

1;
