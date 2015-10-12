package App::PerlPackage2PlantUMLClassDiagram::Package;
use 5.008001;
use strict;
use warnings;

use PPI::Document;

sub new {
    my ($class, $source) = @_;

    bless {
        source => $source,
    }, $class;
}

sub source {
    my ($self) = @_;

    $self->{source};
}

sub document {
    my ($self) = @_;

    $self->{document} ||= PPI::Document->new($self->source);
}

sub package_name {
    my ($self) = @_;

    $self->document->find_first('PPI::Statement::Package')->namespace;
}

sub parent_packages {
    my ($self) = @_;

    my $includes = $self->document->find('PPI::Statement::Include');
    return [] unless $includes;

    my $parent_packages = [];

    # see also: App::PRT::Command::RenameClass
    for my $statement (@$includes) {
        next unless defined $statement->pragma;
        next unless $statement->pragma =~ /^parent|base$/; # only 'use parent' and 'use base' are supported

        # schild(2) is 'Foo' of use parent Foo
        my $parent = $statement->schild(2);

        if ($parent->isa('PPI::Token::Quote')) {
            # The 'literal' method is not implemented by ::Quote::Double or ::Quote::Interpolate.
            push @$parent_packages, $parent->can('literal') ? $parent->literal : $parent->string;
        } elsif ($parent->isa('PPI::Token::QuoteLike::Words')) {
            # use parent qw(A B C) pattern
            # literal is array when QuoteLike::Words
            push @$parent_packages, $parent->literal;
        }
    }

    $parent_packages;
}

sub _methods {
    my ($self) = @_;

    $self->document->find('PPI::Statement::Sub');
}

sub static_methods {
    my ($self) = @_;
    [ map { $_->name } grep { $_ =~ m{\$class} } @{$self->_methods} ];
}

sub public_methods {
    my ($self) = @_;

    [ map { $_->name } grep { index($_->name, '_') == -1 } grep { index($_->content, '$class') == -1 } @{$self->_methods} ];
}

sub private_methods {
    my ($self) = @_;

    [ map { $_->name } grep { index($_->name, '_') == 0 } grep { index($_->content, '$class') == -1 } @{$self->_methods} ];
}

sub to_class_syntax {
    my ($self) = @_;

    <<"UML"
class @{[ $self->package_name ]}
UML

}

1;
