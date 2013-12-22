use strict;
use warnings FATAL => 'all';

use Test::More;
use if $ENV{AUTHOR_TESTING}, 'Test::Warnings';

{
    package MyTypeLibrary;
    use MooseX::Types::Moose 'Str';
    use MooseX::Types -declare => [ 'NonEmptyStr' ];
    use namespace::autoclean;
    subtype NonEmptyStr,
        as Str,
        where { length $_ },
        message { 'Str must not be empty' };
}

{
    package MyApp;
    BEGIN { MyTypeLibrary->import('NonEmptyStr') }

    for my $phase ('before', 'after')
    {
        ::note "$phase calling namespace::autoclean";

        ::ok(is_NonEmptyStr('a string'), 'is_NonEmptyStr');

        ::ok(NonEmptyStr->isa('Moose::Meta::TypeConstraint'), 'type is available as an import');

        ::ok(MyTypeLibrary->can('NonEmptyStr'), 'type is available as a fully-qualified name on the declaring class');

        ::ok(MyTypeLibrary::NonEmptyStr->isa('Moose::Meta::TypeConstraint'), 'type is the right type');
    }
    continue
    {
        namespace::autoclean->import;
    }

    ::ok(!MyTypeLibrary->can('NonEmptyStr'), 'type is not available as a method on the importing class');
}

done_testing;
