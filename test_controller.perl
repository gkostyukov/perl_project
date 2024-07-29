#!/usr/bin/perl
use strict;
use warnings;

# Function to read file contents
sub read_file {
    my ($filename) = @_;
    local $/ = undef;  # Enable 'slurp' mode
    open my $fh, '<', $filename or die "Could not open '$filename' for reading: $!";
    my $content = <$fh>;
    close $fh;
    return $content;
}

# Function to process template
sub process_template {
    my ($template, $replacements) = @_;

    # Replace simple placeholders
    foreach my $key (keys %$replacements) {
        next if ref($replacements->{$key}) eq 'ARRAY';  # Skip arrays for now
        my $placeholder = "{$key}";
        my $value = $replacements->{$key};
        $template =~ s/\Q$placeholder\E/$value/g;
    }

    # Process loops
    while ($template =~ /{foreach\s+(\w+)\s+in\s+(\w+)}(.*?){\/foreach}/gs) {
        my ($item_var, $array_var, $loop_content) = ($1, $2, $3);
        my $replacement = '';

        if (ref($replacements->{$array_var}) eq 'ARRAY') {
            foreach my $item (@{$replacements->{$array_var}}) {
                my $loop_iteration = $loop_content;
                $loop_iteration =~ s/\{$item_var\}/$item/g;
                $replacement .= $loop_iteration;
            }
        }

        $template =~ s/\Q{foreach $item_var in $array_var}$loop_content{\/foreach}\E/$replacement/;
    }

    return $template;
}

# Read the HTML template from the file
my $template_file = 'template.html';
my $html_template = read_file($template_file);

# Dynamic variables for replacements
my $dynamic_title = 'Dynamic Sample Title';
my $dynamic_header = 'Welcome to My Dynamic Website';
my $dynamic_content = 'This is a dynamic paragraph with dynamic content.';

# Define a hash with the keys and values to replace in the template
my %replacements = (
    title   => $dynamic_title,
    header  => $dynamic_header,
    content => $dynamic_content,
    items   => ['Item 1', 'Item 2', 'Item 3'],
);

# Process the template
my $processed_html = process_template($html_template, \%replacements);

# Print the resulting HTML
print "Content-type: text/html\n\n";
print $processed_html;
