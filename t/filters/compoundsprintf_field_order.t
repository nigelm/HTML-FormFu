use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new;

$form->load_config_file('t/filters/compoundsprintf_field_order.yml');

$form->process( {
        'date.month' => '6',
        'date.day'   => '26',
        'date.year'  => '2008',
    } );

ok( $form->submitted_and_valid );

is( $form->param_value('date'), '26-06-2008' );

is_deeply( $form->params, { date => '26-06-2008', }, );
