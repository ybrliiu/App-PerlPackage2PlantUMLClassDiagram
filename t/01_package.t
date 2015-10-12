use strict;
use Test::More 0.98;
use App::PerlPackage2PlantUMLClassDiagram::Package;

subtest 'simple' => sub {
    my $package = App::PerlPackage2PlantUMLClassDiagram::Package->new('t/data/User.pm');
    isa_ok $package, 'App::PerlPackage2PlantUMLClassDiagram::Package';
    is $package->source, 't/data/User.pm';
    isa_ok $package->document, 'PPI::Document';
    is $package->package_name, 'User';

    is_deeply $package->static_methods, ['new'];

    is_deeply $package->public_methods, ['name'];
    is_deeply $package->private_methods, ['_password'];

    is_deeply $package->parent_packages, ['Mammal', 'HasPassword'];

#     is $package->to_plantuml, <<'UML';
# class User {
#   username
#   password
#   +sign_in()
#   -sign_out()
# }
# UML
};

done_testing;

