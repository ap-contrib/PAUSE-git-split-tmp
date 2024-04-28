#!/usr/bin/env perl
use 5.014; use warnings; use autodie;

use Digest::SHA 'sha1_hex';

my $chunk_name = '00preamble';
my @line;

sub write_out {
	( my $fn_name = $ARGV ) =~ s/(?=\.txt\z)/.$chunk_name/
		or die "Bad input filename $ARGV\n";
	open my $fh, '>', $fn_name;
	print $fh splice @line;
	close $fh;
}

sub name_from { lc ( $_[0] =~ s/[ ,].*//sr =~ s/::/-/gr ) }

while ( <> ) {
	if ( @line > 500 and sha1_hex( my $next_name = name_from $_ ) =~ /^00/ ) {
		write_out;
		my $chop = '';
		while ( $next_name ne '' and $next_name ne $chunk_name ) {
			$chop = chop $next_name;
		}
		$chunk_name = $next_name . $chop;
	}

	push @line, $_;

	if ( eof ) {
		write_out;
		unlink $ARGV;
		$chunk_name = '00preamble';
	}
}

write_out if @line;
