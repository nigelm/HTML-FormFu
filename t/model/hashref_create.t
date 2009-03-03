use strict;
use warnings;

use Test::More tests => 3;

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->element('Checkbox')->name('bar')->value('y');

$form->auto_fieldset(1);

$form->default_model('HashRef');

$form->populate(
    {
        elements => [
            {
                type         => "DateTime",
                name         => "datetime",
                auto_inflate => 1,
                year         => { list => [1999] }
            },
            {
                name     => "inflator",
                deflator => { type => 'Strftime', strftime => '%F %H:%M' },
                inflator =>
                  { type => "DateTime", parser => { strptime => '%F' } }
            },
            {
                type        => "Repeatable",
                nested_name => "many",
                elements    => [
                    { name => "id" },
                    {
                        type     => "Block",
                        name     => "nested",
                        elements => [ { type => "Text", name => "foo" } ]
                    }
                ]
            },
            {
                type    => "Select",
                name    => "single-select",
                options => [ [qw(1 foo)], [qw(2 bar)] ]
            },
            {
                type    => "Select",
                name    => "multi-select",
                options => [ [qw(1 foo)], [qw(2 bar)] ]
            },
            {
                type        => "Block",
                nested_name => "nested",
                elements    => [ { type => "Text", name => "foo" } ]
            },
            {
                type     => "Multi",
                name     => "address",
                elements => [ { name => "street" }, { name => "number" } ]
            },
            {
                type     => "Multi",
                name     => "address-split",
                elements => [ { name => "street" }, { name => "number" } ],
                deflators => [ { type => "CompoundSplit" } ]
            },
            {
                type => "SimpleTable",
                rows => [ [ { name => "table1" } ] ]
            }
        ]
    }
);


$form->auto_fieldset(0);

$form->model->default_values(
    {
        datetime => '30-08-1999 22:00',
        bar      => 'y',
        many => [ { id => 1, foo => "bar" }, { id => 2, foo => "baz" } ],
        'single-select' => 1,
		'inflator' => '2008-09-22',
        'multi-select'  => [ 1, 2 ],
        nested          => { foo => "bar" },
        address         => { street => "Lombardstreet", number => 22 },
        'address-split' => "Lombardstreet 22",
        table1          => "test"
    });

$form->process;

is_deeply(
    $form->model->create,
    {
        bar  => 'y',
        many => [ { id => 1, foo => "bar" }, { id => 2, foo => "baz" } ],
        'single-select'   => 1,
        'datetime_year'   => 1999,
        'datetime_minute' => '00',
        'datetime_month'  => 8,
        'datetime_day'    => 30,
        'datetime_hour'   => '22',
        'datetime'        => '30-08-1999 22:00',
        'multi-select'    => [ 1, 2 ],
        nested            => { foo => "bar" },
        address           => { street => "Lombardstreet", number => 22 },
        'address-split'   => { street => "Lombardstreet", number => 22 },
        table1            => "test",
inflator => '2008-09-22 00:00'
    }
);

$form->model->options(1);

is_deeply(
    $form->model->create,
    {
        bar  => 'y',
        many => [ { id => 1, foo => "bar" }, { id => 2, foo => "baz" } ],
        'single-select' => { value => 1, label => "foo" },
        'multi-select' =>
          [ { value => 1, label => "foo" }, { value => 2, label => "bar" } ],
        nested          => { foo    => "bar" },
        address         => { street => "Lombardstreet", number => 22 },
        'address-split' => { street => "Lombardstreet", number => 22 },
        table1         => "test",
        'datetime_day' => {
            'value' => 30,
            'label' => 30
        },
        'datetime'        => '30-08-1999 22:00',
        'datetime_minute' => {
            'value' => '00',
            'label' => '00'
        },
        'datetime_month' => {
            'value' => 8,
            'label' => 'August'
        },
        'datetime_hour' => {
            'value' => '22',
            'label' => '22'
        },
        'datetime_year' => {
            'value' => '1999',
            'label' => '1999'
        },
inflator => '2008-09-22 00:00'
    }
);

$form->model->flatten(1);

$form->model->inflators(1);

is_deeply(
    $form->model->create,
    {
        'datetime'             => '30-08-1999 22:00',
        'address-split.street' => 'Lombardstreet',
        'datetime_year'        => 1999,
        'table1'               => 'test',
        'datetime_minute'      => '00',
        'bar'                  => 'y',
        'many.foo_2'           => 'baz',
        'address-split.number' => '22',
        'many.foo_1'           => 'bar',
        'many.id_2'            => 2,
        'multi-select_1'       => 2,
        'datetime_month'       => 8,
        'address.number'       => 22,
        'address.street'       => 'Lombardstreet',
        'single-select'        => 1,
        'datetime_hour'        => '22',
        'datetime_day'         => 30,
        'multi-select_0'       => 1,
        'nested.foo'           => 'bar',
        'many.id_1'            => 1,
inflator => '2008-09-22 00:00'
    }
);

#print $form->render;

#use Data::Dumper; print Dumper $form->model->create;